// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bani';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get open => 'Open';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Try again';

  @override
  String get later => 'Not now';

  @override
  String get saving => 'Saving...';

  @override
  String get loadFailed => 'Couldn\'t load';

  @override
  String get notFound => 'Not found';

  @override
  String get copied => 'Copied.';

  @override
  String generation(int n) {
    return 'Generation $n';
  }

  @override
  String membersCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String generationsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n generations',
      one: '1 generation',
    );
    return '$_temp0';
  }

  @override
  String peopleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String childOf(String name) {
    return 'child of $name';
  }

  @override
  String get someoneElse => 'another member';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTree => 'Tree';

  @override
  String get tabInvite => 'Invite';

  @override
  String get tabProfile => 'Profile';

  @override
  String get exitTitle => 'Leave Bani?';

  @override
  String get exitBody => 'You can come back anytime. Your data stays saved.';

  @override
  String get exitConfirm => 'Leave';

  @override
  String get loginSlide1Title =>
      'A family tree that grows downward, easy to read on your phone.';

  @override
  String get loginSlide1Body =>
      'Each branch fills in its own family, then everyone meets again at reunions and family trips.';

  @override
  String get loginSlide2Title => 'Invite relatives over WhatsApp.';

  @override
  String get loginSlide2Body =>
      'Send a code, they sign in with Google, then fill in their own branch.';

  @override
  String get loginSlide3Title => 'Contacts and graves, one tap away.';

  @override
  String get loginSlide3Body =>
      'Open WhatsApp, call, or find a place in Google Maps straight from a member\'s profile.';

  @override
  String get loginPendingInvite => 'Sign in to open your invitation';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginTerms =>
      'By continuing you agree to Bani\'s Terms and Privacy Policy.';

  @override
  String get previewChild => 'Child';

  @override
  String get loginCancelled => 'Sign-in cancelled.';

  @override
  String get loginNoToken =>
      'Google didn\'t return a token. Check the Firebase setup.';

  @override
  String loginFailed(String reason) {
    return 'Sign-in failed: $reason';
  }

  @override
  String get inviteTitle => 'Invitation';

  @override
  String get inviteClaimed => 'Done! You can now fill in your branch.';

  @override
  String get inviteCannotOpen => 'Couldn\'t open the invitation';

  @override
  String get inviteToHome => 'Go home';

  @override
  String get inviteNotFound => 'Invitation not found';

  @override
  String get inviteInvalid => 'Invitation no longer valid';

  @override
  String get inviteUsed =>
      'This code was already used. Ask the sender for a new one.';

  @override
  String get inviteExpired =>
      'This code expired or was cancelled. Ask the sender for a new one.';

  @override
  String get inviteCanEditSelf => 'Complete your own details and photo';

  @override
  String get inviteCanAddKids => 'Add your children and grandchildren';

  @override
  String inviteCanAddKidsUntil(int n) {
    return 'Add children and grandchildren, down to generation $n';
  }

  @override
  String get inviteCanManage => 'Manage the whole tree';

  @override
  String inviteCanView(String family) {
    return 'See the whole $family tree';
  }

  @override
  String inviteFrom(String name, String family) {
    return '$name invited you to fill in a branch of $family.';
  }

  @override
  String get inviteIsThisYou => 'Is this you?';

  @override
  String get inviteAfterClaim => 'After claiming, you can';

  @override
  String get inviteYesMe => 'Yes, this is me';

  @override
  String get inviteNotMe => 'Not me';

  @override
  String get inviteAlreadyUsed =>
      'This invitation was already used or has expired.';

  @override
  String get inviteAlreadyJoined =>
      'Your account is already linked to this tree.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleContributor => 'Contributor';

  @override
  String get roleViewer => 'View only';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get spouseMarried => 'Married';

  @override
  String get spouseDivorced => 'Divorced';

  @override
  String get spouseDeceased => 'Deceased';

  @override
  String get alive => 'Alive';

  @override
  String get deceased => 'Deceased';

  @override
  String get deceasedShort => 'deceased';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeTitle => 'My families';

  @override
  String get homeSetupFailed => 'Couldn\'t set up your account';

  @override
  String get homeTrees => 'Family trees';

  @override
  String get homeNewTree => 'Create a new tree';

  @override
  String get homeHaveCode => 'Have an invite code?';

  @override
  String get homeWelcomeTitle => 'Welcome to Bani';

  @override
  String get homeWelcomeBody =>
      'Invited by family? Tap \"Have an invite code?\" and enter it. Want to record your own family? Tap \"Create a new tree\".';

  @override
  String get enterCodeTitle => 'Enter invite code';

  @override
  String get enterCodeBody =>
      'Ask the relative who invited you for the 8-letter code, or paste their link.';

  @override
  String get newTreeTitle => 'New tree';

  @override
  String get newTreeName => 'Family name, e.g. Harun Family';

  @override
  String get newTreeRoot => 'Name of the eldest ancestor';

  @override
  String get quotaTitle => 'Member quota';

  @override
  String get quotaUnlimited => '/ unlimited';

  @override
  String get quotaAdd => 'Add quota';

  @override
  String get quotaSuperAdmin => 'Super Admin · every tree unlimited';

  @override
  String get quotaPremium => 'Premium active';

  @override
  String quotaLeft(int n) {
    return '$n slots left for your trees';
  }

  @override
  String get treeOnlyOwnBranch =>
      'You can only add children within your own branch.';

  @override
  String get treeEmptyTitle => 'No tree yet';

  @override
  String get treeEmptyBody =>
      'Create a tree on Home or enter an invite code from your family.';

  @override
  String get treeSearch => 'Search members';

  @override
  String get treeExport => 'Export to Excel';

  @override
  String get treeRename => 'Rename tree';

  @override
  String get treeRenameTitle => 'Tree name';

  @override
  String get treeFilterAll => 'Everyone';

  @override
  String get treeFilterMine => 'My branch';

  @override
  String get treeGoToMe => 'Find me';

  @override
  String get treeAddChild => 'Add child';

  @override
  String get treeViewDetail => 'View details';

  @override
  String get treeEditData => 'Edit details';

  @override
  String get treeMove => 'Move to another parent';

  @override
  String get treeMe => 'Me';

  @override
  String get searchName => 'Search by name';

  @override
  String get detailNotFound => 'Member not found';

  @override
  String detailChildOrder(int n, String parent) {
    return 'Child #$n of $parent';
  }

  @override
  String detailChildOf(String parent) {
    return 'Child of $parent';
  }

  @override
  String detailAliveAge(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n years',
      one: '1 year',
    );
    return 'Alive · $_temp0 old';
  }

  @override
  String detailDeceasedAge(int n) {
    return 'Deceased · aged $n';
  }

  @override
  String detailLastEdit(String name, String date) {
    return 'Last edited by $name · $date';
  }

  @override
  String detailChildren(int n) {
    return 'Children ($n)';
  }

  @override
  String get detailNoChildren => 'No children recorded yet.';

  @override
  String detailDeleteKidsFirst(String name) {
    return 'Delete their children first before deleting $name.';
  }

  @override
  String detailDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get detailDeleteBody =>
      'Their details, photo, and contact will be removed from the tree.';

  @override
  String get detailWhatsapp => 'WhatsApp';

  @override
  String get detailCall => 'Call';

  @override
  String get detailOpenMaps => 'Open Maps';

  @override
  String get detailGrave => 'Grave';

  @override
  String get detailBorn => 'Born';

  @override
  String get detailDied => 'Died';

  @override
  String get detailAddress => 'Address';

  @override
  String get detailSpouse => 'Spouse';

  @override
  String get detailGender => 'Gender';

  @override
  String get detailOccupation => 'Occupation';

  @override
  String get detailNotes => 'Notes';

  @override
  String get detailOpenInMaps => 'Open in Maps';

  @override
  String get detailContactHidden => 'No contact yet, or it\'s private';

  @override
  String get detailUnclaimed => 'Profile not claimed yet';

  @override
  String detailUnclaimedBody(String name) {
    return 'Invite $name or one of their children to fill in this branch.';
  }

  @override
  String get detailInvite => 'Invite';

  @override
  String waGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get formStepIdentity => 'Identity';

  @override
  String get formStepBirth => 'Birth';

  @override
  String get formStepSpouse => 'Spouse';

  @override
  String get formStepContact => 'Contact';

  @override
  String get formNextBirth => 'Next: Birth & death';

  @override
  String get formNextSpouse => 'Next: Spouse';

  @override
  String get formNextContact => 'Next: Contact';

  @override
  String get formEditTitle => 'Edit details';

  @override
  String get formAddTitle => 'Add child';

  @override
  String formChildOf(String parent, int n) {
    return 'Child of $parent · Generation $n';
  }

  @override
  String formRoot(int n) {
    return 'Eldest ancestor · Generation $n';
  }

  @override
  String formChangedBy(String name) {
    return 'Just changed by $name.';
  }

  @override
  String get formReload => 'Reload';

  @override
  String formQuotaUse(int n) {
    return 'Uses 1 of your $n remaining member slots';
  }

  @override
  String get formNameRequired => 'Full name is required.';

  @override
  String get formSaveChanges => 'Save changes';

  @override
  String get formSaveMember => 'Save member';

  @override
  String get formAddPhoto => 'Add photo';

  @override
  String get formChangePhoto => 'Change photo';

  @override
  String get formPhotoHint =>
      'From camera or gallery. Compressed automatically to stay light.';

  @override
  String get formFullName => 'Full name';

  @override
  String get formFullNameHint => 'e.g. Hasan Basri';

  @override
  String get formNickname => 'Nickname';

  @override
  String get formNicknameHint => 'e.g. Uncle Hasan';

  @override
  String get formGender => 'Gender';

  @override
  String get formBirthOrder => 'Birth order';

  @override
  String get formOccupation => 'Occupation';

  @override
  String get formOccupationHint => 'e.g. Teacher';

  @override
  String get formCamera => 'Camera';

  @override
  String get formGallery => 'Gallery';

  @override
  String get formRemovePhoto => 'Remove photo';

  @override
  String get formBirthPlace => 'Place of birth';

  @override
  String get formBirthPlaceHint => 'e.g. Kediri';

  @override
  String get formBirthDate => 'Date of birth';

  @override
  String get formYearOnlyKnown => 'Only the year is known';

  @override
  String get formStatus => 'Status';

  @override
  String get formDeathDate => 'Date of death';

  @override
  String get formYearOnly => 'Year only';

  @override
  String get formGrave => 'Grave location';

  @override
  String get formGravePick => 'Pick the grave on the map';

  @override
  String get formGraveHint => 'A grave location helps the family visit.';

  @override
  String get formSpouseIntro =>
      'Add a wife or husband. You can add more than one, e.g. after remarriage.';

  @override
  String formSpouseN(int n) {
    return 'Spouse $n';
  }

  @override
  String get formName => 'Name';

  @override
  String get formSpouseNameHint => 'Spouse\'s full name';

  @override
  String get formAddSpouse => 'Add spouse';

  @override
  String get formWhatsapp => 'WhatsApp number';

  @override
  String get formHomeAddress => 'Home address';

  @override
  String get formAddressPick => 'Pick the address on the map';

  @override
  String get formAddressDetail => 'Details: unit, landmark';

  @override
  String get formWhoSeesContact => 'Who can see this contact?';

  @override
  String get formVisibilityFamily => 'Everyone in the tree';

  @override
  String get formVisibilityFamilyHint => 'Family can WhatsApp directly';

  @override
  String get formVisibilityAdmins => 'Owner & Admins only';

  @override
  String get formVisibilityAdminsHint => 'More private';

  @override
  String get formNotes => 'Notes (optional)';

  @override
  String get formNotesHint => 'A short story, message, or memory';

  @override
  String get formConflictTitle => 'Someone just made changes';

  @override
  String formConflictBody(String message) {
    return '$message\n\nLoad the latest (your changes are discarded), or save only the fields you changed on top of the latest?';
  }

  @override
  String get formLoadLatest => 'Load latest';

  @override
  String get formKeepMine => 'Save mine';

  @override
  String get formPickDate => 'Pick a date';

  @override
  String get formTapToOpenMap => 'Tap to open the map';

  @override
  String get formChangeOnMap => 'Change on map';

  @override
  String get mapSelected => 'Selected location';

  @override
  String get mapNotFound => 'Address not found.';

  @override
  String get mapPermissionDenied => 'Location permission denied.';

  @override
  String get mapNoGps => 'Couldn\'t get your location. Make sure GPS is on.';

  @override
  String get mapSearch => 'Search an address or place';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapResolving => 'Finding address...';

  @override
  String get mapDrag => 'Drag the map';

  @override
  String get mapDetailHint => 'Details: unit, landmark, gate colour';

  @override
  String get mapUse => 'Use this location';

  @override
  String get mapTitleDefault => 'Pick a location';

  @override
  String get invPageTitle => 'Invite family';

  @override
  String invPageBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n generations',
      one: '1 generation',
    );
    return 'Contributors fill in their own branch, down to $_temp0 below them.';
  }

  @override
  String get invOnlyManagers =>
      'Only the Owner or an Admin can invite. Ask them to send a code to you or your relatives.';

  @override
  String get invForWho => 'Who is this for?';

  @override
  String get invPickMember => 'Pick a member';

  @override
  String get invPickMemberHint => 'The person who will fill in their branch';

  @override
  String get invClaimed => 'claimed';

  @override
  String get invUnclaimed => 'not claimed yet';

  @override
  String invContributorDepth(int n, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n generations',
      one: '1 generation',
    );
    return 'Can fill in $_temp0 below · code valid $days days';
  }

  @override
  String invContributorUntil(int n, int days) {
    return 'Can fill in down to generation $n · code valid $days days';
  }

  @override
  String get invAdminHint => 'Admins can edit the whole tree and invite others';

  @override
  String get invViewerHint => 'Can only view the tree';

  @override
  String get invCreating => 'Creating code...';

  @override
  String get invCreate => 'Create invite code';

  @override
  String invMessage(
    String name,
    String family,
    String code,
    int days,
    String link,
  ) {
    return 'Hi $name, let\'s fill in the $family family tree in the Bani app.\n\n1. Open Bani and continue with Google\n2. On Home, tap \"Have an invite code?\"\n3. Enter the code: *$code*\n\nThe code is valid for $days days.\n$link';
  }

  @override
  String get invCodeFor => 'Invite code for';

  @override
  String invCodeMeta(String role, int days) {
    return '$role · valid $days days · single use';
  }

  @override
  String get invSendWhatsapp => 'Send via WhatsApp';

  @override
  String get invCopyCode => 'Copy code';

  @override
  String get invCodeCopied => 'Code copied.';

  @override
  String get invSent => 'Invitations sent';

  @override
  String invSentMeta(String role, String code) {
    return '$role · code $code';
  }

  @override
  String invDaysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get invCancel => 'Cancel';

  @override
  String get invActive => 'Active access';

  @override
  String get invNoneYet => 'Nobody invited yet.';

  @override
  String get invMember => 'Member';

  @override
  String invUntilGen(String role, int n) {
    return '$role · down to gen $n';
  }

  @override
  String get invStatusActive => 'Active';

  @override
  String get invRevoke => 'Revoke access';

  @override
  String get profileSuperAdmin => 'Super Admin';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profileFree => 'Free plan';

  @override
  String get profileUnlimited => 'members · unlimited';

  @override
  String profileOfLimit(int n) {
    return 'of $n members';
  }

  @override
  String get profileQuotaHint =>
      'The quota is shared by your trees, including what contributors add.';

  @override
  String get profileSettings => 'SETTINGS';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileContactPrivacy => 'Contact privacy';

  @override
  String get profileContactPrivacyValue => 'Set per member';

  @override
  String get profileSuperAdminSection => 'SUPER ADMIN';

  @override
  String get profileImport => 'Import Bani Mungin data';

  @override
  String get profileFeedbackInbox => 'Feedback inbox';

  @override
  String get profileOther => 'MORE';

  @override
  String get profileSendFeedback => 'Send feedback';

  @override
  String get profileHelp => 'Help via WhatsApp';

  @override
  String get profileHelpMessage => 'Hi Bani admin, I need some help.';

  @override
  String get profileLogout => 'Sign out';

  @override
  String profileVersion(String v) {
    return 'Bani version $v';
  }

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get importReadFailed => 'Couldn\'t read the data';

  @override
  String get importTitle => 'Import Bani Mungin';

  @override
  String importFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n people found',
      one: '1 person found',
    );
    return '$_temp0';
  }

  @override
  String importPerGen(int g, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n people',
      one: '1 person',
    );
    return 'Generation $g: $_temp0';
  }

  @override
  String importChildrenOf(String name) {
    return 'Children of $name:';
  }

  @override
  String importKidCount(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n children',
      one: '1 child',
    );
    return '$name ($_temp0)';
  }

  @override
  String get importAlready => 'This data was already imported.';

  @override
  String get importWillCreate =>
      'A new tree \"Bani Mungin\" will be created with you as Owner. The old data stays untouched.';

  @override
  String get importDo => 'Import';

  @override
  String importDone(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n members imported.',
      one: '1 member imported.',
    );
    return '$_temp0';
  }

  @override
  String get importEmpty => 'The \"mungin\" collection is empty or unreadable.';

  @override
  String get importNoName => 'Unnamed';

  @override
  String get limitBranchTitle => 'This branch reached its limit';

  @override
  String get limitMemberTitle => 'Member quota is full';

  @override
  String limitBranchBody(String name, int n) {
    return '$name\'s branch is free down to generation $n. Pick a package to continue, then pay via the admin.';
  }

  @override
  String limitMemberBody(String family, int n) {
    return 'The $family tree already uses $n member slots. Add quota to continue.';
  }

  @override
  String limitWaMessage(
    String package,
    String family,
    String familyId,
    String email,
    String uid,
  ) {
    return 'Hi Bani admin, I\'d like $package.\nTree: $family ($familyId)\nAccount: $email ($uid)';
  }

  @override
  String get limitAddQuota => 'more quota';

  @override
  String get limitNoAdminWa =>
      'The admin WhatsApp number isn\'t set in config/app.';

  @override
  String get limitPickPackage => 'Pick a package';

  @override
  String limitPay(String price) {
    return 'Pay $price via WhatsApp';
  }

  @override
  String get limitContactAdmin => 'Contact admin via WhatsApp';

  @override
  String get limitAskOwner => 'Ask the Owner instead';

  @override
  String get limitAfterTransfer =>
      'After you transfer, the admin confirms and the quota opens automatically.';

  @override
  String limitGen(int n) {
    return 'Gen $n';
  }

  @override
  String get pkgBranchName => 'Open branch';

  @override
  String get pkgBranchDesc => '+2 generations for one branch';

  @override
  String get pkgMembersName => 'Add 50 members';

  @override
  String get pkgMembersDesc => '+50 members & +10 album photos';

  @override
  String get pkgPremiumName => 'Family Premium';

  @override
  String get pkgPremiumDesc => 'Unlimited members & 200 album photos';

  @override
  String get pkgOnce => 'one-time';

  @override
  String get pkgYearly => 'per year';

  @override
  String get pkgSave => 'Best value';

  @override
  String get moveRootNotAllowed => 'The eldest ancestor can\'t be moved.';

  @override
  String get moveIntoOwnSubtree =>
      'Can\'t move someone under their own descendant.';

  @override
  String get moveConfirmTitle => 'Move member?';

  @override
  String moveConfirmBody(String name, String parent, int n) {
    return '$name will become a child of $parent (generation $n).';
  }

  @override
  String moveConfirmBodyWithKids(String name, int kids, String parent, int n) {
    return '$name and $kids descendants will become a child of $parent (generation $n).';
  }

  @override
  String get moveDo => 'Move';

  @override
  String moveDone(String name, String parent) {
    return '$name is now a child of $parent.';
  }

  @override
  String movePickTitle(String name) {
    return 'Move $name';
  }

  @override
  String get movePickHint => 'Pick the correct parent.';

  @override
  String get errPermission =>
      'Rejected by the server [permission-denied]. Check quota, branch, or app version.';

  @override
  String get errOffline =>
      'You\'re offline. Changes will sync when you\'re back online.';

  @override
  String get errNotFound => 'Not found.';

  @override
  String errGeneric(String code) {
    return 'Something went wrong ($code).';
  }

  @override
  String get errEditDenied =>
      'The server rejected this change [edit/permission-denied]. Make sure Bani is up to date (see Profile) and you are an Admin or this branch\'s Contributor.';

  @override
  String errConflict(String name) {
    return '$name just changed this member.';
  }

  @override
  String get xlsGeneration => 'Generation';

  @override
  String get xlsFullName => 'Full name';

  @override
  String get xlsNickname => 'Nickname';

  @override
  String get xlsGender => 'Gender';

  @override
  String get xlsBirthOrder => 'Birth order';

  @override
  String get xlsParent => 'Parent';

  @override
  String get xlsBirthPlace => 'Place of birth';

  @override
  String get xlsBirthDate => 'Date of birth';

  @override
  String get xlsStatus => 'Status';

  @override
  String get xlsDeathDate => 'Date of death';

  @override
  String get xlsSpouse => 'Spouse';

  @override
  String get xlsOccupation => 'Occupation';

  @override
  String xlsShareText(String family) {
    return '$family family tree';
  }

  @override
  String get fbTitle => 'Send feedback';

  @override
  String get fbBody =>
      'Got a feature idea, a problem, or wrong data? Write it here — it goes straight to the developer.';

  @override
  String get fbTypeIdea => 'Feature idea';

  @override
  String get fbTypeBug => 'Problem';

  @override
  String get fbTypeOther => 'Other';

  @override
  String get fbHint => 'Write your feedback...';

  @override
  String get fbSend => 'Send';

  @override
  String get fbTooShort => 'Write at least 5 characters.';

  @override
  String get fbThanks => 'Thank you! Your feedback was sent.';

  @override
  String get fbInboxTitle => 'Feedback inbox';

  @override
  String get fbInboxEmpty => 'No feedback yet.';

  @override
  String get fbMarkDone => 'Mark as done';

  @override
  String get fbDone => 'Done';

  @override
  String get fbNew => 'New';

  @override
  String get treeRefresh => 'Refresh data';

  @override
  String get treeRefreshed => 'Data refreshed.';

  @override
  String albumTitle(int n) {
    return 'Memories ($n)';
  }

  @override
  String get albumEmpty =>
      'No old photos yet. Add some memories so the grandchildren can see them too.';

  @override
  String get albumAdd => 'Add photos';

  @override
  String albumUploading(int done, int total) {
    return 'Uploading $done/$total...';
  }

  @override
  String albumUploaded(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n photos added.',
      one: '1 photo added.',
    );
    return '$_temp0';
  }

  @override
  String get albumCaptionTitle => 'Photo caption';

  @override
  String get albumCaptionHint => 'e.g. Eid at grandpa\'s house';

  @override
  String get albumYearHint => 'Year (optional)';

  @override
  String get albumDelete => 'Delete photo';

  @override
  String get albumDeleteConfirm => 'Delete this photo from the album?';

  @override
  String albumBy(String name) {
    return 'Uploaded by $name';
  }

  @override
  String albumQuota(int used, int limit) {
    return '$used/$limit photos in this tree';
  }

  @override
  String get albumLimitTitle => 'Album quota is full';

  @override
  String albumLimitBody(String family, int n) {
    return 'The $family tree already uses $n album photos. Add quota to upload more.';
  }

  @override
  String get albumEditCaption => 'Edit caption';

  @override
  String memberHasAlbum(String name) {
    return 'Delete $name\'s album photos before deleting this member.';
  }

  @override
  String get pkgFamilyName => 'Family';

  @override
  String get pkgFamilyDesc => 'Unlimited members & branches · 60 photos';

  @override
  String get pkgBigFamilyName => 'Big Family';

  @override
  String get pkgBigFamilyDesc => '2 trees · unlimited · 150 photos per tree';

  @override
  String get pkgPhotosName => 'Photo Pack +30';

  @override
  String get pkgPhotosDesc => '+30 album photos for your tree';

  @override
  String get planFree => 'Free plan';

  @override
  String get planFamily => 'Family';

  @override
  String get planBigFamily => 'Big Family';

  @override
  String get treeLimitTitle => 'A second tree needs Big Family';

  @override
  String get treeLimitBody =>
      'Big Family lets you own 2 trees, e.g. your father\'s and mother\'s families, or yours and your spouse\'s.';

  @override
  String get deviceUsed =>
      'This phone was already used to create a free tree with another account. Sign in with that account, or choose a paid plan.';

  @override
  String albumNeedMembers(int n) {
    return 'Add at least $n members before uploading album photos.';
  }

  @override
  String albumDailyLimit(int n) {
    return 'Today\'s upload limit is reached ($n photos). Try again tomorrow.';
  }

  @override
  String get tabEvents => 'Events';

  @override
  String get treeFilterAllBranches => 'All branches';

  @override
  String get treeModeList => 'Lineage';

  @override
  String get treeModeFocus => 'Focus';

  @override
  String get treeShowInFocus => 'Show in Focus view';

  @override
  String silsilahMyGeneration(int n) {
    return 'Your generation: $n';
  }

  @override
  String get silsilahThisIsYou => 'this is you';

  @override
  String get silsilahCollapse => 'Fold branch';

  @override
  String silsilahExpand(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Show $n descendants',
      one: 'Show 1 descendant',
    );
    return '$_temp0';
  }

  @override
  String get silsilahExpandAll => 'Unfold all branches';

  @override
  String get silsilahCollapseAll => 'Fold all branches';

  @override
  String get focusParent => 'Parent';

  @override
  String focusSibling(int pos, int total) {
    return 'Sibling $pos of $total';
  }

  @override
  String get focusTapHint => 'Tap to move focus';

  @override
  String focusChildCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n children',
      one: '1 child',
    );
    return '$_temp0';
  }

  @override
  String focusBorn(int year) {
    return 'Born $year';
  }

  @override
  String focusChildOrder(int n, int total) {
    return 'child $n of $total';
  }

  @override
  String focusSpouse(String name) {
    return 'Spouse: $name';
  }

  @override
  String get focusProfile => 'Profile';

  @override
  String get eventTypeReunion => 'Reunion';

  @override
  String get eventTypeHalalBihalal => 'Halal bihalal';

  @override
  String get eventTypeHoliday => 'Family trip';

  @override
  String get eventTypeArisan => 'Arisan';

  @override
  String get eventTypeHaul => 'Haul, tahlilan';

  @override
  String get eventTypeOther => 'Other';

  @override
  String get eventToday => 'Today';

  @override
  String get eventTomorrow => 'Tomorrow';

  @override
  String eventInDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'in $n days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String eventGoingCount(int n) {
    return '$n coming';
  }

  @override
  String get eventYouAreGoing => 'You\'re coming';

  @override
  String get eventImGoing => 'I\'m coming';

  @override
  String get eventNext => 'Next event';

  @override
  String dateHaul(int n) {
    return 'death anniversary no. $n';
  }

  @override
  String dateBirthday(int n) {
    return 'turns $n';
  }

  @override
  String get rsvpNone => 'No answer yet';

  @override
  String get rsvpGoing => 'Coming';

  @override
  String get rsvpMaybe => 'Maybe';

  @override
  String get rsvpNo => 'Not coming';

  @override
  String get rsvpQuestion => 'Are you coming?';

  @override
  String get rsvpPeople => 'Coming with you, you included';

  @override
  String get rsvpFewer => 'Fewer';

  @override
  String get rsvpMore => 'More';

  @override
  String get eventsTitle => 'Family events';

  @override
  String get eventCreate => 'New event';

  @override
  String get eventEdit => 'Edit event';

  @override
  String get eventsFromTree => 'From the tree, next 30 days';

  @override
  String eventsUpcoming(int n) {
    return 'Upcoming ($n)';
  }

  @override
  String get eventsPast => 'Past';

  @override
  String get eventsNoPast => 'No past events yet.';

  @override
  String get eventsNoMore => 'No other events scheduled.';

  @override
  String get eventsEmptyTitle => 'No events yet';

  @override
  String get eventsEmptyBody =>
      'Plan a reunion, halal bihalal or a family trip. Everyone in this tree gets the invitation.';

  @override
  String get eventsEmptyViewer => 'Events your family plans will show up here.';

  @override
  String get eventAgenda => 'Schedule';

  @override
  String get eventNotes => 'Notes';

  @override
  String get eventShareWa => 'Share invitation on WhatsApp';

  @override
  String get eventShareFooter =>
      'Confirm your attendance in the Bani app, Events tab.';

  @override
  String eventDuesPerHousehold(String amount) {
    return '$amount per household';
  }

  @override
  String eventForBranch(String name) {
    return 'For the $name branch';
  }

  @override
  String get eventForAll => 'For everyone in the tree';

  @override
  String get eventDone => 'Finished';

  @override
  String get eventDeleteTitle => 'Delete this event?';

  @override
  String get eventDeleteBody =>
      'The event and all attendance answers will be deleted.';

  @override
  String get eventDeleted => 'Event deleted.';

  @override
  String eventFromTime(String time) {
    return 'Starts $time';
  }

  @override
  String eventStartsAt(String time) {
    return 'Starts at $time';
  }

  @override
  String eventOrganizer(String name) {
    return 'Organised by $name';
  }

  @override
  String eventBranch(String name) {
    return '$name branch';
  }

  @override
  String get eventBranchOther => 'Others';

  @override
  String get eventAttendance => 'Attendance by branch';

  @override
  String get eventDues => 'Contributions';

  @override
  String eventDuesCollected(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n households',
      one: '1 household',
    );
    return 'collected from $_temp0';
  }

  @override
  String eventDuesLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n households left',
      one: '1 household left',
    );
    return '$_temp0';
  }

  @override
  String get eventDuesClaim => 'I\'ve transferred';

  @override
  String get eventDuesWaiting => 'Waiting for the treasurer';

  @override
  String get eventDuesConfirmed => 'Your contribution is confirmed';

  @override
  String get eventDuesTreasurer => 'Confirm payments';

  @override
  String get eventDuesClaimed => 'Says they\'ve transferred';

  @override
  String get eventDuesNote =>
      'The treasurer keeps the record. Bani doesn\'t process payments.';

  @override
  String get eventFormTitleRequired => 'Enter the event name first.';

  @override
  String get eventCreated =>
      'Event created. Share the invitation in your family WhatsApp.';

  @override
  String get eventSaved => 'Changes saved.';

  @override
  String get eventFormType => 'Event type';

  @override
  String get eventFormName => 'Event name';

  @override
  String get eventFormNameHint => 'e.g. Grand family reunion';

  @override
  String get eventFormDate => 'Start date and time';

  @override
  String get eventFormAddEnd => 'More than one day? Add an end date';

  @override
  String eventFormUntil(String date) {
    return 'Until $date';
  }

  @override
  String get eventFormPlace => 'Location';

  @override
  String get eventFormPlacePick => 'Choose a location';

  @override
  String get eventFormInvite => 'Who\'s invited';

  @override
  String get eventFormInviteAll => 'Whole family';

  @override
  String get eventFormInviteBranch => 'One branch';

  @override
  String get eventFormInviteHint =>
      'Everyone in the tree can still see this event.';

  @override
  String get eventFormDues => 'Contribution per household';

  @override
  String get eventFormDuesHint =>
      'The treasurer records it; money is transferred directly';

  @override
  String get eventFormAgendaAdd => 'Add';

  @override
  String get eventFormAgendaHint => 'e.g. Group photo per branch';

  @override
  String get eventFormNotesHint => 'Dress code, what to bring, parking';

  @override
  String get eventFormSubmit => 'Create event';

  @override
  String get homeThisWeek => 'This week';

  @override
  String homeHaulOf(int n, String name) {
    return '$name, death anniversary no. $n';
  }

  @override
  String homeBirthdayOf(String name, int n) {
    return '$name turns $n';
  }

  @override
  String detailBirthdayOn(String day) {
    return 'Birthday on $day';
  }

  @override
  String detailHaulOn(String day) {
    return 'Death anniversary on $day';
  }

  @override
  String get detailDateInEvents =>
      'Shown to the whole family in the Events tab.';

  @override
  String detailGrandchildCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n grandchildren',
      one: '1 grandchild',
    );
    return '$_temp0';
  }

  @override
  String focusParentWith(String name) {
    return 'Parent, with $name';
  }

  @override
  String get treeModeChart => 'Chart';

  @override
  String get chartZoomIn => 'Zoom in';

  @override
  String get chartZoomOut => 'Zoom out';

  @override
  String get chartFit => 'Fit to screen';

  @override
  String silsilahUpTo(int n) {
    return 'Down to generation $n';
  }

  @override
  String get silsilahTapGeneration => 'Tap a number to limit generations';

  @override
  String get eventBranchElders => 'Elders';
}
