// ─────────────────────────────────────────────────────────────────────────────
//  App Constants
// ─────────────────────────────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String configCollection = 'config';
  static const String configAppDoc = 'app';
  static const String familiesCollection = 'families';
  static const String membersCollection = 'members';
  static const String grantsCollection = 'grants';
  static const String invitesCollection = 'invites';
  static const String mediaCollection = 'media';
  static const String privateCollection = 'private';
  static const String photoDoc = 'photo';
  static const String contactDoc = 'contact';
  static const String eventsCollection = 'events';
  static const String rsvpsCollection = 'rsvps';

  // App owner — registers as Super Admin on login (also hard-coded in rules).
  static const String ownerEmail = 'achmad.yukrisna@gmail.com';

  // Legacy nested data from the old famtree app, imported by the Super Admin.
  static const String legacyCollection = 'mungin';
  static const String legacyFamilyId = 'bani-mungin';
  static const String legacyFamilyName = 'Bani Mungin';

  // Fallbacks when config/app is missing or unreadable.
  static const int defaultMemberLimit = 50;
  static const int defaultBranchDepth = 2;
  static const int defaultAlbumFree = 6; // album photos per tree, free plan
  static const int defaultAlbumPremium = 200; // fair-use cap for Premium

  // Invite links. Host this domain (e.g. Firebase Hosting <project>.web.app)
  // with /.well-known/assetlinks.json so Android App Links open the app.
  static const String inviteHost = 'bani-app.web.app';
  static const String inviteBaseUrl = 'https://$inviteHost/invite';
  static const int inviteExpiryDays = 7;

  // Google Sign-In: Web client ID from Firebase Console
  // (Authentication → Sign-in method → Google → Web SDK configuration).
  // Required on Android by google_sign_in 7 to obtain an idToken.
  static const String googleServerClientId =
      '33966153493-9bmdt3nekk2n6qk91ham6jqa4f9g17qi.apps.googleusercontent.com';

  // Photos stored as base64 in Firestore (no Firebase Storage).
  static const int photoThumbSize = 128;
  static const int photoThumbQuality = 70;
  static const int photoFullSize = 512;
  static const int photoFullQuality = 75;
  static const int photoMaxBytes = 200 * 1024;

  // Map tiles (OpenStreetMap — free, no API key).
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackage = 'com.bani.bani';
}
