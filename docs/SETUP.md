# Setup Bani

Urutan langkah supaya app jalan dengan Firebase. Detail produk ada di PRD.

## 1. Hubungkan ke project Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<project-id> --platforms=android,ios --android-package-name=com.bani.bani --ios-bundle-id=com.bani.bani
```

Perintah ini menimpa `lib/firebase_options.dart` dan menambahkan `google-services.json`.

## 2. Login Google

1. Firebase Console → Authentication → Sign-in method → aktifkan **Google**.
2. Tambahkan SHA-1 debug (dan release) di Project settings → app Android:
   `keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android`
3. Salin **Web client ID** (Authentication → Google → Web SDK configuration) ke
   `AppConstants.googleServerClientId` di `lib/core/constants/app_constants.dart`.
   google_sign_in 7 butuh ini untuk mendapat idToken di Android.

## 3. Firestore rules

```bash
firebase deploy --only firestore:rules,firestore:indexes --project <project-id>
```

Test rules (butuh JDK 21+): `cd tools/rules_test && npm install && npm test`.

## 4. Config dan Super Admin (di Console)

- `config/app`:
  - `defaultMemberLimit` (number) = 50
  - `defaultBranchDepth` (number) = 2
  - `showPricing` (boolean) = true (matikan kalau Play Store keberatan)
  - `adminWhatsapp` (string) = nomor WA admin, format `62812...`
  - `packages` (array, opsional): `{id, name, description, price, period, tag?}`
- `admins/{uid-kamu}`: dokumen apa saja, misalnya `{since: <timestamp>}`. uid ada di Authentication → Users.

Tambah kuota setelah pembayaran manual: ubah `users/{uid}.memberLimit`, atau set `plan` = `premium` dan `planUntil` = tanggal berakhir.
Buka cabang: ubah `families/{id}/grants/{uid}.maxGeneration`.

## 5. Link undangan (Android App Links)

Link undangan berbentuk `https://bani-app.web.app/invite?t=<token>`. Ganti host di
`AppConstants.inviteHost` dan di `AndroidManifest.xml` sesuai domain Hosting project.
Lalu buat `hosting/.well-known/assetlinks.json` berisi SHA-256 signing key app,
dan deploy: `firebase deploy --only hosting`.
Tanpa langkah ini, link tetap bisa ditempel lewat Beranda → "Punya link undangan?".

## 6. Migrasi data lama `mungin`

```bash
cd tools/migrate_mungin && npm install
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\service-account.json
node migrate.js --project <project-id> --source mungin --owner-uid <uid> --family-id bani-mungin --name "Bani Mungin"
```

Tanpa `--commit` skrip hanya menampilkan laporan (dry run). Setelah dicek, jalankan ulang
dengan `--commit` (plus `--make-admin --init-config` bila perlu). Collection `mungin` tidak diubah.

## 7. Paket & aktivasi pembayaran manual (di Console → Firestore → `users/{uid}`)

| Paket | Yang diisi di `users/{uid}` |
| --- | --- |
| Keluarga (Rp49.000/thn) | `plan` = `keluarga`, `planUntil` = timestamp +1 tahun |
| Keluarga Besar (Rp99.000/thn) | `plan` = `keluarga_besar`, `planUntil` = timestamp +1 tahun (boleh buat pohon ke-2, id `uid_2`) |
| Paket Foto +30 (Rp15.000) | `albumBonus` = nilai lama + 30 |
| Buka Cabang (Rp15.000) | di `families/{fid}/grants/{uid}`: `maxGeneration` = nilai lama + 2 |

Batas tiap paket ada di `config/app.plans` (`trees`, `members`, `branchDepth`, `album`, `uploadsPerDay`) dan `config/app.minMembersForAlbum` (default 5) — bisa diubah online.
Setelah `plan` diubah, user cukup buka ulang aplikasi (label paket di pohon ikut tersinkron).

Satu HP hanya bisa membuat 1 pohon gratis (`devices/{hash}`). Untuk membebaskan HP (mis. ganti akun resmi), hapus dokumen `devices/{hash}` itu.

## 8. App Check (mode monitor selama testing)

1. Firebase Console → **App Check** → tab **Apps** → pilih Android `com.bani.bani` → **Play Integrity** → Register.
   Masukkan SHA-256 sertifikat rilis:
   `E9:BE:1C:01:9F:AB:07:1A:71:C9:8B:B2:3E:B5:C7:9A:4E:20:3D:81:85:8F:8C:8D:D3:63:46:5A:16:51:F3:68`
   (saat sudah di Play Store, tambahkan juga SHA-256 "App signing key" dari Play Console → Setup → App integrity).
2. Tab **APIs** → **Cloud Firestore** → biarkan status **Unenforced** = mode monitor. Grafik "Verified / Unverified requests" mulai terisi, tapi tidak ada yang diblokir.
   **Jangan klik "Enforce"** sampai aplikasi dibagikan lewat Play Store (APK kiriman WhatsApp tidak lolos Play Integrity).
3. Build debug (`flutter run`) memakai debug provider: cari di logcat baris `Enter this debug secret into the allow list ...`, lalu salin tokennya ke App Check → Apps → ⋮ → **Manage debug tokens**.
