import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Bani'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @open.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get open;

  /// No description provided for @create.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @later.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get later;

  /// No description provided for @saving.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan...'**
  String get saving;

  /// No description provided for @loadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat'**
  String get loadFailed;

  /// No description provided for @notFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan'**
  String get notFound;

  /// No description provided for @copied.
  ///
  /// In id, this message translates to:
  /// **'Disalin.'**
  String get copied;

  /// No description provided for @generation.
  ///
  /// In id, this message translates to:
  /// **'Generasi {n}'**
  String generation(int n);

  /// No description provided for @membersCount.
  ///
  /// In id, this message translates to:
  /// **'{n} anggota'**
  String membersCount(int n);

  /// No description provided for @generationsCount.
  ///
  /// In id, this message translates to:
  /// **'{n} generasi'**
  String generationsCount(int n);

  /// No description provided for @peopleCount.
  ///
  /// In id, this message translates to:
  /// **'{n} orang'**
  String peopleCount(int n);

  /// No description provided for @childOf.
  ///
  /// In id, this message translates to:
  /// **'anak {name}'**
  String childOf(String name);

  /// No description provided for @someoneElse.
  ///
  /// In id, this message translates to:
  /// **'anggota lain'**
  String get someoneElse;

  /// No description provided for @tabHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get tabHome;

  /// No description provided for @tabTree.
  ///
  /// In id, this message translates to:
  /// **'Pohon'**
  String get tabTree;

  /// No description provided for @tabInvite.
  ///
  /// In id, this message translates to:
  /// **'Undang'**
  String get tabInvite;

  /// No description provided for @tabProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @exitTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari Bani?'**
  String get exitTitle;

  /// No description provided for @exitBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa kembali kapan saja. Data tetap tersimpan.'**
  String get exitBody;

  /// No description provided for @exitConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get exitConfirm;

  /// No description provided for @loginSlide1Title.
  ///
  /// In id, this message translates to:
  /// **'Silsilah bani yang tumbuh ke bawah, enak dibaca di HP.'**
  String get loginSlide1Title;

  /// No description provided for @loginSlide1Body.
  ///
  /// In id, this message translates to:
  /// **'Tiap cabang mengisi keluarganya sendiri, lalu kumpul lagi lewat reuni, halal bihalal, atau liburan bareng.'**
  String get loginSlide1Body;

  /// No description provided for @loginSlide2Title.
  ///
  /// In id, this message translates to:
  /// **'Undang saudara lewat WhatsApp.'**
  String get loginSlide2Title;

  /// No description provided for @loginSlide2Body.
  ///
  /// In id, this message translates to:
  /// **'Kirim kode, saudara masuk dengan Google, lalu mengisi cabangnya sendiri.'**
  String get loginSlide2Body;

  /// No description provided for @loginSlide3Title.
  ///
  /// In id, this message translates to:
  /// **'Kontak dan makam, satu ketukan.'**
  String get loginSlide3Title;

  /// No description provided for @loginSlide3Body.
  ///
  /// In id, this message translates to:
  /// **'Buka WhatsApp, telepon, atau lokasi di Google Maps langsung dari profil anggota.'**
  String get loginSlide3Body;

  /// No description provided for @loginPendingInvite.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk membuka undangan'**
  String get loginPendingInvite;

  /// No description provided for @loginWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get loginWithGoogle;

  /// No description provided for @loginTerms.
  ///
  /// In id, this message translates to:
  /// **'Dengan masuk, kamu menyetujui Ketentuan dan Kebijakan Privasi Bani.'**
  String get loginTerms;

  /// No description provided for @previewChild.
  ///
  /// In id, this message translates to:
  /// **'Anak'**
  String get previewChild;

  /// No description provided for @loginCancelled.
  ///
  /// In id, this message translates to:
  /// **'Login dibatalkan.'**
  String get loginCancelled;

  /// No description provided for @loginNoToken.
  ///
  /// In id, this message translates to:
  /// **'Google tidak mengirim token. Cek konfigurasi Firebase.'**
  String get loginNoToken;

  /// No description provided for @loginFailed.
  ///
  /// In id, this message translates to:
  /// **'Login gagal: {reason}'**
  String loginFailed(String reason);

  /// No description provided for @inviteTitle.
  ///
  /// In id, this message translates to:
  /// **'Undangan'**
  String get inviteTitle;

  /// No description provided for @inviteClaimed.
  ///
  /// In id, this message translates to:
  /// **'Berhasil! Sekarang kamu bisa mengisi cabangmu.'**
  String get inviteClaimed;

  /// No description provided for @inviteCannotOpen.
  ///
  /// In id, this message translates to:
  /// **'Undangan tidak bisa dibuka'**
  String get inviteCannotOpen;

  /// No description provided for @inviteToHome.
  ///
  /// In id, this message translates to:
  /// **'Ke beranda'**
  String get inviteToHome;

  /// No description provided for @inviteNotFound.
  ///
  /// In id, this message translates to:
  /// **'Undangan tidak ditemukan'**
  String get inviteNotFound;

  /// No description provided for @inviteInvalid.
  ///
  /// In id, this message translates to:
  /// **'Undangan tidak berlaku'**
  String get inviteInvalid;

  /// No description provided for @inviteUsed.
  ///
  /// In id, this message translates to:
  /// **'Kode ini sudah dipakai. Minta kode baru ke pengirim.'**
  String get inviteUsed;

  /// No description provided for @inviteExpired.
  ///
  /// In id, this message translates to:
  /// **'Kode ini sudah kedaluwarsa atau dibatalkan. Minta kode baru ke pengirim.'**
  String get inviteExpired;

  /// No description provided for @inviteCanEditSelf.
  ///
  /// In id, this message translates to:
  /// **'Melengkapi data dan foto dirimu'**
  String get inviteCanEditSelf;

  /// No description provided for @inviteCanAddKids.
  ///
  /// In id, this message translates to:
  /// **'Menambah anak dan cucu'**
  String get inviteCanAddKids;

  /// No description provided for @inviteCanAddKidsUntil.
  ///
  /// In id, this message translates to:
  /// **'Menambah anak dan cucu, sampai generasi {n}'**
  String inviteCanAddKidsUntil(int n);

  /// No description provided for @inviteCanManage.
  ///
  /// In id, this message translates to:
  /// **'Mengelola seluruh pohon'**
  String get inviteCanManage;

  /// No description provided for @inviteCanView.
  ///
  /// In id, this message translates to:
  /// **'Melihat seluruh pohon {family}'**
  String inviteCanView(String family);

  /// No description provided for @inviteFrom.
  ///
  /// In id, this message translates to:
  /// **'{name} mengundangmu mengisi cabang di {family}.'**
  String inviteFrom(String name, String family);

  /// No description provided for @inviteIsThisYou.
  ///
  /// In id, this message translates to:
  /// **'Apakah ini kamu?'**
  String get inviteIsThisYou;

  /// No description provided for @inviteAfterClaim.
  ///
  /// In id, this message translates to:
  /// **'Setelah klaim, kamu bisa'**
  String get inviteAfterClaim;

  /// No description provided for @inviteYesMe.
  ///
  /// In id, this message translates to:
  /// **'Ya, ini saya'**
  String get inviteYesMe;

  /// No description provided for @inviteNotMe.
  ///
  /// In id, this message translates to:
  /// **'Bukan saya'**
  String get inviteNotMe;

  /// No description provided for @inviteAlreadyUsed.
  ///
  /// In id, this message translates to:
  /// **'Undangan sudah dipakai atau kedaluwarsa.'**
  String get inviteAlreadyUsed;

  /// No description provided for @inviteAlreadyJoined.
  ///
  /// In id, this message translates to:
  /// **'Akunmu sudah terhubung ke pohon ini.'**
  String get inviteAlreadyJoined;

  /// No description provided for @roleOwner.
  ///
  /// In id, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In id, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleContributor.
  ///
  /// In id, this message translates to:
  /// **'Kontributor'**
  String get roleContributor;

  /// No description provided for @roleViewer.
  ///
  /// In id, this message translates to:
  /// **'Hanya lihat'**
  String get roleViewer;

  /// No description provided for @genderMale.
  ///
  /// In id, this message translates to:
  /// **'Laki-laki'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In id, this message translates to:
  /// **'Perempuan'**
  String get genderFemale;

  /// No description provided for @spouseMarried.
  ///
  /// In id, this message translates to:
  /// **'Menikah'**
  String get spouseMarried;

  /// No description provided for @spouseDivorced.
  ///
  /// In id, this message translates to:
  /// **'Cerai'**
  String get spouseDivorced;

  /// No description provided for @spouseDeceased.
  ///
  /// In id, this message translates to:
  /// **'Wafat'**
  String get spouseDeceased;

  /// No description provided for @alive.
  ///
  /// In id, this message translates to:
  /// **'Hidup'**
  String get alive;

  /// No description provided for @deceased.
  ///
  /// In id, this message translates to:
  /// **'Wafat'**
  String get deceased;

  /// No description provided for @deceasedShort.
  ///
  /// In id, this message translates to:
  /// **'wafat'**
  String get deceasedShort;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Assalamu\'alaikum, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluarga saya'**
  String get homeTitle;

  /// No description provided for @homeSetupFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyiapkan akun'**
  String get homeSetupFailed;

  /// No description provided for @homeTrees.
  ///
  /// In id, this message translates to:
  /// **'Pohon keluarga'**
  String get homeTrees;

  /// No description provided for @homeNewTree.
  ///
  /// In id, this message translates to:
  /// **'Buat pohon baru'**
  String get homeNewTree;

  /// No description provided for @homeHaveCode.
  ///
  /// In id, this message translates to:
  /// **'Punya kode undangan?'**
  String get homeHaveCode;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di Bani'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Diundang keluarga? Pilih \"Punya kode undangan?\" lalu masukkan kodenya. Ingin mencatat silsilah sendiri? Pilih \"Buat pohon baru\".'**
  String get homeWelcomeBody;

  /// No description provided for @enterCodeTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode undangan'**
  String get enterCodeTitle;

  /// No description provided for @enterCodeBody.
  ///
  /// In id, this message translates to:
  /// **'Minta kode 8 huruf dari keluarga yang mengundangmu, atau tempel link-nya.'**
  String get enterCodeBody;

  /// No description provided for @newTreeTitle.
  ///
  /// In id, this message translates to:
  /// **'Pohon baru'**
  String get newTreeTitle;

  /// No description provided for @newTreeName.
  ///
  /// In id, this message translates to:
  /// **'Nama bani, contoh: Bani Harun'**
  String get newTreeName;

  /// No description provided for @newTreeRoot.
  ///
  /// In id, this message translates to:
  /// **'Nama leluhur utama'**
  String get newTreeRoot;

  /// No description provided for @quotaTitle.
  ///
  /// In id, this message translates to:
  /// **'Kuota anggota'**
  String get quotaTitle;

  /// No description provided for @quotaUnlimited.
  ///
  /// In id, this message translates to:
  /// **'/ tanpa batas'**
  String get quotaUnlimited;

  /// No description provided for @quotaAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah kuota'**
  String get quotaAdd;

  /// No description provided for @quotaSuperAdmin.
  ///
  /// In id, this message translates to:
  /// **'Super Admin · semua pohon tanpa batas'**
  String get quotaSuperAdmin;

  /// No description provided for @quotaPremium.
  ///
  /// In id, this message translates to:
  /// **'Premium aktif'**
  String get quotaPremium;

  /// No description provided for @quotaLeft.
  ///
  /// In id, this message translates to:
  /// **'{n} slot tersisa untuk pohon milikmu'**
  String quotaLeft(int n);

  /// No description provided for @treeOnlyOwnBranch.
  ///
  /// In id, this message translates to:
  /// **'Kamu hanya bisa menambah anak di cabangmu sendiri.'**
  String get treeOnlyOwnBranch;

  /// No description provided for @treeEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pohon'**
  String get treeEmptyTitle;

  /// No description provided for @treeEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Buat pohon baru di Beranda atau masukkan kode undangan dari keluargamu.'**
  String get treeEmptyBody;

  /// No description provided for @treeSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari anggota'**
  String get treeSearch;

  /// No description provided for @treeExport.
  ///
  /// In id, this message translates to:
  /// **'Ekspor ke Excel'**
  String get treeExport;

  /// No description provided for @treeRename.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama pohon'**
  String get treeRename;

  /// No description provided for @treeRenameTitle.
  ///
  /// In id, this message translates to:
  /// **'Nama pohon'**
  String get treeRenameTitle;

  /// No description provided for @treeFilterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get treeFilterAll;

  /// No description provided for @treeFilterMine.
  ///
  /// In id, this message translates to:
  /// **'Cabang saya'**
  String get treeFilterMine;

  /// No description provided for @treeGoToMe.
  ///
  /// In id, this message translates to:
  /// **'Ke saya'**
  String get treeGoToMe;

  /// No description provided for @treeAddChild.
  ///
  /// In id, this message translates to:
  /// **'Tambah anak'**
  String get treeAddChild;

  /// No description provided for @treeViewDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail'**
  String get treeViewDetail;

  /// No description provided for @treeEditData.
  ///
  /// In id, this message translates to:
  /// **'Edit data'**
  String get treeEditData;

  /// No description provided for @treeMove.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan ke orang tua lain'**
  String get treeMove;

  /// No description provided for @treeMe.
  ///
  /// In id, this message translates to:
  /// **'Saya'**
  String get treeMe;

  /// No description provided for @searchName.
  ///
  /// In id, this message translates to:
  /// **'Cari nama'**
  String get searchName;

  /// No description provided for @detailNotFound.
  ///
  /// In id, this message translates to:
  /// **'Anggota tidak ditemukan'**
  String get detailNotFound;

  /// No description provided for @detailChildOrder.
  ///
  /// In id, this message translates to:
  /// **'Anak ke-{n} dari {parent}'**
  String detailChildOrder(int n, String parent);

  /// No description provided for @detailChildOf.
  ///
  /// In id, this message translates to:
  /// **'Anak dari {parent}'**
  String detailChildOf(String parent);

  /// No description provided for @detailAliveAge.
  ///
  /// In id, this message translates to:
  /// **'Hidup · {n} tahun'**
  String detailAliveAge(int n);

  /// No description provided for @detailDeceasedAge.
  ///
  /// In id, this message translates to:
  /// **'Wafat · usia {n} tahun'**
  String detailDeceasedAge(int n);

  /// No description provided for @detailLastEdit.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diubah oleh {name} · {date}'**
  String detailLastEdit(String name, String date);

  /// No description provided for @detailChildren.
  ///
  /// In id, this message translates to:
  /// **'Anak ({n})'**
  String detailChildren(int n);

  /// No description provided for @detailNoChildren.
  ///
  /// In id, this message translates to:
  /// **'Belum ada anak yang dicatat.'**
  String get detailNoChildren;

  /// No description provided for @detailDeleteKidsFirst.
  ///
  /// In id, this message translates to:
  /// **'Hapus anak-anaknya dulu sebelum menghapus {name}.'**
  String detailDeleteKidsFirst(String name);

  /// No description provided for @detailDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String detailDeleteTitle(String name);

  /// No description provided for @detailDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Data, foto, dan kontaknya akan dihapus dari pohon.'**
  String get detailDeleteBody;

  /// No description provided for @detailWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp'**
  String get detailWhatsapp;

  /// No description provided for @detailCall.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get detailCall;

  /// No description provided for @detailOpenMaps.
  ///
  /// In id, this message translates to:
  /// **'Buka Maps'**
  String get detailOpenMaps;

  /// No description provided for @detailGrave.
  ///
  /// In id, this message translates to:
  /// **'Makam'**
  String get detailGrave;

  /// No description provided for @detailBorn.
  ///
  /// In id, this message translates to:
  /// **'Lahir'**
  String get detailBorn;

  /// No description provided for @detailDied.
  ///
  /// In id, this message translates to:
  /// **'Wafat'**
  String get detailDied;

  /// No description provided for @detailAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get detailAddress;

  /// No description provided for @detailSpouse.
  ///
  /// In id, this message translates to:
  /// **'Pasangan'**
  String get detailSpouse;

  /// No description provided for @detailGender.
  ///
  /// In id, this message translates to:
  /// **'Jenis kelamin'**
  String get detailGender;

  /// No description provided for @detailOccupation.
  ///
  /// In id, this message translates to:
  /// **'Pekerjaan'**
  String get detailOccupation;

  /// No description provided for @detailNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get detailNotes;

  /// No description provided for @detailOpenInMaps.
  ///
  /// In id, this message translates to:
  /// **'Buka di Maps'**
  String get detailOpenInMaps;

  /// No description provided for @detailContactHidden.
  ///
  /// In id, this message translates to:
  /// **'Kontak belum diisi atau privat'**
  String get detailContactHidden;

  /// No description provided for @detailUnclaimed.
  ///
  /// In id, this message translates to:
  /// **'Profil belum diklaim'**
  String get detailUnclaimed;

  /// No description provided for @detailUnclaimedBody.
  ///
  /// In id, this message translates to:
  /// **'Undang {name} atau anaknya untuk mengisi cabang ini sendiri.'**
  String detailUnclaimedBody(String name);

  /// No description provided for @detailInvite.
  ///
  /// In id, this message translates to:
  /// **'Undang'**
  String get detailInvite;

  /// No description provided for @waGreeting.
  ///
  /// In id, this message translates to:
  /// **'Assalamu\'alaikum {name}'**
  String waGreeting(String name);

  /// No description provided for @formStepIdentity.
  ///
  /// In id, this message translates to:
  /// **'Identitas'**
  String get formStepIdentity;

  /// No description provided for @formStepBirth.
  ///
  /// In id, this message translates to:
  /// **'Lahir'**
  String get formStepBirth;

  /// No description provided for @formStepSpouse.
  ///
  /// In id, this message translates to:
  /// **'Pasangan'**
  String get formStepSpouse;

  /// No description provided for @formStepContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak'**
  String get formStepContact;

  /// No description provided for @formNextBirth.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: Lahir & wafat'**
  String get formNextBirth;

  /// No description provided for @formNextSpouse.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: Pasangan'**
  String get formNextSpouse;

  /// No description provided for @formNextContact.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: Kontak'**
  String get formNextContact;

  /// No description provided for @formEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit data'**
  String get formEditTitle;

  /// No description provided for @formAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah anak'**
  String get formAddTitle;

  /// No description provided for @formChildOf.
  ///
  /// In id, this message translates to:
  /// **'Anak dari {parent} · Generasi {n}'**
  String formChildOf(String parent, int n);

  /// No description provided for @formRoot.
  ///
  /// In id, this message translates to:
  /// **'Leluhur utama · Generasi {n}'**
  String formRoot(int n);

  /// No description provided for @formChangedBy.
  ///
  /// In id, this message translates to:
  /// **'Baru saja diubah oleh {name}.'**
  String formChangedBy(String name);

  /// No description provided for @formReload.
  ///
  /// In id, this message translates to:
  /// **'Muat'**
  String get formReload;

  /// No description provided for @formQuotaUse.
  ///
  /// In id, this message translates to:
  /// **'Memakai 1 dari {n} slot anggota yang tersisa'**
  String formQuotaUse(int n);

  /// No description provided for @formNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap wajib diisi.'**
  String get formNameRequired;

  /// No description provided for @formSaveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get formSaveChanges;

  /// No description provided for @formSaveMember.
  ///
  /// In id, this message translates to:
  /// **'Simpan anggota'**
  String get formSaveMember;

  /// No description provided for @formAddPhoto.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get formAddPhoto;

  /// No description provided for @formChangePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get formChangePhoto;

  /// No description provided for @formPhotoHint.
  ///
  /// In id, this message translates to:
  /// **'Dari kamera atau galeri. Dikompres otomatis supaya ringan.'**
  String get formPhotoHint;

  /// No description provided for @formFullName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get formFullName;

  /// No description provided for @formFullNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Hasan Basri'**
  String get formFullNameHint;

  /// No description provided for @formNickname.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan'**
  String get formNickname;

  /// No description provided for @formNicknameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Pak Hasan'**
  String get formNicknameHint;

  /// No description provided for @formGender.
  ///
  /// In id, this message translates to:
  /// **'Jenis kelamin'**
  String get formGender;

  /// No description provided for @formBirthOrder.
  ///
  /// In id, this message translates to:
  /// **'Anak ke-'**
  String get formBirthOrder;

  /// No description provided for @formOccupation.
  ///
  /// In id, this message translates to:
  /// **'Pekerjaan'**
  String get formOccupation;

  /// No description provided for @formOccupationHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Guru'**
  String get formOccupationHint;

  /// No description provided for @formCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get formCamera;

  /// No description provided for @formGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get formGallery;

  /// No description provided for @formRemovePhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get formRemovePhoto;

  /// No description provided for @formBirthPlace.
  ///
  /// In id, this message translates to:
  /// **'Tempat lahir'**
  String get formBirthPlace;

  /// No description provided for @formBirthPlaceHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Kediri'**
  String get formBirthPlaceHint;

  /// No description provided for @formBirthDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir'**
  String get formBirthDate;

  /// No description provided for @formYearOnlyKnown.
  ///
  /// In id, this message translates to:
  /// **'Hanya tahun yang diketahui'**
  String get formYearOnlyKnown;

  /// No description provided for @formStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get formStatus;

  /// No description provided for @formDeathDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal wafat'**
  String get formDeathDate;

  /// No description provided for @formYearOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya tahun'**
  String get formYearOnly;

  /// No description provided for @formGrave.
  ///
  /// In id, this message translates to:
  /// **'Lokasi makam'**
  String get formGrave;

  /// No description provided for @formGravePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih lokasi makam di peta'**
  String get formGravePick;

  /// No description provided for @formGraveHint.
  ///
  /// In id, this message translates to:
  /// **'Lokasi makam membantu keluarga saat ziarah dan haul.'**
  String get formGraveHint;

  /// No description provided for @formSpouseIntro.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan istri atau suami. Bisa lebih dari satu, misalnya jika menikah lagi.'**
  String get formSpouseIntro;

  /// No description provided for @formSpouseN.
  ///
  /// In id, this message translates to:
  /// **'Pasangan {n}'**
  String formSpouseN(int n);

  /// No description provided for @formName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get formName;

  /// No description provided for @formSpouseNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap pasangan'**
  String get formSpouseNameHint;

  /// No description provided for @formAddSpouse.
  ///
  /// In id, this message translates to:
  /// **'Tambah pasangan'**
  String get formAddSpouse;

  /// No description provided for @formWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp'**
  String get formWhatsapp;

  /// No description provided for @formHomeAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat rumah'**
  String get formHomeAddress;

  /// No description provided for @formAddressPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih alamat di peta'**
  String get formAddressPick;

  /// No description provided for @formAddressDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail: RT/RW, patokan'**
  String get formAddressDetail;

  /// No description provided for @formWhoSeesContact.
  ///
  /// In id, this message translates to:
  /// **'Siapa yang bisa melihat kontak?'**
  String get formWhoSeesContact;

  /// No description provided for @formVisibilityFamily.
  ///
  /// In id, this message translates to:
  /// **'Semua anggota pohon'**
  String get formVisibilityFamily;

  /// No description provided for @formVisibilityFamilyHint.
  ///
  /// In id, this message translates to:
  /// **'Keluarga bisa langsung WhatsApp'**
  String get formVisibilityFamilyHint;

  /// No description provided for @formVisibilityAdmins.
  ///
  /// In id, this message translates to:
  /// **'Hanya Owner & Admin'**
  String get formVisibilityAdmins;

  /// No description provided for @formVisibilityAdminsHint.
  ///
  /// In id, this message translates to:
  /// **'Lebih privat'**
  String get formVisibilityAdminsHint;

  /// No description provided for @formNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get formNotes;

  /// No description provided for @formNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Kisah singkat, pesan, atau kenangan'**
  String get formNotesHint;

  /// No description provided for @formConflictTitle.
  ///
  /// In id, this message translates to:
  /// **'Ada perubahan baru'**
  String get formConflictTitle;

  /// No description provided for @formConflictBody.
  ///
  /// In id, this message translates to:
  /// **'{message}\n\nMuat data terbaru (perubahanmu dibuang), atau tetap simpan hanya bagian yang kamu ubah di atas data terbaru?'**
  String formConflictBody(String message);

  /// No description provided for @formLoadLatest.
  ///
  /// In id, this message translates to:
  /// **'Muat terbaru'**
  String get formLoadLatest;

  /// No description provided for @formKeepMine.
  ///
  /// In id, this message translates to:
  /// **'Tetap simpan'**
  String get formKeepMine;

  /// No description provided for @formPickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get formPickDate;

  /// No description provided for @formTapToOpenMap.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk membuka peta'**
  String get formTapToOpenMap;

  /// No description provided for @formChangeOnMap.
  ///
  /// In id, this message translates to:
  /// **'Ubah di peta'**
  String get formChangeOnMap;

  /// No description provided for @mapSelected.
  ///
  /// In id, this message translates to:
  /// **'Lokasi terpilih'**
  String get mapSelected;

  /// No description provided for @mapNotFound.
  ///
  /// In id, this message translates to:
  /// **'Alamat tidak ditemukan.'**
  String get mapNotFound;

  /// No description provided for @mapPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak.'**
  String get mapPermissionDenied;

  /// No description provided for @mapNoGps.
  ///
  /// In id, this message translates to:
  /// **'Lokasi tidak bisa didapat. Pastikan GPS aktif.'**
  String get mapNoGps;

  /// No description provided for @mapSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari alamat atau tempat'**
  String get mapSearch;

  /// No description provided for @mapMyLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi saya'**
  String get mapMyLocation;

  /// No description provided for @mapResolving.
  ///
  /// In id, this message translates to:
  /// **'Mencari alamat...'**
  String get mapResolving;

  /// No description provided for @mapDrag.
  ///
  /// In id, this message translates to:
  /// **'Geser peta'**
  String get mapDrag;

  /// No description provided for @mapDetailHint.
  ///
  /// In id, this message translates to:
  /// **'Detail: RT/RW, patokan, warna pagar'**
  String get mapDetailHint;

  /// No description provided for @mapUse.
  ///
  /// In id, this message translates to:
  /// **'Pakai lokasi ini'**
  String get mapUse;

  /// No description provided for @mapTitleDefault.
  ///
  /// In id, this message translates to:
  /// **'Pilih lokasi'**
  String get mapTitleDefault;

  /// No description provided for @invPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Undang keluarga'**
  String get invPageTitle;

  /// No description provided for @invPageBody.
  ///
  /// In id, this message translates to:
  /// **'Kontributor mengisi cabangnya sendiri, sampai {n} generasi di bawahnya.'**
  String invPageBody(int n);

  /// No description provided for @invOnlyManagers.
  ///
  /// In id, this message translates to:
  /// **'Hanya Owner atau Admin yang bisa mengundang. Minta mereka mengirim kode untukmu atau saudaramu.'**
  String get invOnlyManagers;

  /// No description provided for @invForWho.
  ///
  /// In id, this message translates to:
  /// **'Untuk siapa?'**
  String get invForWho;

  /// No description provided for @invPickMember.
  ///
  /// In id, this message translates to:
  /// **'Pilih anggota'**
  String get invPickMember;

  /// No description provided for @invPickMemberHint.
  ///
  /// In id, this message translates to:
  /// **'Orang yang akan mengisi cabangnya'**
  String get invPickMemberHint;

  /// No description provided for @invClaimed.
  ///
  /// In id, this message translates to:
  /// **'sudah diklaim'**
  String get invClaimed;

  /// No description provided for @invUnclaimed.
  ///
  /// In id, this message translates to:
  /// **'belum diklaim'**
  String get invUnclaimed;

  /// No description provided for @invContributorDepth.
  ///
  /// In id, this message translates to:
  /// **'Bisa mengisi {n} generasi di bawahnya · kode berlaku {days} hari'**
  String invContributorDepth(int n, int days);

  /// No description provided for @invContributorUntil.
  ///
  /// In id, this message translates to:
  /// **'Bisa mengisi sampai generasi {n} · kode berlaku {days} hari'**
  String invContributorUntil(int n, int days);

  /// No description provided for @invAdminHint.
  ///
  /// In id, this message translates to:
  /// **'Admin bisa mengedit seluruh pohon dan mengundang'**
  String get invAdminHint;

  /// No description provided for @invViewerHint.
  ///
  /// In id, this message translates to:
  /// **'Hanya bisa melihat pohon'**
  String get invViewerHint;

  /// No description provided for @invCreating.
  ///
  /// In id, this message translates to:
  /// **'Membuat kode...'**
  String get invCreating;

  /// No description provided for @invCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat kode undangan'**
  String get invCreate;

  /// No description provided for @invMessage.
  ///
  /// In id, this message translates to:
  /// **'Assalamu\'alaikum {name}, ayo isi silsilah {family} di aplikasi Bani.\n\n1. Buka aplikasi Bani, masuk dengan Google\n2. Di Beranda, pilih \"Punya kode undangan?\"\n3. Masukkan kode: *{code}*\n\nKode berlaku {days} hari.\n{link}'**
  String invMessage(
    String name,
    String family,
    String code,
    int days,
    String link,
  );

  /// No description provided for @invCodeFor.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan untuk'**
  String get invCodeFor;

  /// No description provided for @invCodeMeta.
  ///
  /// In id, this message translates to:
  /// **'{role} · berlaku {days} hari · sekali pakai'**
  String invCodeMeta(String role, int days);

  /// No description provided for @invSendWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'Kirim lewat WhatsApp'**
  String get invSendWhatsapp;

  /// No description provided for @invCopyCode.
  ///
  /// In id, this message translates to:
  /// **'Salin kode'**
  String get invCopyCode;

  /// No description provided for @invCodeCopied.
  ///
  /// In id, this message translates to:
  /// **'Kode disalin.'**
  String get invCodeCopied;

  /// No description provided for @invSent.
  ///
  /// In id, this message translates to:
  /// **'Undangan terkirim'**
  String get invSent;

  /// No description provided for @invSentMeta.
  ///
  /// In id, this message translates to:
  /// **'{role} · kode {code}'**
  String invSentMeta(String role, String code);

  /// No description provided for @invDaysLeft.
  ///
  /// In id, this message translates to:
  /// **'{n} hari lagi'**
  String invDaysLeft(int n);

  /// No description provided for @invCancel.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get invCancel;

  /// No description provided for @invActive.
  ///
  /// In id, this message translates to:
  /// **'Akses aktif'**
  String get invActive;

  /// No description provided for @invNoneYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada yang diundang.'**
  String get invNoneYet;

  /// No description provided for @invMember.
  ///
  /// In id, this message translates to:
  /// **'Anggota'**
  String get invMember;

  /// No description provided for @invUntilGen.
  ///
  /// In id, this message translates to:
  /// **'{role} · s/d generasi {n}'**
  String invUntilGen(String role, int n);

  /// No description provided for @invStatusActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get invStatusActive;

  /// No description provided for @invRevoke.
  ///
  /// In id, this message translates to:
  /// **'Cabut akses'**
  String get invRevoke;

  /// No description provided for @profileSuperAdmin.
  ///
  /// In id, this message translates to:
  /// **'Super Admin'**
  String get profileSuperAdmin;

  /// No description provided for @profilePremium.
  ///
  /// In id, this message translates to:
  /// **'Premium'**
  String get profilePremium;

  /// No description provided for @profileFree.
  ///
  /// In id, this message translates to:
  /// **'Paket Gratis'**
  String get profileFree;

  /// No description provided for @profileUnlimited.
  ///
  /// In id, this message translates to:
  /// **'anggota · tanpa batas'**
  String get profileUnlimited;

  /// No description provided for @profileOfLimit.
  ///
  /// In id, this message translates to:
  /// **'dari {n} anggota'**
  String profileOfLimit(int n);

  /// No description provided for @profileQuotaHint.
  ///
  /// In id, this message translates to:
  /// **'Kuota dipakai bersama oleh pohon milikmu, termasuk isian kontributor.'**
  String get profileQuotaHint;

  /// No description provided for @profileSettings.
  ///
  /// In id, this message translates to:
  /// **'PENGATURAN'**
  String get profileSettings;

  /// No description provided for @profileLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get profileLanguage;

  /// No description provided for @profileContactPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi kontak'**
  String get profileContactPrivacy;

  /// No description provided for @profileContactPrivacyValue.
  ///
  /// In id, this message translates to:
  /// **'Diatur per anggota'**
  String get profileContactPrivacyValue;

  /// No description provided for @profileSuperAdminSection.
  ///
  /// In id, this message translates to:
  /// **'SUPER ADMIN'**
  String get profileSuperAdminSection;

  /// No description provided for @profileImport.
  ///
  /// In id, this message translates to:
  /// **'Impor data Bani Mungin'**
  String get profileImport;

  /// No description provided for @profileFeedbackInbox.
  ///
  /// In id, this message translates to:
  /// **'Saran masuk'**
  String get profileFeedbackInbox;

  /// No description provided for @profileOther.
  ///
  /// In id, this message translates to:
  /// **'LAINNYA'**
  String get profileOther;

  /// No description provided for @profileSendFeedback.
  ///
  /// In id, this message translates to:
  /// **'Kirim saran'**
  String get profileSendFeedback;

  /// No description provided for @profileHelp.
  ///
  /// In id, this message translates to:
  /// **'Bantuan via WhatsApp'**
  String get profileHelp;

  /// No description provided for @profileHelpMessage.
  ///
  /// In id, this message translates to:
  /// **'Halo admin Bani, saya butuh bantuan.'**
  String get profileHelpMessage;

  /// No description provided for @profileLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get profileLogout;

  /// No description provided for @profileVersion.
  ///
  /// In id, this message translates to:
  /// **'Bani versi {v}'**
  String profileVersion(String v);

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @importReadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca data'**
  String get importReadFailed;

  /// No description provided for @importTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Bani Mungin'**
  String get importTitle;

  /// No description provided for @importFound.
  ///
  /// In id, this message translates to:
  /// **'{n} orang ditemukan'**
  String importFound(int n);

  /// No description provided for @importPerGen.
  ///
  /// In id, this message translates to:
  /// **'Generasi {g}: {n} orang'**
  String importPerGen(int g, int n);

  /// No description provided for @importChildrenOf.
  ///
  /// In id, this message translates to:
  /// **'Anak dari {name}:'**
  String importChildrenOf(String name);

  /// No description provided for @importKidCount.
  ///
  /// In id, this message translates to:
  /// **'{name} ({n} anak)'**
  String importKidCount(String name, int n);

  /// No description provided for @importAlready.
  ///
  /// In id, this message translates to:
  /// **'Data ini sudah pernah diimpor.'**
  String get importAlready;

  /// No description provided for @importWillCreate.
  ///
  /// In id, this message translates to:
  /// **'Pohon baru \"Bani Mungin\" akan dibuat dengan kamu sebagai Owner. Data lama tidak diubah.'**
  String get importWillCreate;

  /// No description provided for @importDo.
  ///
  /// In id, this message translates to:
  /// **'Impor'**
  String get importDo;

  /// No description provided for @importDone.
  ///
  /// In id, this message translates to:
  /// **'{n} anggota berhasil diimpor.'**
  String importDone(int n);

  /// No description provided for @importEmpty.
  ///
  /// In id, this message translates to:
  /// **'Collection \"mungin\" kosong atau tidak bisa dibaca.'**
  String get importEmpty;

  /// No description provided for @importNoName.
  ///
  /// In id, this message translates to:
  /// **'Tanpa nama'**
  String get importNoName;

  /// No description provided for @limitBranchTitle.
  ///
  /// In id, this message translates to:
  /// **'Cabang ini sudah sampai batas'**
  String get limitBranchTitle;

  /// No description provided for @limitMemberTitle.
  ///
  /// In id, this message translates to:
  /// **'Kuota anggota sudah penuh'**
  String get limitMemberTitle;

  /// No description provided for @limitBranchBody.
  ///
  /// In id, this message translates to:
  /// **'Cabang {name} gratis sampai generasi {n}. Pilih paket untuk melanjutkan, lalu bayar lewat admin.'**
  String limitBranchBody(String name, int n);

  /// No description provided for @limitMemberBody.
  ///
  /// In id, this message translates to:
  /// **'Pohon {family} sudah memakai {n} slot anggota. Tambah kuota untuk melanjutkan.'**
  String limitMemberBody(String family, int n);

  /// No description provided for @limitWaMessage.
  ///
  /// In id, this message translates to:
  /// **'Halo admin Bani, saya ingin {package}.\nPohon: {family} ({familyId})\nAkun: {email} ({uid})'**
  String limitWaMessage(
    String package,
    String family,
    String familyId,
    String email,
    String uid,
  );

  /// No description provided for @limitAddQuota.
  ///
  /// In id, this message translates to:
  /// **'menambah kuota'**
  String get limitAddQuota;

  /// No description provided for @limitNoAdminWa.
  ///
  /// In id, this message translates to:
  /// **'Nomor WhatsApp admin belum diatur di config/app.'**
  String get limitNoAdminWa;

  /// No description provided for @limitPickPackage.
  ///
  /// In id, this message translates to:
  /// **'Pilih paket'**
  String get limitPickPackage;

  /// No description provided for @limitPay.
  ///
  /// In id, this message translates to:
  /// **'Bayar {price} via WhatsApp'**
  String limitPay(String price);

  /// No description provided for @limitContactAdmin.
  ///
  /// In id, this message translates to:
  /// **'Hubungi admin via WhatsApp'**
  String get limitContactAdmin;

  /// No description provided for @limitAskOwner.
  ///
  /// In id, this message translates to:
  /// **'Minta Owner saja'**
  String get limitAskOwner;

  /// No description provided for @limitAfterTransfer.
  ///
  /// In id, this message translates to:
  /// **'Setelah transfer, admin mengonfirmasi dan kuota terbuka otomatis.'**
  String get limitAfterTransfer;

  /// No description provided for @limitGen.
  ///
  /// In id, this message translates to:
  /// **'Gen {n}'**
  String limitGen(int n);

  /// No description provided for @pkgBranchName.
  ///
  /// In id, this message translates to:
  /// **'Buka Cabang'**
  String get pkgBranchName;

  /// No description provided for @pkgBranchDesc.
  ///
  /// In id, this message translates to:
  /// **'+2 generasi untuk satu cabang'**
  String get pkgBranchDesc;

  /// No description provided for @pkgMembersName.
  ///
  /// In id, this message translates to:
  /// **'Tambah 50 anggota'**
  String get pkgMembersName;

  /// No description provided for @pkgMembersDesc.
  ///
  /// In id, this message translates to:
  /// **'+50 anggota & +10 foto album'**
  String get pkgMembersDesc;

  /// No description provided for @pkgPremiumName.
  ///
  /// In id, this message translates to:
  /// **'Premium Keluarga'**
  String get pkgPremiumName;

  /// No description provided for @pkgPremiumDesc.
  ///
  /// In id, this message translates to:
  /// **'Anggota tanpa batas & 200 foto album'**
  String get pkgPremiumDesc;

  /// No description provided for @pkgOnce.
  ///
  /// In id, this message translates to:
  /// **'sekali bayar'**
  String get pkgOnce;

  /// No description provided for @pkgYearly.
  ///
  /// In id, this message translates to:
  /// **'per tahun'**
  String get pkgYearly;

  /// No description provided for @pkgSave.
  ///
  /// In id, this message translates to:
  /// **'Hemat'**
  String get pkgSave;

  /// No description provided for @moveRootNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Leluhur utama tidak bisa dipindah.'**
  String get moveRootNotAllowed;

  /// No description provided for @moveIntoOwnSubtree.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa dipindah ke bawah keturunannya sendiri.'**
  String get moveIntoOwnSubtree;

  /// No description provided for @moveConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan anggota?'**
  String get moveConfirmTitle;

  /// No description provided for @moveConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{name} akan dipindah menjadi anak dari {parent} (generasi {n}).'**
  String moveConfirmBody(String name, String parent, int n);

  /// No description provided for @moveConfirmBodyWithKids.
  ///
  /// In id, this message translates to:
  /// **'{name} beserta {kids} keturunannya akan dipindah menjadi anak dari {parent} (generasi {n}).'**
  String moveConfirmBodyWithKids(String name, int kids, String parent, int n);

  /// No description provided for @moveDo.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan'**
  String get moveDo;

  /// No description provided for @moveDone.
  ///
  /// In id, this message translates to:
  /// **'{name} sekarang anak dari {parent}.'**
  String moveDone(String name, String parent);

  /// No description provided for @movePickTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan {name}'**
  String movePickTitle(String name);

  /// No description provided for @movePickHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih orang tua yang benar.'**
  String get movePickHint;

  /// No description provided for @errPermission.
  ///
  /// In id, this message translates to:
  /// **'Ditolak server [permission-denied]. Cek kuota, cabang, atau versi aplikasi.'**
  String get errPermission;

  /// No description provided for @errOffline.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi. Perubahan akan dikirim saat online.'**
  String get errOffline;

  /// No description provided for @errNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get errNotFound;

  /// No description provided for @errGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan ({code}).'**
  String errGeneric(String code);

  /// No description provided for @errEditDenied.
  ///
  /// In id, this message translates to:
  /// **'Perubahan ditolak server [edit/permission-denied]. Pastikan Bani versi terbaru (lihat Profil) dan kamu Admin atau Kontributor cabang ini.'**
  String get errEditDenied;

  /// No description provided for @errConflict.
  ///
  /// In id, this message translates to:
  /// **'Data ini baru saja diubah oleh {name}.'**
  String errConflict(String name);

  /// No description provided for @xlsGeneration.
  ///
  /// In id, this message translates to:
  /// **'Generasi'**
  String get xlsGeneration;

  /// No description provided for @xlsFullName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get xlsFullName;

  /// No description provided for @xlsNickname.
  ///
  /// In id, this message translates to:
  /// **'Panggilan'**
  String get xlsNickname;

  /// No description provided for @xlsGender.
  ///
  /// In id, this message translates to:
  /// **'Jenis kelamin'**
  String get xlsGender;

  /// No description provided for @xlsBirthOrder.
  ///
  /// In id, this message translates to:
  /// **'Anak ke-'**
  String get xlsBirthOrder;

  /// No description provided for @xlsParent.
  ///
  /// In id, this message translates to:
  /// **'Orang tua'**
  String get xlsParent;

  /// No description provided for @xlsBirthPlace.
  ///
  /// In id, this message translates to:
  /// **'Tempat lahir'**
  String get xlsBirthPlace;

  /// No description provided for @xlsBirthDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir'**
  String get xlsBirthDate;

  /// No description provided for @xlsStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get xlsStatus;

  /// No description provided for @xlsDeathDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal wafat'**
  String get xlsDeathDate;

  /// No description provided for @xlsSpouse.
  ///
  /// In id, this message translates to:
  /// **'Pasangan'**
  String get xlsSpouse;

  /// No description provided for @xlsOccupation.
  ///
  /// In id, this message translates to:
  /// **'Pekerjaan'**
  String get xlsOccupation;

  /// No description provided for @xlsShareText.
  ///
  /// In id, this message translates to:
  /// **'Silsilah {family}'**
  String xlsShareText(String family);

  /// No description provided for @fbTitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim saran'**
  String get fbTitle;

  /// No description provided for @fbBody.
  ///
  /// In id, this message translates to:
  /// **'Ada ide fitur, keluhan, atau data yang salah? Tulis di sini, langsung sampai ke pengembang.'**
  String get fbBody;

  /// No description provided for @fbTypeIdea.
  ///
  /// In id, this message translates to:
  /// **'Ide fitur'**
  String get fbTypeIdea;

  /// No description provided for @fbTypeBug.
  ///
  /// In id, this message translates to:
  /// **'Ada masalah'**
  String get fbTypeBug;

  /// No description provided for @fbTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get fbTypeOther;

  /// No description provided for @fbHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis saranmu...'**
  String get fbHint;

  /// No description provided for @fbSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get fbSend;

  /// No description provided for @fbTooShort.
  ///
  /// In id, this message translates to:
  /// **'Tulis minimal 5 huruf.'**
  String get fbTooShort;

  /// No description provided for @fbThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih! Saranmu sudah terkirim.'**
  String get fbThanks;

  /// No description provided for @fbInboxTitle.
  ///
  /// In id, this message translates to:
  /// **'Saran masuk'**
  String get fbInboxTitle;

  /// No description provided for @fbInboxEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada saran.'**
  String get fbInboxEmpty;

  /// No description provided for @fbMarkDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai selesai'**
  String get fbMarkDone;

  /// No description provided for @fbDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get fbDone;

  /// No description provided for @fbNew.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get fbNew;

  /// No description provided for @treeRefresh.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang data'**
  String get treeRefresh;

  /// No description provided for @treeRefreshed.
  ///
  /// In id, this message translates to:
  /// **'Data sudah diperbarui.'**
  String get treeRefreshed;

  /// No description provided for @albumTitle.
  ///
  /// In id, this message translates to:
  /// **'Album kenangan ({n})'**
  String albumTitle(int n);

  /// No description provided for @albumEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto lama. Tambahkan foto kenangan supaya anak cucu bisa ikut melihat.'**
  String get albumEmpty;

  /// No description provided for @albumAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get albumAdd;

  /// No description provided for @albumUploading.
  ///
  /// In id, this message translates to:
  /// **'Mengunggah {done}/{total}...'**
  String albumUploading(int done, int total);

  /// No description provided for @albumUploaded.
  ///
  /// In id, this message translates to:
  /// **'{n} foto ditambahkan.'**
  String albumUploaded(int n);

  /// No description provided for @albumCaptionTitle.
  ///
  /// In id, this message translates to:
  /// **'Keterangan foto'**
  String get albumCaptionTitle;

  /// No description provided for @albumCaptionHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Lebaran di rumah kakek'**
  String get albumCaptionHint;

  /// No description provided for @albumYearHint.
  ///
  /// In id, this message translates to:
  /// **'Tahun (opsional)'**
  String get albumYearHint;

  /// No description provided for @albumDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get albumDelete;

  /// No description provided for @albumDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto ini dari album?'**
  String get albumDeleteConfirm;

  /// No description provided for @albumBy.
  ///
  /// In id, this message translates to:
  /// **'Diunggah oleh {name}'**
  String albumBy(String name);

  /// No description provided for @albumQuota.
  ///
  /// In id, this message translates to:
  /// **'{used}/{limit} foto di pohon ini'**
  String albumQuota(int used, int limit);

  /// No description provided for @albumLimitTitle.
  ///
  /// In id, this message translates to:
  /// **'Kuota album penuh'**
  String get albumLimitTitle;

  /// No description provided for @albumLimitBody.
  ///
  /// In id, this message translates to:
  /// **'Pohon {family} sudah memakai {n} foto album. Tambah kuota untuk mengunggah lagi.'**
  String albumLimitBody(String family, int n);

  /// No description provided for @albumEditCaption.
  ///
  /// In id, this message translates to:
  /// **'Ubah keterangan'**
  String get albumEditCaption;

  /// No description provided for @memberHasAlbum.
  ///
  /// In id, this message translates to:
  /// **'Hapus dulu foto album {name} sebelum menghapus anggota ini.'**
  String memberHasAlbum(String name);

  /// No description provided for @pkgFamilyName.
  ///
  /// In id, this message translates to:
  /// **'Keluarga'**
  String get pkgFamilyName;

  /// No description provided for @pkgFamilyDesc.
  ///
  /// In id, this message translates to:
  /// **'Anggota & cabang tanpa batas · 60 foto'**
  String get pkgFamilyDesc;

  /// No description provided for @pkgBigFamilyName.
  ///
  /// In id, this message translates to:
  /// **'Keluarga Besar'**
  String get pkgBigFamilyName;

  /// No description provided for @pkgBigFamilyDesc.
  ///
  /// In id, this message translates to:
  /// **'2 pohon · tanpa batas · 150 foto per pohon'**
  String get pkgBigFamilyDesc;

  /// No description provided for @pkgPhotosName.
  ///
  /// In id, this message translates to:
  /// **'Paket Foto +30'**
  String get pkgPhotosName;

  /// No description provided for @pkgPhotosDesc.
  ///
  /// In id, this message translates to:
  /// **'+30 foto album untuk pohonmu'**
  String get pkgPhotosDesc;

  /// No description provided for @planFree.
  ///
  /// In id, this message translates to:
  /// **'Paket Gratis'**
  String get planFree;

  /// No description provided for @planFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluarga'**
  String get planFamily;

  /// No description provided for @planBigFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluarga Besar'**
  String get planBigFamily;

  /// No description provided for @treeLimitTitle.
  ///
  /// In id, this message translates to:
  /// **'Pohon kedua butuh Keluarga Besar'**
  String get treeLimitTitle;

  /// No description provided for @treeLimitBody.
  ///
  /// In id, this message translates to:
  /// **'Paket Keluarga Besar bisa punya 2 pohon, misalnya keluarga ayah dan ibu, atau keluargamu dan keluarga pasangan.'**
  String get treeLimitBody;

  /// No description provided for @deviceUsed.
  ///
  /// In id, this message translates to:
  /// **'HP ini sudah dipakai membuat pohon gratis dengan akun lain. Masuk dengan akun itu, atau pilih paket berbayar.'**
  String get deviceUsed;

  /// No description provided for @albumNeedMembers.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan minimal {n} anggota dulu sebelum mengunggah foto album.'**
  String albumNeedMembers(int n);

  /// No description provided for @albumDailyLimit.
  ///
  /// In id, this message translates to:
  /// **'Batas upload hari ini sudah tercapai ({n} foto). Coba lagi besok.'**
  String albumDailyLimit(int n);

  /// No description provided for @tabEvents.
  ///
  /// In id, this message translates to:
  /// **'Acara'**
  String get tabEvents;

  /// No description provided for @treeFilterAllBranches.
  ///
  /// In id, this message translates to:
  /// **'Semua cabang'**
  String get treeFilterAllBranches;

  /// No description provided for @treeModeList.
  ///
  /// In id, this message translates to:
  /// **'Silsilah'**
  String get treeModeList;

  /// No description provided for @treeModeFocus.
  ///
  /// In id, this message translates to:
  /// **'Fokus'**
  String get treeModeFocus;

  /// No description provided for @treeShowInFocus.
  ///
  /// In id, this message translates to:
  /// **'Lihat dalam mode Fokus'**
  String get treeShowInFocus;

  /// No description provided for @silsilahMyGeneration.
  ///
  /// In id, this message translates to:
  /// **'Generasi kamu: {n}'**
  String silsilahMyGeneration(int n);

  /// No description provided for @silsilahThisIsYou.
  ///
  /// In id, this message translates to:
  /// **'ini kamu'**
  String get silsilahThisIsYou;

  /// No description provided for @silsilahCollapse.
  ///
  /// In id, this message translates to:
  /// **'Lipat cabang'**
  String get silsilahCollapse;

  /// No description provided for @silsilahExpand.
  ///
  /// In id, this message translates to:
  /// **'Buka {n} keturunan'**
  String silsilahExpand(int n);

  /// No description provided for @silsilahExpandAll.
  ///
  /// In id, this message translates to:
  /// **'Buka semua cabang'**
  String get silsilahExpandAll;

  /// No description provided for @silsilahCollapseAll.
  ///
  /// In id, this message translates to:
  /// **'Lipat semua cabang'**
  String get silsilahCollapseAll;

  /// No description provided for @focusParent.
  ///
  /// In id, this message translates to:
  /// **'Orang tua'**
  String get focusParent;

  /// No description provided for @focusSibling.
  ///
  /// In id, this message translates to:
  /// **'Saudara {pos} dari {total}'**
  String focusSibling(int pos, int total);

  /// No description provided for @focusTapHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk pindah fokus'**
  String get focusTapHint;

  /// No description provided for @focusChildCount.
  ///
  /// In id, this message translates to:
  /// **'{n} anak'**
  String focusChildCount(int n);

  /// No description provided for @focusBorn.
  ///
  /// In id, this message translates to:
  /// **'Lahir {year}'**
  String focusBorn(int year);

  /// No description provided for @focusChildOrder.
  ///
  /// In id, this message translates to:
  /// **'anak ke-{n} dari {total}'**
  String focusChildOrder(int n, int total);

  /// No description provided for @focusSpouse.
  ///
  /// In id, this message translates to:
  /// **'Pasangan: {name}'**
  String focusSpouse(String name);

  /// No description provided for @focusProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get focusProfile;

  /// No description provided for @eventTypeReunion.
  ///
  /// In id, this message translates to:
  /// **'Reuni'**
  String get eventTypeReunion;

  /// No description provided for @eventTypeHalalBihalal.
  ///
  /// In id, this message translates to:
  /// **'Halal bihalal'**
  String get eventTypeHalalBihalal;

  /// No description provided for @eventTypeHoliday.
  ///
  /// In id, this message translates to:
  /// **'Liburan bareng'**
  String get eventTypeHoliday;

  /// No description provided for @eventTypeArisan.
  ///
  /// In id, this message translates to:
  /// **'Arisan'**
  String get eventTypeArisan;

  /// No description provided for @eventTypeHaul.
  ///
  /// In id, this message translates to:
  /// **'Haul, tahlilan'**
  String get eventTypeHaul;

  /// No description provided for @eventTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get eventTypeOther;

  /// No description provided for @eventToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get eventToday;

  /// No description provided for @eventTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok'**
  String get eventTomorrow;

  /// No description provided for @eventInDays.
  ///
  /// In id, this message translates to:
  /// **'{n} hari lagi'**
  String eventInDays(int n);

  /// No description provided for @eventGoingCount.
  ///
  /// In id, this message translates to:
  /// **'{n} hadir'**
  String eventGoingCount(int n);

  /// No description provided for @eventYouAreGoing.
  ///
  /// In id, this message translates to:
  /// **'Kamu hadir'**
  String get eventYouAreGoing;

  /// No description provided for @eventImGoing.
  ///
  /// In id, this message translates to:
  /// **'Saya hadir'**
  String get eventImGoing;

  /// No description provided for @eventNext.
  ///
  /// In id, this message translates to:
  /// **'Acara berikutnya'**
  String get eventNext;

  /// No description provided for @dateHaul.
  ///
  /// In id, this message translates to:
  /// **'haul ke-{n}'**
  String dateHaul(int n);

  /// No description provided for @dateBirthday.
  ///
  /// In id, this message translates to:
  /// **'ulang tahun ke-{n}'**
  String dateBirthday(int n);

  /// No description provided for @rsvpNone.
  ///
  /// In id, this message translates to:
  /// **'Belum jawab'**
  String get rsvpNone;

  /// No description provided for @rsvpGoing.
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get rsvpGoing;

  /// No description provided for @rsvpMaybe.
  ///
  /// In id, this message translates to:
  /// **'Mungkin'**
  String get rsvpMaybe;

  /// No description provided for @rsvpNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get rsvpNo;

  /// No description provided for @rsvpQuestion.
  ///
  /// In id, this message translates to:
  /// **'Kamu datang?'**
  String get rsvpQuestion;

  /// No description provided for @rsvpPeople.
  ///
  /// In id, this message translates to:
  /// **'Ikut bersamamu, termasuk kamu'**
  String get rsvpPeople;

  /// No description provided for @rsvpFewer.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get rsvpFewer;

  /// No description provided for @rsvpMore.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get rsvpMore;

  /// No description provided for @eventsTitle.
  ///
  /// In id, this message translates to:
  /// **'Acara keluarga'**
  String get eventsTitle;

  /// No description provided for @eventCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat acara'**
  String get eventCreate;

  /// No description provided for @eventEdit.
  ///
  /// In id, this message translates to:
  /// **'Edit acara'**
  String get eventEdit;

  /// No description provided for @eventsFromTree.
  ///
  /// In id, this message translates to:
  /// **'Dari silsilah, 30 hari ke depan'**
  String get eventsFromTree;

  /// No description provided for @eventsUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Mendatang ({n})'**
  String eventsUpcoming(int n);

  /// No description provided for @eventsPast.
  ///
  /// In id, this message translates to:
  /// **'Sudah lewat'**
  String get eventsPast;

  /// No description provided for @eventsNoPast.
  ///
  /// In id, this message translates to:
  /// **'Belum ada acara yang lewat.'**
  String get eventsNoPast;

  /// No description provided for @eventsNoMore.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada acara lain yang dijadwalkan.'**
  String get eventsNoMore;

  /// No description provided for @eventsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada acara'**
  String get eventsEmptyTitle;

  /// No description provided for @eventsEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Buat reuni, halal bihalal, atau liburan bareng. Undangan sampai ke semua anggota pohon ini.'**
  String get eventsEmptyBody;

  /// No description provided for @eventsEmptyViewer.
  ///
  /// In id, this message translates to:
  /// **'Acara yang dibuat keluarga akan muncul di sini.'**
  String get eventsEmptyViewer;

  /// No description provided for @eventAgenda.
  ///
  /// In id, this message translates to:
  /// **'Susunan acara'**
  String get eventAgenda;

  /// No description provided for @eventNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get eventNotes;

  /// No description provided for @eventShareWa.
  ///
  /// In id, this message translates to:
  /// **'Bagikan undangan ke WhatsApp'**
  String get eventShareWa;

  /// No description provided for @eventShareFooter.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kehadiran di aplikasi Bani, tab Acara.'**
  String get eventShareFooter;

  /// No description provided for @eventDuesPerHousehold.
  ///
  /// In id, this message translates to:
  /// **'{amount} per KK'**
  String eventDuesPerHousehold(String amount);

  /// No description provided for @eventForBranch.
  ///
  /// In id, this message translates to:
  /// **'Untuk cabang {name}'**
  String eventForBranch(String name);

  /// No description provided for @eventForAll.
  ///
  /// In id, this message translates to:
  /// **'Untuk semua anggota pohon'**
  String get eventForAll;

  /// No description provided for @eventDone.
  ///
  /// In id, this message translates to:
  /// **'Sudah selesai'**
  String get eventDone;

  /// No description provided for @eventDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus acara ini?'**
  String get eventDeleteTitle;

  /// No description provided for @eventDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Acara dan semua jawaban kehadiran akan dihapus.'**
  String get eventDeleteBody;

  /// No description provided for @eventDeleted.
  ///
  /// In id, this message translates to:
  /// **'Acara dihapus.'**
  String get eventDeleted;

  /// No description provided for @eventFromTime.
  ///
  /// In id, this message translates to:
  /// **'Mulai {time}'**
  String eventFromTime(String time);

  /// No description provided for @eventStartsAt.
  ///
  /// In id, this message translates to:
  /// **'Mulai pukul {time}'**
  String eventStartsAt(String time);

  /// No description provided for @eventOrganizer.
  ///
  /// In id, this message translates to:
  /// **'Diatur oleh {name}'**
  String eventOrganizer(String name);

  /// No description provided for @eventBranch.
  ///
  /// In id, this message translates to:
  /// **'Cabang {name}'**
  String eventBranch(String name);

  /// No description provided for @eventBranchOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get eventBranchOther;

  /// No description provided for @eventAttendance.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran per cabang'**
  String get eventAttendance;

  /// No description provided for @eventDues.
  ///
  /// In id, this message translates to:
  /// **'Iuran'**
  String get eventDues;

  /// No description provided for @eventDuesCollected.
  ///
  /// In id, this message translates to:
  /// **'terkumpul dari {n} KK'**
  String eventDuesCollected(int n);

  /// No description provided for @eventDuesLeft.
  ///
  /// In id, this message translates to:
  /// **'{n} KK lagi'**
  String eventDuesLeft(int n);

  /// No description provided for @eventDuesClaim.
  ///
  /// In id, this message translates to:
  /// **'Saya sudah transfer'**
  String get eventDuesClaim;

  /// No description provided for @eventDuesWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu konfirmasi bendahara'**
  String get eventDuesWaiting;

  /// No description provided for @eventDuesConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Iuranmu sudah dikonfirmasi'**
  String get eventDuesConfirmed;

  /// No description provided for @eventDuesTreasurer.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi pembayaran'**
  String get eventDuesTreasurer;

  /// No description provided for @eventDuesClaimed.
  ///
  /// In id, this message translates to:
  /// **'Bilang sudah transfer'**
  String get eventDuesClaimed;

  /// No description provided for @eventDuesNote.
  ///
  /// In id, this message translates to:
  /// **'Bendahara mencatat manual. Bani tidak memproses pembayaran.'**
  String get eventDuesNote;

  /// No description provided for @eventFormTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Isi nama acara dulu.'**
  String get eventFormTitleRequired;

  /// No description provided for @eventCreated.
  ///
  /// In id, this message translates to:
  /// **'Acara dibuat. Bagikan undangannya ke WhatsApp keluarga.'**
  String get eventCreated;

  /// No description provided for @eventSaved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan disimpan.'**
  String get eventSaved;

  /// No description provided for @eventFormType.
  ///
  /// In id, this message translates to:
  /// **'Jenis acara'**
  String get eventFormType;

  /// No description provided for @eventFormName.
  ///
  /// In id, this message translates to:
  /// **'Nama acara'**
  String get eventFormName;

  /// No description provided for @eventFormNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Reuni akbar Bani Harun'**
  String get eventFormNameHint;

  /// No description provided for @eventFormDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal dan jam mulai'**
  String get eventFormDate;

  /// No description provided for @eventFormAddEnd.
  ///
  /// In id, this message translates to:
  /// **'Lebih dari sehari? Tambah tanggal selesai'**
  String get eventFormAddEnd;

  /// No description provided for @eventFormUntil.
  ///
  /// In id, this message translates to:
  /// **'Sampai {date}'**
  String eventFormUntil(String date);

  /// No description provided for @eventFormPlace.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get eventFormPlace;

  /// No description provided for @eventFormPlacePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih lokasi'**
  String get eventFormPlacePick;

  /// No description provided for @eventFormInvite.
  ///
  /// In id, this message translates to:
  /// **'Siapa yang diundang'**
  String get eventFormInvite;

  /// No description provided for @eventFormInviteAll.
  ///
  /// In id, this message translates to:
  /// **'Semua bani'**
  String get eventFormInviteAll;

  /// No description provided for @eventFormInviteBranch.
  ///
  /// In id, this message translates to:
  /// **'Cabang tertentu'**
  String get eventFormInviteBranch;

  /// No description provided for @eventFormInviteHint.
  ///
  /// In id, this message translates to:
  /// **'Semua anggota pohon tetap bisa melihat acara ini.'**
  String get eventFormInviteHint;

  /// No description provided for @eventFormDues.
  ///
  /// In id, this message translates to:
  /// **'Iuran per KK'**
  String get eventFormDues;

  /// No description provided for @eventFormDuesHint.
  ///
  /// In id, this message translates to:
  /// **'Dicatat bendahara, uang ditransfer langsung'**
  String get eventFormDuesHint;

  /// No description provided for @eventFormAgendaAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get eventFormAgendaAdd;

  /// No description provided for @eventFormAgendaHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Foto bersama per cabang'**
  String get eventFormAgendaHint;

  /// No description provided for @eventFormNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Dress code, yang perlu dibawa, info parkir'**
  String get eventFormNotesHint;

  /// No description provided for @eventFormSubmit.
  ///
  /// In id, this message translates to:
  /// **'Buat acara'**
  String get eventFormSubmit;

  /// No description provided for @homeThisWeek.
  ///
  /// In id, this message translates to:
  /// **'Pekan ini'**
  String get homeThisWeek;

  /// No description provided for @homeHaulOf.
  ///
  /// In id, this message translates to:
  /// **'Haul ke-{n} {name}'**
  String homeHaulOf(int n, String name);

  /// No description provided for @homeBirthdayOf.
  ///
  /// In id, this message translates to:
  /// **'{name} ulang tahun ke-{n}'**
  String homeBirthdayOf(String name, int n);

  /// No description provided for @detailBirthdayOn.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahun {day}'**
  String detailBirthdayOn(String day);

  /// No description provided for @detailHaulOn.
  ///
  /// In id, this message translates to:
  /// **'Haul setiap {day}'**
  String detailHaulOn(String day);

  /// No description provided for @detailDateInEvents.
  ///
  /// In id, this message translates to:
  /// **'Muncul untuk semua keluarga di tab Acara.'**
  String get detailDateInEvents;

  /// No description provided for @detailGrandchildCount.
  ///
  /// In id, this message translates to:
  /// **'{n} cucu'**
  String detailGrandchildCount(int n);

  /// No description provided for @focusParentWith.
  ///
  /// In id, this message translates to:
  /// **'Orang tua, bersama {name}'**
  String focusParentWith(String name);

  /// No description provided for @treeModeChart.
  ///
  /// In id, this message translates to:
  /// **'Bagan'**
  String get treeModeChart;

  /// No description provided for @chartZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get chartZoomIn;

  /// No description provided for @chartZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil'**
  String get chartZoomOut;

  /// No description provided for @chartFit.
  ///
  /// In id, this message translates to:
  /// **'Muat satu layar'**
  String get chartFit;

  /// No description provided for @silsilahUpTo.
  ///
  /// In id, this message translates to:
  /// **'Sampai generasi {n}'**
  String silsilahUpTo(int n);

  /// No description provided for @silsilahTapGeneration.
  ///
  /// In id, this message translates to:
  /// **'Ketuk angka untuk membatasi generasi'**
  String get silsilahTapGeneration;

  /// No description provided for @eventBranchElders.
  ///
  /// In id, this message translates to:
  /// **'Sesepuh'**
  String get eventBranchElders;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'id':
      return L10nId();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
