import 'package:bani/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

export 'package:bani/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Localization helpers — widgets use `context.t`; code without a
//  BuildContext (repositories, errors, Excel export) uses the global `tr`,
//  which follows the language picked in Profil.
// ─────────────────────────────────────────────────────────────────────────────

extension L10nX on BuildContext {
  L10n get t => L10n.of(this);
}

var _current = const Locale('id');

/// Called by the locale provider whenever the language changes.
void setCurrentLocale(Locale locale) {
  _current = locale;
  Intl.defaultLocale = locale.languageCode;
}

Locale get currentLocale => _current;
bool get isEnglish => _current.languageCode == 'en';

L10n get tr => lookupL10n(_current);
