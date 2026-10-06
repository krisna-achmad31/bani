#!/usr/bin/env node
// ─────────────────────────────────────────────────────────────────────────────
//  Migrate the legacy nested collection (e.g. `mungin`, where children live in
//  `anak[]` arrays and/or an `anak` subcollection) into the flat structure
//  used by the app: families/{familyId}/members/{memberId}.
//
//  Usage (dry run by default — prints a report, writes nothing):
//    set GOOGLE_APPLICATION_CREDENTIALS=path\to\service-account.json
//    node migrate.js --project famtree-489cc --source mungin \
//        --owner-uid <your uid> --family-id bani-mungin --name "Bani Mungin"
//  Add --commit to write. Add --make-admin to mark the owner as Super Admin
//  and --init-config to create config/app with defaults if it is missing.
//  The source collection is never modified or deleted.
// ─────────────────────────────────────────────────────────────────────────────

const admin = require('firebase-admin');

const args = Object.fromEntries(
  process.argv.slice(2).reduce((acc, a, i, all) => {
    if (a.startsWith('--')) {
      const next = all[i + 1];
      acc.push([a.slice(2), next && !next.startsWith('--') ? next : true]);
    }
    return acc;
  }, []),
);

const project = args.project;
const source = args.source || 'mungin';
const ownerUid = args['owner-uid'];
const familyId = args['family-id'] || `bani-${source}`;
const familyName = args.name || `Bani ${source[0].toUpperCase()}${source.slice(1)}`;
const commit = args.commit === true;

if (!project || !ownerUid) {
  console.error('Wajib: --project <id> --owner-uid <uid>. Lihat komentar di atas file.');
  process.exit(1);
}

admin.initializeApp({ projectId: project });
const db = admin.firestore();
const { FieldValue, Timestamp } = admin.firestore;

// ── Parsing helpers (mirror lib/core/utils/formatters.dart) ─────────────────

const MONTHS = ['januari', 'februari', 'maret', 'april', 'mei', 'juni', 'juli',
  'agustus', 'september', 'oktober', 'november', 'desember'];

function parseDob(raw) {
  if (!raw || typeof raw !== 'string' || !raw.trim()) return { place: null, date: null, yearOnly: false };
  let text = raw.trim();
  let place = null;
  const comma = text.indexOf(',');
  if (comma > 0) {
    place = text.slice(0, comma).trim();
    text = text.slice(comma + 1).trim();
  }
  const parts = text.split(/\s+/);
  if (parts.length === 3) {
    const d = parseInt(parts[0], 10);
    const m = MONTHS.indexOf(parts[1].toLowerCase());
    const y = parseInt(parts[2], 10);
    if (!isNaN(d) && m >= 0 && !isNaN(y)) {
      return { place, date: new Date(Date.UTC(y, m, d)), yearOnly: false };
    }
  }
  const y = parseInt(parts[parts.length - 1], 10);
  if (!isNaN(y) && y > 1000) return { place, date: new Date(Date.UTC(y, 0, 1)), yearOnly: true };
  return { place: place || raw, date: null, yearOnly: false, unparsed: true };
}

function gender(v) {
  const s = String(v || '').toLowerCase();
  if (s.startsWith('p') || s.includes('wanita')) return 'female';
  if (s.startsWith('l') || s.includes('pria')) return 'male';
  return 'unknown';
}

function isDead(v) {
  const s = String(v || '').toLowerCase();
  return ['meninggal', 'wafat', 'alm', 'almarhum', 'almarhumah'].some((k) => s.includes(k));
}

function spouseStatus(v) {
  const s = String(v || '').toLowerCase();
  if (isDead(s)) return 'deceased';
  if (s.includes('cerai')) return 'divorced';
  return 'married';
}

function spouses(p) {
  if (!p) return [];
  const list = Array.isArray(p) ? p : [p];
  return list
    .filter((s) => s && (s.nama || typeof s === 'string'))
    .map((s) => (typeof s === 'string'
      ? { name: s, status: 'married', memberId: null }
      : { name: s.nama, status: spouseStatus(s.status), memberId: null }));
}

// ── Walk the legacy tree ─────────────────────────────────────────────────────

const members = [];
const report = { perGeneration: {}, unparsedDob: [] };
const membersCol = db.collection('families').doc(familyId).collection('members');

