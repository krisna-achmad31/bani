// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class L10nId extends L10n {
  L10nId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Bani';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get open => 'Buka';

  @override
  String get create => 'Buat';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Coba lagi';

  @override
  String get later => 'Nanti saja';

  @override
  String get saving => 'Menyimpan...';

  @override
  String get loadFailed => 'Gagal memuat';

  @override
  String get notFound => 'Data tidak ditemukan';

  @override
  String get copied => 'Disalin.';

  @override
  String generation(int n) {
    return 'Generasi $n';
  }

  @override
  String membersCount(int n) {
    return '$n anggota';
  }

  @override
  String generationsCount(int n) {
    return '$n generasi';
  }

  @override
  String peopleCount(int n) {
    return '$n orang';
  }

  @override
  String childOf(String name) {
    return 'anak $name';
  }

  @override
  String get someoneElse => 'anggota lain';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabTree => 'Pohon';

  @override
  String get tabInvite => 'Undang';

  @override
  String get tabProfile => 'Profil';

  @override
  String get exitTitle => 'Keluar dari Bani?';

  @override
  String get exitBody => 'Kamu bisa kembali kapan saja. Data tetap tersimpan.';

  @override
  String get exitConfirm => 'Keluar';

  @override
  String get loginSlide1Title =>
      'Silsilah bani yang tumbuh ke bawah, enak dibaca di HP.';

  @override
  String get loginSlide1Body =>
      'Tiap cabang mengisi keluarganya sendiri, lalu kumpul lagi lewat reuni, halal bihalal, atau liburan bareng.';

  @override
  String get loginSlide2Title => 'Undang saudara lewat WhatsApp.';

  @override
  String get loginSlide2Body =>
      'Kirim kode, saudara masuk dengan Google, lalu mengisi cabangnya sendiri.';

  @override
  String get loginSlide3Title => 'Kontak dan makam, satu ketukan.';

  @override
  String get loginSlide3Body =>
      'Buka WhatsApp, telepon, atau lokasi di Google Maps langsung dari profil anggota.';

  @override
  String get loginPendingInvite => 'Masuk untuk membuka undangan';

  @override
  String get loginWithGoogle => 'Masuk dengan Google';

  @override
  String get loginTerms =>
      'Dengan masuk, kamu menyetujui Ketentuan dan Kebijakan Privasi Bani.';

  @override
  String get previewChild => 'Anak';

  @override
  String get loginCancelled => 'Login dibatalkan.';

  @override
  String get loginNoToken =>
      'Google tidak mengirim token. Cek konfigurasi Firebase.';

  @override
  String loginFailed(String reason) {
    return 'Login gagal: $reason';
  }

  @override
  String get inviteTitle => 'Undangan';

  @override
  String get inviteClaimed => 'Berhasil! Sekarang kamu bisa mengisi cabangmu.';

  @override
  String get inviteCannotOpen => 'Undangan tidak bisa dibuka';

  @override
  String get inviteToHome => 'Ke beranda';

  @override
  String get inviteNotFound => 'Undangan tidak ditemukan';

  @override
  String get inviteInvalid => 'Undangan tidak berlaku';

  @override
  String get inviteUsed =>
      'Kode ini sudah dipakai. Minta kode baru ke pengirim.';

  @override
  String get inviteExpired =>
      'Kode ini sudah kedaluwarsa atau dibatalkan. Minta kode baru ke pengirim.';

  @override
  String get inviteCanEditSelf => 'Melengkapi data dan foto dirimu';

  @override
  String get inviteCanAddKids => 'Menambah anak dan cucu';

  @override
  String inviteCanAddKidsUntil(int n) {
    return 'Menambah anak dan cucu, sampai generasi $n';
  }

  @override
  String get inviteCanManage => 'Mengelola seluruh pohon';

  @override
  String inviteCanView(String family) {
    return 'Melihat seluruh pohon $family';
  }

  @override
  String inviteFrom(String name, String family) {
    return '$name mengundangmu mengisi cabang di $family.';
  }

  @override
  String get inviteIsThisYou => 'Apakah ini kamu?';

  @override
  String get inviteAfterClaim => 'Setelah klaim, kamu bisa';

  @override
  String get inviteYesMe => 'Ya, ini saya';

  @override
  String get inviteNotMe => 'Bukan saya';

  @override
  String get inviteAlreadyUsed => 'Undangan sudah dipakai atau kedaluwarsa.';

  @override
  String get inviteAlreadyJoined => 'Akunmu sudah terhubung ke pohon ini.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleContributor => 'Kontributor';

  @override
  String get roleViewer => 'Hanya lihat';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get spouseMarried => 'Menikah';

  @override
  String get spouseDivorced => 'Cerai';

  @override
  String get spouseDeceased => 'Wafat';

  @override
  String get alive => 'Hidup';

  @override
  String get deceased => 'Wafat';

  @override
  String get deceasedShort => 'wafat';

  @override
  String homeGreeting(String name) {
    return 'Assalamu\'alaikum, $name';
  }

  @override
  String get homeTitle => 'Keluarga saya';

  @override
  String get homeSetupFailed => 'Gagal menyiapkan akun';

  @override
  String get homeTrees => 'Pohon keluarga';

  @override
  String get homeNewTree => 'Buat pohon baru';

  @override
  String get homeHaveCode => 'Punya kode undangan?';

  @override
  String get homeWelcomeTitle => 'Selamat datang di Bani';

  @override
  String get homeWelcomeBody =>
      'Diundang keluarga? Pilih \"Punya kode undangan?\" lalu masukkan kodenya. Ingin mencatat silsilah sendiri? Pilih \"Buat pohon baru\".';

  @override
  String get enterCodeTitle => 'Masukkan kode undangan';

  @override
  String get enterCodeBody =>
      'Minta kode 8 huruf dari keluarga yang mengundangmu, atau tempel link-nya.';

  @override
  String get newTreeTitle => 'Pohon baru';

  @override
  String get newTreeName => 'Nama bani, contoh: Bani Harun';

  @override
  String get newTreeRoot => 'Nama leluhur utama';

  @override
  String get quotaTitle => 'Kuota anggota';

  @override
  String get quotaUnlimited => '/ tanpa batas';

  @override
  String get quotaAdd => 'Tambah kuota';

  @override
  String get quotaSuperAdmin => 'Super Admin · semua pohon tanpa batas';

  @override
  String get quotaPremium => 'Premium aktif';

  @override
  String quotaLeft(int n) {
    return '$n slot tersisa untuk pohon milikmu';
  }

  @override
  String get treeOnlyOwnBranch =>
      'Kamu hanya bisa menambah anak di cabangmu sendiri.';

  @override
  String get treeEmptyTitle => 'Belum ada pohon';

  @override
  String get treeEmptyBody =>
      'Buat pohon baru di Beranda atau masukkan kode undangan dari keluargamu.';

  @override
  String get treeSearch => 'Cari anggota';

  @override
  String get treeExport => 'Ekspor ke Excel';

  @override
  String get treeRename => 'Ganti nama pohon';

  @override
  String get treeRenameTitle => 'Nama pohon';

  @override
  String get treeFilterAll => 'Semua';

  @override
  String get treeFilterMine => 'Cabang saya';

  @override
  String get treeGoToMe => 'Ke saya';

  @override
  String get treeAddChild => 'Tambah anak';

  @override
  String get treeViewDetail => 'Lihat detail';

  @override
  String get treeEditData => 'Edit data';

  @override
  String get treeMove => 'Pindahkan ke orang tua lain';

  @override
  String get treeMe => 'Saya';

  @override
  String get searchName => 'Cari nama';

  @override
  String get detailNotFound => 'Anggota tidak ditemukan';

  @override
  String detailChildOrder(int n, String parent) {
    return 'Anak ke-$n dari $parent';
  }

  @override
  String detailChildOf(String parent) {
    return 'Anak dari $parent';
  }

  @override
  String detailAliveAge(int n) {
    return 'Hidup · $n tahun';
  }

  @override
  String detailDeceasedAge(int n) {
    return 'Wafat · usia $n tahun';
  }

  @override
  String detailLastEdit(String name, String date) {
    return 'Terakhir diubah oleh $name · $date';
  }

  @override
  String detailChildren(int n) {
    return 'Anak ($n)';
  }

  @override
  String get detailNoChildren => 'Belum ada anak yang dicatat.';

  @override
  String detailDeleteKidsFirst(String name) {
    return 'Hapus anak-anaknya dulu sebelum menghapus $name.';
  }

  @override
  String detailDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get detailDeleteBody =>
      'Data, foto, dan kontaknya akan dihapus dari pohon.';

  @override
  String get detailWhatsapp => 'WhatsApp';

  @override
  String get detailCall => 'Telepon';

  @override
  String get detailOpenMaps => 'Buka Maps';

  @override
  String get detailGrave => 'Makam';

  @override
  String get detailBorn => 'Lahir';

  @override
  String get detailDied => 'Wafat';

  @override
  String get detailAddress => 'Alamat';

  @override
  String get detailSpouse => 'Pasangan';

  @override
  String get detailGender => 'Jenis kelamin';

  @override
  String get detailOccupation => 'Pekerjaan';

  @override
  String get detailNotes => 'Catatan';

  @override
  String get detailOpenInMaps => 'Buka di Maps';

  @override
  String get detailContactHidden => 'Kontak belum diisi atau privat';

  @override
  String get detailUnclaimed => 'Profil belum diklaim';

  @override
  String detailUnclaimedBody(String name) {
    return 'Undang $name atau anaknya untuk mengisi cabang ini sendiri.';
  }

  @override
  String get detailInvite => 'Undang';

  @override
  String waGreeting(String name) {
    return 'Assalamu\'alaikum $name';
  }

  @override
  String get formStepIdentity => 'Identitas';

  @override
  String get formStepBirth => 'Lahir';

  @override
  String get formStepSpouse => 'Pasangan';

  @override
  String get formStepContact => 'Kontak';

  @override
  String get formNextBirth => 'Lanjut: Lahir & wafat';

  @override
  String get formNextSpouse => 'Lanjut: Pasangan';

  @override
  String get formNextContact => 'Lanjut: Kontak';

  @override
  String get formEditTitle => 'Edit data';

  @override
  String get formAddTitle => 'Tambah anak';

  @override
  String formChildOf(String parent, int n) {
    return 'Anak dari $parent · Generasi $n';
  }

  @override
  String formRoot(int n) {
    return 'Leluhur utama · Generasi $n';
  }

  @override
  String formChangedBy(String name) {
    return 'Baru saja diubah oleh $name.';
  }

  @override
  String get formReload => 'Muat';

  @override
  String formQuotaUse(int n) {
    return 'Memakai 1 dari $n slot anggota yang tersisa';
  }

  @override
  String get formNameRequired => 'Nama lengkap wajib diisi.';

  @override
  String get formSaveChanges => 'Simpan perubahan';

  @override
  String get formSaveMember => 'Simpan anggota';

  @override
  String get formAddPhoto => 'Tambah foto';

  @override
  String get formChangePhoto => 'Ganti foto';

  @override
  String get formPhotoHint =>
      'Dari kamera atau galeri. Dikompres otomatis supaya ringan.';

  @override
  String get formFullName => 'Nama lengkap';

  @override
  String get formFullNameHint => 'Contoh: Hasan Basri';

  @override
  String get formNickname => 'Nama panggilan';

  @override
  String get formNicknameHint => 'Contoh: Pak Hasan';

  @override
  String get formGender => 'Jenis kelamin';

  @override
  String get formBirthOrder => 'Anak ke-';

  @override
  String get formOccupation => 'Pekerjaan';

  @override
  String get formOccupationHint => 'Contoh: Guru';

  @override
  String get formCamera => 'Kamera';

  @override
  String get formGallery => 'Galeri';

  @override
  String get formRemovePhoto => 'Hapus foto';

  @override
  String get formBirthPlace => 'Tempat lahir';

  @override
  String get formBirthPlaceHint => 'Contoh: Kediri';

  @override
  String get formBirthDate => 'Tanggal lahir';

  @override
  String get formYearOnlyKnown => 'Hanya tahun yang diketahui';

  @override
  String get formStatus => 'Status';

  @override
  String get formDeathDate => 'Tanggal wafat';

  @override
  String get formYearOnly => 'Hanya tahun';

  @override
  String get formGrave => 'Lokasi makam';

  @override
  String get formGravePick => 'Pilih lokasi makam di peta';

  @override
  String get formGraveHint =>
      'Lokasi makam membantu keluarga saat ziarah dan haul.';

  @override
  String get formSpouseIntro =>
      'Tambahkan istri atau suami. Bisa lebih dari satu, misalnya jika menikah lagi.';

  @override
  String formSpouseN(int n) {
    return 'Pasangan $n';
  }

  @override
  String get formName => 'Nama';

  @override
  String get formSpouseNameHint => 'Nama lengkap pasangan';

  @override
  String get formAddSpouse => 'Tambah pasangan';

  @override
  String get formWhatsapp => 'Nomor WhatsApp';

  @override
  String get formHomeAddress => 'Alamat rumah';

  @override
  String get formAddressPick => 'Pilih alamat di peta';

  @override
  String get formAddressDetail => 'Detail: RT/RW, patokan';

  @override
  String get formWhoSeesContact => 'Siapa yang bisa melihat kontak?';

  @override
  String get formVisibilityFamily => 'Semua anggota pohon';

  @override
  String get formVisibilityFamilyHint => 'Keluarga bisa langsung WhatsApp';

  @override
  String get formVisibilityAdmins => 'Hanya Owner & Admin';

  @override
  String get formVisibilityAdminsHint => 'Lebih privat';

  @override
  String get formNotes => 'Catatan (opsional)';

  @override
  String get formNotesHint => 'Kisah singkat, pesan, atau kenangan';

  @override
  String get formConflictTitle => 'Ada perubahan baru';

  @override
  String formConflictBody(String message) {
    return '$message\n\nMuat data terbaru (perubahanmu dibuang), atau tetap simpan hanya bagian yang kamu ubah di atas data terbaru?';
  }

  @override
  String get formLoadLatest => 'Muat terbaru';

  @override
  String get formKeepMine => 'Tetap simpan';

  @override
  String get formPickDate => 'Pilih tanggal';

  @override
  String get formTapToOpenMap => 'Ketuk untuk membuka peta';

  @override
  String get formChangeOnMap => 'Ubah di peta';

  @override
  String get mapSelected => 'Lokasi terpilih';

  @override
  String get mapNotFound => 'Alamat tidak ditemukan.';

  @override
  String get mapPermissionDenied => 'Izin lokasi ditolak.';

  @override
  String get mapNoGps => 'Lokasi tidak bisa didapat. Pastikan GPS aktif.';

  @override
  String get mapSearch => 'Cari alamat atau tempat';

  @override
  String get mapMyLocation => 'Lokasi saya';

  @override
  String get mapResolving => 'Mencari alamat...';

  @override
  String get mapDrag => 'Geser peta';

  @override
  String get mapDetailHint => 'Detail: RT/RW, patokan, warna pagar';

  @override
  String get mapUse => 'Pakai lokasi ini';

  @override
  String get mapTitleDefault => 'Pilih lokasi';

  @override
  String get invPageTitle => 'Undang keluarga';

  @override
  String invPageBody(int n) {
    return 'Kontributor mengisi cabangnya sendiri, sampai $n generasi di bawahnya.';
  }

  @override
  String get invOnlyManagers =>
      'Hanya Owner atau Admin yang bisa mengundang. Minta mereka mengirim kode untukmu atau saudaramu.';

  @override
  String get invForWho => 'Untuk siapa?';

  @override
  String get invPickMember => 'Pilih anggota';

  @override
  String get invPickMemberHint => 'Orang yang akan mengisi cabangnya';

  @override
  String get invClaimed => 'sudah diklaim';

  @override
  String get invUnclaimed => 'belum diklaim';

  @override
  String invContributorDepth(int n, int days) {
    return 'Bisa mengisi $n generasi di bawahnya · kode berlaku $days hari';
  }

  @override
  String invContributorUntil(int n, int days) {
    return 'Bisa mengisi sampai generasi $n · kode berlaku $days hari';
  }

  @override
  String get invAdminHint => 'Admin bisa mengedit seluruh pohon dan mengundang';

  @override
  String get invViewerHint => 'Hanya bisa melihat pohon';

  @override
  String get invCreating => 'Membuat kode...';

  @override
  String get invCreate => 'Buat kode undangan';

  @override
  String invMessage(
    String name,
    String family,
    String code,
    int days,
    String link,
  ) {
    return 'Assalamu\'alaikum $name, ayo isi silsilah $family di aplikasi Bani.\n\n1. Buka aplikasi Bani, masuk dengan Google\n2. Di Beranda, pilih \"Punya kode undangan?\"\n3. Masukkan kode: *$code*\n\nKode berlaku $days hari.\n$link';
  }

  @override
  String get invCodeFor => 'Kode undangan untuk';

  @override
  String invCodeMeta(String role, int days) {
    return '$role · berlaku $days hari · sekali pakai';
  }

  @override
  String get invSendWhatsapp => 'Kirim lewat WhatsApp';

  @override
  String get invCopyCode => 'Salin kode';

  @override
  String get invCodeCopied => 'Kode disalin.';

  @override
  String get invSent => 'Undangan terkirim';

  @override
  String invSentMeta(String role, String code) {
    return '$role · kode $code';
  }

  @override
  String invDaysLeft(int n) {
    return '$n hari lagi';
  }

  @override
  String get invCancel => 'Batalkan';

  @override
  String get invActive => 'Akses aktif';

  @override
  String get invNoneYet => 'Belum ada yang diundang.';

  @override
  String get invMember => 'Anggota';

  @override
  String invUntilGen(String role, int n) {
    return '$role · s/d generasi $n';
  }

  @override
  String get invStatusActive => 'Aktif';

  @override
  String get invRevoke => 'Cabut akses';

  @override
  String get profileSuperAdmin => 'Super Admin';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profileFree => 'Paket Gratis';

  @override
  String get profileUnlimited => 'anggota · tanpa batas';

  @override
  String profileOfLimit(int n) {
    return 'dari $n anggota';
  }

  @override
  String get profileQuotaHint =>
      'Kuota dipakai bersama oleh pohon milikmu, termasuk isian kontributor.';

  @override
  String get profileSettings => 'PENGATURAN';

  @override
  String get profileLanguage => 'Bahasa';

  @override
  String get profileContactPrivacy => 'Privasi kontak';

  @override
  String get profileContactPrivacyValue => 'Diatur per anggota';

  @override
  String get profileSuperAdminSection => 'SUPER ADMIN';

  @override
  String get profileImport => 'Impor data Bani Mungin';

  @override
  String get profileFeedbackInbox => 'Saran masuk';

  @override
  String get profileOther => 'LAINNYA';

  @override
  String get profileSendFeedback => 'Kirim saran';

  @override
  String get profileHelp => 'Bantuan via WhatsApp';

  @override
  String get profileHelpMessage => 'Halo admin Bani, saya butuh bantuan.';

  @override
  String get profileLogout => 'Keluar';

  @override
  String profileVersion(String v) {
    return 'Bani versi $v';
  }

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get importReadFailed => 'Gagal membaca data';

  @override
  String get importTitle => 'Impor Bani Mungin';

  @override
  String importFound(int n) {
    return '$n orang ditemukan';
  }

  @override
  String importPerGen(int g, int n) {
    return 'Generasi $g: $n orang';
  }

  @override
  String importChildrenOf(String name) {
    return 'Anak dari $name:';
  }

  @override
  String importKidCount(String name, int n) {
    return '$name ($n anak)';
  }

  @override
  String get importAlready => 'Data ini sudah pernah diimpor.';

  @override
  String get importWillCreate =>
      'Pohon baru \"Bani Mungin\" akan dibuat dengan kamu sebagai Owner. Data lama tidak diubah.';

  @override
  String get importDo => 'Impor';

  @override
  String importDone(int n) {
    return '$n anggota berhasil diimpor.';
  }

  @override
  String get importEmpty =>
      'Collection \"mungin\" kosong atau tidak bisa dibaca.';

  @override
  String get importNoName => 'Tanpa nama';

  @override
  String get limitBranchTitle => 'Cabang ini sudah sampai batas';

  @override
  String get limitMemberTitle => 'Kuota anggota sudah penuh';

  @override
  String limitBranchBody(String name, int n) {
    return 'Cabang $name gratis sampai generasi $n. Pilih paket untuk melanjutkan, lalu bayar lewat admin.';
  }

  @override
  String limitMemberBody(String family, int n) {
    return 'Pohon $family sudah memakai $n slot anggota. Tambah kuota untuk melanjutkan.';
  }

  @override
  String limitWaMessage(
    String package,
    String family,
    String familyId,
    String email,
    String uid,
  ) {
    return 'Halo admin Bani, saya ingin $package.\nPohon: $family ($familyId)\nAkun: $email ($uid)';
  }

  @override
  String get limitAddQuota => 'menambah kuota';

  @override
  String get limitNoAdminWa =>
      'Nomor WhatsApp admin belum diatur di config/app.';

  @override
  String get limitPickPackage => 'Pilih paket';

  @override
  String limitPay(String price) {
    return 'Bayar $price via WhatsApp';
  }

  @override
  String get limitContactAdmin => 'Hubungi admin via WhatsApp';

  @override
  String get limitAskOwner => 'Minta Owner saja';

  @override
  String get limitAfterTransfer =>
      'Setelah transfer, admin mengonfirmasi dan kuota terbuka otomatis.';

  @override
  String limitGen(int n) {
    return 'Gen $n';
  }

  @override
  String get pkgBranchName => 'Buka Cabang';

  @override
  String get pkgBranchDesc => '+2 generasi untuk satu cabang';

  @override
  String get pkgMembersName => 'Tambah 50 anggota';

  @override
  String get pkgMembersDesc => '+50 anggota & +10 foto album';

  @override
  String get pkgPremiumName => 'Premium Keluarga';

  @override
  String get pkgPremiumDesc => 'Anggota tanpa batas & 200 foto album';

  @override
  String get pkgOnce => 'sekali bayar';

  @override
  String get pkgYearly => 'per tahun';

  @override
  String get pkgSave => 'Hemat';

  @override
  String get moveRootNotAllowed => 'Leluhur utama tidak bisa dipindah.';

  @override
  String get moveIntoOwnSubtree =>
      'Tidak bisa dipindah ke bawah keturunannya sendiri.';

  @override
  String get moveConfirmTitle => 'Pindahkan anggota?';

  @override
  String moveConfirmBody(String name, String parent, int n) {
    return '$name akan dipindah menjadi anak dari $parent (generasi $n).';
  }

  @override
  String moveConfirmBodyWithKids(String name, int kids, String parent, int n) {
    return '$name beserta $kids keturunannya akan dipindah menjadi anak dari $parent (generasi $n).';
  }

  @override
  String get moveDo => 'Pindahkan';

  @override
  String moveDone(String name, String parent) {
    return '$name sekarang anak dari $parent.';
  }

  @override
  String movePickTitle(String name) {
    return 'Pindahkan $name';
  }

  @override
  String get movePickHint => 'Pilih orang tua yang benar.';

  @override
  String get errPermission =>
      'Ditolak server [permission-denied]. Cek kuota, cabang, atau versi aplikasi.';

  @override
  String get errOffline =>
      'Tidak ada koneksi. Perubahan akan dikirim saat online.';

  @override
  String get errNotFound => 'Data tidak ditemukan.';

  @override
  String errGeneric(String code) {
    return 'Terjadi kesalahan ($code).';
  }

  @override
  String get errEditDenied =>
      'Perubahan ditolak server [edit/permission-denied]. Pastikan Bani versi terbaru (lihat Profil) dan kamu Admin atau Kontributor cabang ini.';

  @override
  String errConflict(String name) {
    return 'Data ini baru saja diubah oleh $name.';
  }

  @override
  String get xlsGeneration => 'Generasi';

  @override
  String get xlsFullName => 'Nama lengkap';

  @override
  String get xlsNickname => 'Panggilan';

  @override
  String get xlsGender => 'Jenis kelamin';

  @override
  String get xlsBirthOrder => 'Anak ke-';

  @override
  String get xlsParent => 'Orang tua';

  @override
  String get xlsBirthPlace => 'Tempat lahir';

  @override
  String get xlsBirthDate => 'Tanggal lahir';

  @override
  String get xlsStatus => 'Status';

  @override
  String get xlsDeathDate => 'Tanggal wafat';

  @override
  String get xlsSpouse => 'Pasangan';

  @override
  String get xlsOccupation => 'Pekerjaan';

  @override
  String xlsShareText(String family) {
    return 'Silsilah $family';
  }

  @override
  String get fbTitle => 'Kirim saran';

  @override
  String get fbBody =>
      'Ada ide fitur, keluhan, atau data yang salah? Tulis di sini, langsung sampai ke pengembang.';

  @override
  String get fbTypeIdea => 'Ide fitur';

  @override
  String get fbTypeBug => 'Ada masalah';

  @override
  String get fbTypeOther => 'Lainnya';

  @override
  String get fbHint => 'Tulis saranmu...';

  @override
  String get fbSend => 'Kirim';

  @override
  String get fbTooShort => 'Tulis minimal 5 huruf.';

  @override
  String get fbThanks => 'Terima kasih! Saranmu sudah terkirim.';

  @override
  String get fbInboxTitle => 'Saran masuk';

  @override
  String get fbInboxEmpty => 'Belum ada saran.';

  @override
  String get fbMarkDone => 'Tandai selesai';

  @override
  String get fbDone => 'Selesai';

  @override
  String get fbNew => 'Baru';

  @override
  String get treeRefresh => 'Muat ulang data';

  @override
  String get treeRefreshed => 'Data sudah diperbarui.';

  @override
  String albumTitle(int n) {
    return 'Album kenangan ($n)';
  }

  @override
  String get albumEmpty =>
      'Belum ada foto lama. Tambahkan foto kenangan supaya anak cucu bisa ikut melihat.';

  @override
  String get albumAdd => 'Tambah foto';

  @override
  String albumUploading(int done, int total) {
    return 'Mengunggah $done/$total...';
  }

  @override
  String albumUploaded(int n) {
    return '$n foto ditambahkan.';
  }

  @override
  String get albumCaptionTitle => 'Keterangan foto';

  @override
  String get albumCaptionHint => 'Contoh: Lebaran di rumah kakek';

  @override
  String get albumYearHint => 'Tahun (opsional)';

  @override
  String get albumDelete => 'Hapus foto';

  @override
  String get albumDeleteConfirm => 'Hapus foto ini dari album?';

  @override
  String albumBy(String name) {
    return 'Diunggah oleh $name';
  }

  @override
  String albumQuota(int used, int limit) {
    return '$used/$limit foto di pohon ini';
  }

  @override
  String get albumLimitTitle => 'Kuota album penuh';

  @override
  String albumLimitBody(String family, int n) {
    return 'Pohon $family sudah memakai $n foto album. Tambah kuota untuk mengunggah lagi.';
  }

  @override
  String get albumEditCaption => 'Ubah keterangan';

  @override
  String memberHasAlbum(String name) {
    return 'Hapus dulu foto album $name sebelum menghapus anggota ini.';
  }

  @override
  String get pkgFamilyName => 'Keluarga';

  @override
  String get pkgFamilyDesc => 'Anggota & cabang tanpa batas · 60 foto';

  @override
  String get pkgBigFamilyName => 'Keluarga Besar';

  @override
  String get pkgBigFamilyDesc => '2 pohon · tanpa batas · 150 foto per pohon';

  @override
  String get pkgPhotosName => 'Paket Foto +30';

  @override
  String get pkgPhotosDesc => '+30 foto album untuk pohonmu';

  @override
  String get planFree => 'Paket Gratis';

  @override
  String get planFamily => 'Keluarga';

  @override
  String get planBigFamily => 'Keluarga Besar';

  @override
  String get treeLimitTitle => 'Pohon kedua butuh Keluarga Besar';

  @override
  String get treeLimitBody =>
      'Paket Keluarga Besar bisa punya 2 pohon, misalnya keluarga ayah dan ibu, atau keluargamu dan keluarga pasangan.';

  @override
  String get deviceUsed =>
      'HP ini sudah dipakai membuat pohon gratis dengan akun lain. Masuk dengan akun itu, atau pilih paket berbayar.';

  @override
  String albumNeedMembers(int n) {
    return 'Tambahkan minimal $n anggota dulu sebelum mengunggah foto album.';
  }

  @override
  String albumDailyLimit(int n) {
    return 'Batas upload hari ini sudah tercapai ($n foto). Coba lagi besok.';
  }

  @override
  String get tabEvents => 'Acara';

  @override
  String get treeFilterAllBranches => 'Semua cabang';

  @override
  String get treeModeList => 'Silsilah';

  @override
  String get treeModeFocus => 'Fokus';

  @override
  String get treeShowInFocus => 'Lihat dalam mode Fokus';

  @override
  String silsilahMyGeneration(int n) {
    return 'Generasi kamu: $n';
  }

  @override
  String get silsilahThisIsYou => 'ini kamu';

  @override
  String get silsilahCollapse => 'Lipat cabang';

  @override
  String silsilahExpand(int n) {
    return 'Buka $n keturunan';
  }

  @override
  String get silsilahExpandAll => 'Buka semua cabang';

  @override
  String get silsilahCollapseAll => 'Lipat semua cabang';

  @override
  String get focusParent => 'Orang tua';

  @override
  String focusSibling(int pos, int total) {
    return 'Saudara $pos dari $total';
  }

  @override
  String get focusTapHint => 'Ketuk untuk pindah fokus';

  @override
  String focusChildCount(int n) {
    return '$n anak';
  }

  @override
  String focusBorn(int year) {
    return 'Lahir $year';
  }

  @override
  String focusChildOrder(int n, int total) {
    return 'anak ke-$n dari $total';
  }

  @override
  String focusSpouse(String name) {
    return 'Pasangan: $name';
  }

  @override
  String get focusProfile => 'Profil';

  @override
  String get eventTypeReunion => 'Reuni';

  @override
  String get eventTypeHalalBihalal => 'Halal bihalal';

  @override
  String get eventTypeHoliday => 'Liburan bareng';

  @override
  String get eventTypeArisan => 'Arisan';

  @override
  String get eventTypeHaul => 'Haul, tahlilan';

  @override
  String get eventTypeOther => 'Lainnya';

  @override
  String get eventToday => 'Hari ini';

  @override
  String get eventTomorrow => 'Besok';

  @override
  String eventInDays(int n) {
    return '$n hari lagi';
  }

  @override
  String eventGoingCount(int n) {
    return '$n hadir';
  }

  @override
  String get eventYouAreGoing => 'Kamu hadir';

  @override
  String get eventImGoing => 'Saya hadir';

  @override
  String get eventNext => 'Acara berikutnya';

  @override
  String dateHaul(int n) {
    return 'haul ke-$n';
  }

  @override
  String dateBirthday(int n) {
    return 'ulang tahun ke-$n';
  }

  @override
  String get rsvpNone => 'Belum jawab';

  @override
  String get rsvpGoing => 'Hadir';

  @override
  String get rsvpMaybe => 'Mungkin';

  @override
  String get rsvpNo => 'Tidak';

  @override
  String get rsvpQuestion => 'Kamu datang?';

  @override
  String get rsvpPeople => 'Ikut bersamamu, termasuk kamu';

  @override
  String get rsvpFewer => 'Kurangi';

  @override
  String get rsvpMore => 'Tambah';

  @override
  String get eventsTitle => 'Acara keluarga';

  @override
  String get eventCreate => 'Buat acara';

  @override
  String get eventEdit => 'Edit acara';

  @override
  String get eventsFromTree => 'Dari silsilah, 30 hari ke depan';

  @override
  String eventsUpcoming(int n) {
    return 'Mendatang ($n)';
  }

  @override
  String get eventsPast => 'Sudah lewat';

  @override
  String get eventsNoPast => 'Belum ada acara yang lewat.';

  @override
  String get eventsNoMore => 'Tidak ada acara lain yang dijadwalkan.';

  @override
  String get eventsEmptyTitle => 'Belum ada acara';

  @override
  String get eventsEmptyBody =>
      'Buat reuni, halal bihalal, atau liburan bareng. Undangan sampai ke semua anggota pohon ini.';

  @override
  String get eventsEmptyViewer =>
      'Acara yang dibuat keluarga akan muncul di sini.';

  @override
  String get eventAgenda => 'Susunan acara';

  @override
  String get eventNotes => 'Catatan';

  @override
  String get eventShareWa => 'Bagikan undangan ke WhatsApp';

  @override
  String get eventShareFooter =>
      'Konfirmasi kehadiran di aplikasi Bani, tab Acara.';

  @override
  String eventDuesPerHousehold(String amount) {
    return '$amount per KK';
  }

  @override
  String eventForBranch(String name) {
    return 'Untuk cabang $name';
  }

  @override
  String get eventForAll => 'Untuk semua anggota pohon';

  @override
  String get eventDone => 'Sudah selesai';

  @override
  String get eventDeleteTitle => 'Hapus acara ini?';

  @override
  String get eventDeleteBody =>
      'Acara dan semua jawaban kehadiran akan dihapus.';

  @override
  String get eventDeleted => 'Acara dihapus.';

  @override
  String eventFromTime(String time) {
    return 'Mulai $time';
  }

  @override
  String eventStartsAt(String time) {
    return 'Mulai pukul $time';
  }

  @override
  String eventOrganizer(String name) {
    return 'Diatur oleh $name';
  }

  @override
  String eventBranch(String name) {
    return 'Cabang $name';
  }

  @override
  String get eventBranchOther => 'Lainnya';

  @override
  String get eventAttendance => 'Kehadiran per cabang';

  @override
  String get eventDues => 'Iuran';

  @override
  String eventDuesCollected(int n) {
    return 'terkumpul dari $n KK';
  }

  @override
  String eventDuesLeft(int n) {
    return '$n KK lagi';
  }

  @override
  String get eventDuesClaim => 'Saya sudah transfer';

  @override
  String get eventDuesWaiting => 'Menunggu konfirmasi bendahara';

  @override
  String get eventDuesConfirmed => 'Iuranmu sudah dikonfirmasi';

  @override
  String get eventDuesTreasurer => 'Konfirmasi pembayaran';

  @override
  String get eventDuesClaimed => 'Bilang sudah transfer';

  @override
  String get eventDuesNote =>
      'Bendahara mencatat manual. Bani tidak memproses pembayaran.';

  @override
  String get eventFormTitleRequired => 'Isi nama acara dulu.';

  @override
  String get eventCreated =>
      'Acara dibuat. Bagikan undangannya ke WhatsApp keluarga.';

  @override
  String get eventSaved => 'Perubahan disimpan.';

  @override
  String get eventFormType => 'Jenis acara';

  @override
  String get eventFormName => 'Nama acara';

  @override
  String get eventFormNameHint => 'Contoh: Reuni akbar Bani Harun';

  @override
  String get eventFormDate => 'Tanggal dan jam mulai';

  @override
  String get eventFormAddEnd => 'Lebih dari sehari? Tambah tanggal selesai';

  @override
  String eventFormUntil(String date) {
    return 'Sampai $date';
  }

  @override
  String get eventFormPlace => 'Lokasi';

  @override
  String get eventFormPlacePick => 'Pilih lokasi';

  @override
  String get eventFormInvite => 'Siapa yang diundang';

  @override
  String get eventFormInviteAll => 'Semua bani';

  @override
  String get eventFormInviteBranch => 'Cabang tertentu';

  @override
  String get eventFormInviteHint =>
      'Semua anggota pohon tetap bisa melihat acara ini.';

  @override
  String get eventFormDues => 'Iuran per KK';

  @override
  String get eventFormDuesHint => 'Dicatat bendahara, uang ditransfer langsung';

  @override
  String get eventFormAgendaAdd => 'Tambah';

  @override
  String get eventFormAgendaHint => 'Contoh: Foto bersama per cabang';

  @override
  String get eventFormNotesHint => 'Dress code, yang perlu dibawa, info parkir';

  @override
  String get eventFormSubmit => 'Buat acara';

  @override
  String get homeThisWeek => 'Pekan ini';

  @override
  String homeHaulOf(int n, String name) {
    return 'Haul ke-$n $name';
  }

  @override
  String homeBirthdayOf(String name, int n) {
    return '$name ulang tahun ke-$n';
  }

  @override
  String detailBirthdayOn(String day) {
    return 'Ulang tahun $day';
  }

  @override
  String detailHaulOn(String day) {
    return 'Haul setiap $day';
  }

  @override
  String get detailDateInEvents => 'Muncul untuk semua keluarga di tab Acara.';

  @override
  String detailGrandchildCount(int n) {
    return '$n cucu';
  }

  @override
  String focusParentWith(String name) {
    return 'Orang tua, bersama $name';
  }

  @override
  String get treeModeChart => 'Bagan';

  @override
  String get chartZoomIn => 'Perbesar';

  @override
  String get chartZoomOut => 'Perkecil';

  @override
  String get chartFit => 'Muat satu layar';

  @override
  String silsilahUpTo(int n) {
    return 'Sampai generasi $n';
  }

  @override
  String get silsilahTapGeneration => 'Ketuk angka untuk membatasi generasi';

  @override
  String get eventBranchElders => 'Sesepuh';
}
