import 'package:bani/core/providers/locale_provider.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/firebase_options.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Entry point — Firestore offline persistence is on by default on mobile.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // App Check: requests carry proof they come from the genuine app on a real
  // device. Nothing is blocked until enforcement is switched on in the
  // Firebase Console (App Check → APIs → Cloud Firestore) — see docs/SETUP.md.
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple:
          kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
    );
  } catch (_) {
    // Never block the app on App Check setup problems while testing.
  }
  // Bigger offline cache: member docs carry base64 thumbnails, so reopening
  // the tree is served locally instead of re-downloading them.
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true, cacheSizeBytes: 100 * 1024 * 1024 /* plugin max */);
  runApp(const ProviderScope(child: BaniApp()));
}

class BaniApp extends ConsumerWidget {
  const BaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Bani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      locale: ref.watch(localeProvider),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