function addMember(node, parent, order) {
  const ref = membersCol.doc();
  const dob = parseDob(node.dob || node.ttl || node.tanggal_lahir);
  if (dob.unparsed) report.unparsedDob.push(`${node.nama}: ${node.dob}`);
  const generation = parent ? parent.generation + 1 : 1;
  const ancestors = parent ? [...parent.ancestors, parent.id] : [];
  const m = {
    id: ref.id,
    generation,
    ancestors,
    data: {
      fullName: String(node.nama || node.name || 'Tanpa nama').trim(),
      nickname: null,
      parentId: parent ? parent.id : null,
      generation,
      ancestors,
      birthOrder: Number(node.anak_ke) || order || null,
      gender: gender(node.gender || node.jenis_kelamin),
      birthPlace: dob.place,
      birthDate: dob.date ? Timestamp.fromDate(dob.date) : null,
      birthYearOnly: dob.yearOnly,
      birthRaw: dob.unparsed ? node.dob : null,
      isDeceased: isDead(node.status),
      deathDate: null,
      deathYearOnly: false,
      grave: null,
      spouses: spouses(node.pasangan),
      occupation: node.pekerjaan || null,
      notes: null,
      photoThumb: null,
      hasPhoto: false,
      claimedByUid: null,
      createdBy: ownerUid,
      legacySource: `${source}`,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
  };
  members.push(m);
  report.perGeneration[generation] = (report.perGeneration[generation] || 0) + 1;
  return m;
}

async function walk(node, parent, order, snapRef) {
  const m = addMember(node, parent, order);
  const kids = Array.isArray(node.anak) ? node.anak : [];
  let i = 0;
  for (const kid of kids) await walk(kid, m, ++i, null);
  if (snapRef) {
    const sub = await snapRef.collection('anak').get();
    for (const d of sub.docs) await walk(d.data(), m, ++i, d.ref);
  }
}

async function main() {
  const snap = await db.collection(source).get();
  if (snap.empty) throw new Error(`Collection "${source}" kosong atau tidak ditemukan.`);

  for (const d of snap.docs) {
    const data = d.data();
    if (data.nama) {
      await walk(data, null, 1, d.ref);
    } else {
      // Document without its own name = the ancestor (named after the collection)
      // whose children are in `anak[]` / the `anak` subcollection.
      await walk({ ...data, nama: familyName.replace(/^Bani\s+/i, '') }, null, 1, d.ref);
    }
  }

  const roots = members.filter((m) => m.generation === 1);
  console.log(`\nSumber: ${source}  →  families/${familyId} ("${familyName}")`);
  console.log(`Total anggota: ${members.length}  (leluhur/root: ${roots.length})`);
  for (const [g, n] of Object.entries(report.perGeneration)) console.log(`  Generasi ${g}: ${n}`);
  if (report.unparsedDob.length) {
    console.log(`\nTanggal lahir yang tidak terbaca (disimpan di birthRaw):`);
    report.unparsedDob.forEach((s) => console.log(`  - ${s}`));
  }

  if (!commit) {
    console.log('\nDry run selesai. Tambahkan --commit untuk menulis ke Firestore.');
    return;
  }

  const famRef = db.collection('families').doc(familyId);
  if ((await famRef.get()).exists) throw new Error(`families/${familyId} sudah ada. Pakai --family-id lain.`);

  const writes = [
    (b) => b.set(famRef, {
      name: familyName,
      ownerId: ownerUid,
      memberCount: members.length,
      lastMemberOp: members[members.length - 1].id,
      roles: { [ownerUid]: 'owner' },
      memberUids: [ownerUid],
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }),
    (b) => b.set(famRef.collection('grants').doc(ownerUid), {
      role: 'owner', anchorMemberId: roots[0].id, maxGeneration: null,
      createdAt: FieldValue.serverTimestamp(),
    }),
    ...members.map((m) => (b) => b.set(membersCol.doc(m.id), m.data)),
  ];
  if (args['make-admin']) {
    writes.push((b) => b.set(db.collection('admins').doc(ownerUid), { since: FieldValue.serverTimestamp() }));
  }
  if (args['init-config'] && !(await db.collection('config').doc('app').get()).exists) {
    writes.push((b) => b.set(db.collection('config').doc('app'), {
      defaultMemberLimit: 50,
      defaultBranchDepth: 2,
      showPricing: true,
      adminWhatsapp: '',
      packages: [
        { id: 'branch', name: 'Buka Cabang', description: '+2 generasi untuk cabang ini', price: 15000, period: 'sekali bayar' },
        { id: 'members50', name: 'Tambah 50 anggota', description: 'Untuk semua pohon milik Owner', price: 25000, period: 'sekali bayar' },
        { id: 'premium', name: 'Premium Keluarga', description: 'Anggota & generasi tanpa batas', price: 79000, period: 'per tahun', tag: 'Hemat' },
      ],
    }));
  }

  for (let i = 0; i < writes.length; i += 400) {
    const batch = db.batch();
    writes.slice(i, i + 400).forEach((w) => w(batch));
    await batch.commit();
    console.log(`  ditulis ${Math.min(i + 400, writes.length)}/${writes.length}`);
  }
  console.log(`\nSelesai. Data lama di "${source}" tidak diubah.`);
}

main().catch((e) => {
  console.error('\nGagal:', e.message);
  process.exit(1);
});
