import 'dart:ui';

import 'package:bani/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  App language (Indonesia / English), remembered on the device.
// ─────────────────────────────────────────────────────────────────────────────

const supportedLanguages = ['id', 'en'];
const _prefsKey = 'app_language';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final device = PlatformDispatcher.instance.locale.languageCode;
    final initial = Locale(device == 'en' ? 'en' : 'id');
    setCurrentLocale(initial);
    _restore();
    return initial;
  }

  Future<void> _restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_prefsKey);
      if (saved != null && supportedLanguages.contains(saved) && saved != state.languageCode) {
        _apply(Locale(saved));
      }
    } catch (_) {}
  }

  Future<void> set(String languageCode) async {
    _apply(Locale(languageCode));
    try {
      await (await SharedPreferences.getInstance()).setString(_prefsKey, languageCode);
    } catch (_) {}
  }

  void _apply(Locale locale) {
    setCurrentLocale(locale);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
