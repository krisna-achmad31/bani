// ─────────────────────────────────────────────────────────────────────────────
//  Security-rules tests for quota, branch limits and invite claiming.
//  Needs JDK 21+ (Firestore emulator). Run from this folder:
//    npm install
//    npm test        (= firebase emulators:exec --only firestore "node --test")
// ─────────────────────────────────────────────────────────────────────────────

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';

const { FieldValue, Timestamp } = firebase.firestore;
const OWNER = 'owner1';
const BUDI = 'budi1';
const CITRA = 'citra1';
const FID = OWNER; // free tree id == owner uid

let env;
const db = (uid) => env.authenticatedContext(uid).firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-bani',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});
after(() => env.cleanup());

// Seeds: owner profile (limit 50), a tree Mungin → Wiji → Budi (gen 3).
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const d = ctx.firestore();
    await d.doc('config/app').set({ defaultMemberLimit: 50, defaultBranchDepth: 2 });
    await d.doc(`users/${OWNER}`).set({ memberLimit: 50, plan: 'free', planUntil: null });
    await d.doc(`families/${FID}`).set({
      name: 'Bani Mungin', ownerId: OWNER, memberCount: 3, lastMemberOp: 'budi',
      roles: { [OWNER]: 'owner' }, memberUids: [OWNER],
    });
    await d.doc(`families/${FID}/grants/${OWNER}`).set({ role: 'owner', anchorMemberId: 'mungin', maxGeneration: null });
    const m = (id, parentId, generation, ancestors) =>
      d.doc(`families/${FID}/members/${id}`).set({
        fullName: id, parentId, generation, ancestors, claimedByUid: null, createdBy: OWNER,
      });
    await m('mungin', null, 1, []);
    await m('wiji', 'mungin', 2, ['mungin']);
    await m('budi', 'wiji', 3, ['mungin', 'wiji']);
  });
});

function addChild(d, uid, parent, id) {
  const b = d.batch();
  b.set(d.doc(`families/${FID}/members/${id}`), {
    fullName: id, parentId: parent.id, generation: parent.generation + 1,
    ancestors: [...parent.ancestors, parent.id], claimedByUid: null, createdBy: uid,
  });
  b.update(d.doc(`families/${FID}`), { memberCount: FieldValue.increment(1), lastMemberOp: id });
  return b.commit();
}

const BUDI_NODE = { id: 'budi', generation: 3, ancestors: ['mungin', 'wiji'] };
const node = (id, parent) => ({
  id, generation: parent.generation + 1, ancestors: [...parent.ancestors, parent.id],
});

async function inviteAndClaim(uid, memberId, maxDepth = 2) {
  await db(OWNER).doc('invites/tok1').set({
    familyId: FID, memberId, role: 'contributor', maxDepth, usedBy: null,
    createdByUid: OWNER, expiresAt: Timestamp.fromDate(new Date(Date.now() + 86400000)),
  });
  const d = db(uid);
  const b = d.batch();
  b.update(d.doc('invites/tok1'), { usedBy: uid, usedAt: FieldValue.serverTimestamp() });
  b.set(d.doc(`families/${FID}/grants/${uid}`), {
    role: 'contributor', anchorMemberId: memberId, maxGeneration: 3 + maxDepth, inviteToken: 'tok1',
  });
  b.update(d.doc(`families/${FID}/members/${memberId}`), { claimedByUid: uid });
  b.update(d.doc(`families/${FID}`), {
    [`roles.${uid}`]: 'contributor', memberUids: FieldValue.arrayUnion(uid),
  });
  return b.commit();
}

