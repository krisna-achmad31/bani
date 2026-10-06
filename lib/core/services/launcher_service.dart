import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LauncherService — WhatsApp, phone and Google Maps (URL scheme, no API key)
// ─────────────────────────────────────────────────────────────────────────────

class LauncherService {
  LauncherService._();

  static Future<bool> whatsapp(String phone, {String? text}) => _open(Uri.https(
        'wa.me',
        '/${normalizePhone(phone)}',
        {if (text != null) 'text': text},
      ));

  /// Opens WhatsApp with [text] ready to send to any chat or group.
  static Future<bool> whatsappShare(String text) =>
      _open(Uri.https('wa.me', '/', {'text': text}));

  static Future<bool> call(String phone) =>
      _open(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  static Future<bool> maps(GeoPlace place) {
    final query = place.hasCoordinates
        ? '${place.lat},${place.lng}'
        : [place.text, place.detail].whereType<String>().join(', ');
    return _open(Uri.https(
        'www.google.com', '/maps/search/', {'api': '1', 'query': query}));
  }

  static Future<bool> _open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
