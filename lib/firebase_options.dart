// ─────────────────────────────────────────────────────────────────────────────
//  firebase_options.dart — PLACEHOLDER
//
//  This file will be generated automatically by the FlutterFire CLI.
//  Run the following after setting up your Firebase project:
//
//    dart pub global activate flutterfire_cli
//    flutterfire configure
//
//  See docs/FIREBASE_SETUP.md for full step-by-step instructions.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  // ── REPLACE THESE PLACEHOLDERS WITH YOUR REAL VALUES ──────────────────────
  // Run `flutterfire configure` to generate this automatically.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrT57tnMKJeyeRGhKyrbykdjeNRoHnAus',
    appId: '1:33966153493:android:fb2ce63e63803fe64e131c',
    messagingSenderId: '33966153493',
    projectId: 'famtree-489cc',
    databaseURL: 'https://famtree-489cc-default-rtdb.firebaseio.com',
    storageBucket: 'famtree-489cc.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDV8-xQquitjIMyoTLjKiNSUW4BFTU5KI4',
    appId: '1:33966153493:ios:73451107e27791c14e131c',
    messagingSenderId: '33966153493',
    projectId: 'famtree-489cc',
    databaseURL: 'https://famtree-489cc-default-rtdb.firebaseio.com',
    storageBucket: 'famtree-489cc.firebasestorage.app',
    androidClientId: '33966153493-e9rm3b4mmhe6ef9nj316bhe54dg1f969.apps.googleusercontent.com',
    iosClientId: '33966153493-k1bi0p42vg5aomrb99srsqrc0p2mqf5e.apps.googleusercontent.com',
    iosBundleId: 'com.bani.bani',
  );
}