describe('akun', () => {
  test('profil baru wajib pakai limit default', async () => {
    await assertSucceeds(db('new1').doc('users/new1').set({ memberLimit: 50, plan: 'free', planUntil: null }));
    await assertFails(db('new2').doc('users/new2').set({ memberLimit: 9999, plan: 'free', planUntil: null }));
  });

  test('user tidak bisa menaikkan limit sendiri', async () => {
    await assertFails(db(OWNER).doc(`users/${OWNER}`).update({ memberLimit: 500 }));
  });

  test('akun gratis hanya boleh 1 pohon (id = uid)', async () => {
    const d = db('new3');
    await d.doc('users/new3').set({ memberLimit: 50, plan: 'free', planUntil: null });
    const mk = (fid) => {
      const b = d.batch();
      b.set(d.doc(`families/${fid}`), {
        name: 'x', ownerId: 'new3', memberCount: 1, lastMemberOp: 'root',
        roles: { new3: 'owner' }, memberUids: ['new3'],
      });
      b.set(d.doc(`families/${fid}/members/root`), {
        fullName: 'x', parentId: null, generation: 1, ancestors: [], claimedByUid: 'new3', createdBy: 'new3',
      });
      b.set(d.doc(`families/${fid}/grants/new3`), { role: 'owner', anchorMemberId: 'root', maxGeneration: null });
      return b.commit();
    };
    await assertSucceeds(mk('new3'));
    await assertFails(mk('pohon-kedua'));
  });
});

describe('kuota anggota', () => {
  test('owner bisa menambah anak dengan counter', async () => {
    await assertSucceeds(addChild(db(OWNER), OWNER, BUDI_NODE, 'anak1'));
  });

  test('tanpa counter ditolak', async () => {
    const d = db(OWNER);
    await assertFails(d.doc(`families/${FID}/members/liar`).set({
      fullName: 'x', parentId: 'budi', generation: 4, ancestors: ['mungin', 'wiji', 'budi'],
      claimedByUid: null, createdBy: OWNER,
    }));
  });

  test('penuh = ditolak', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      ctx.firestore().doc(`users/${OWNER}`).update({ memberLimit: 3 }));
    await assertFails(addChild(db(OWNER), OWNER, BUDI_NODE, 'anak1'));
  });

  test('generation palsu ditolak', async () => {
    await assertFails(addChild(db(OWNER), OWNER, { ...BUDI_NODE, generation: 1 }, 'x'));
  });
});

describe('cabang kontributor', () => {
  test('klaim undangan lalu isi sampai generasi 5', async () => {
    await assertSucceeds(inviteAndClaim(BUDI, 'budi'));
    const anak = node('anak1', BUDI_NODE);
    const cucu = node('cucu1', anak);
    await assertSucceeds(addChild(db(BUDI), BUDI, BUDI_NODE, 'anak1'));
    await assertSucceeds(addChild(db(BUDI), BUDI, anak, 'cucu1'));
    await assertFails(addChild(db(BUDI), BUDI, cucu, 'cicit1')); // generasi 6
  });

  test('di luar cabang ditolak', async () => {
    await inviteAndClaim(BUDI, 'budi');
    await assertFails(addChild(db(BUDI), BUDI, { id: 'wiji', generation: 2, ancestors: ['mungin'] }, 'x'));
  });

  test('kontributor tidak bisa menaikkan batas atau mengundang', async () => {
    await inviteAndClaim(BUDI, 'budi');
    await assertFails(db(BUDI).doc(`families/${FID}/grants/${BUDI}`).update({ maxGeneration: 99 }));
    await assertFails(db(BUDI).doc('invites/tok2').set({
      familyId: FID, memberId: 'budi', role: 'contributor', maxDepth: 2, usedBy: null,
      createdByUid: BUDI, expiresAt: Timestamp.fromDate(new Date(Date.now() + 86400000)),
    }));
  });

  test('akun baru tanpa undangan tidak bisa menulis', async () => {
    await inviteAndClaim(BUDI, 'budi');
    await assertFails(addChild(db(CITRA), CITRA, BUDI_NODE, 'x'));
  });

  test('undangan tidak bisa dipakai dua kali', async () => {
    await assertSucceeds(inviteAndClaim(BUDI, 'budi'));
    const d = db(CITRA);
    const b = d.batch();
    b.update(d.doc('invites/tok1'), { usedBy: CITRA });
    b.set(d.doc(`families/${FID}/grants/${CITRA}`), {
      role: 'contributor', anchorMemberId: 'budi', maxGeneration: 5, inviteToken: 'tok1',
    });
    await assertFails(b.commit());
  });
});
