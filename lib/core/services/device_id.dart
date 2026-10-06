import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DeviceId — a salted SHA-256 of the phone's ID, used only to allow one free
//  tree per phone (devices/{hash}). The raw ID never leaves the device.
//  Android: ANDROID_ID (stable across reinstalls for this app's signing key).
//  iOS: identifierForVendor.
// ─────────────────────────────────────────────────────────────────────────────

class DeviceId {
  DeviceId._();

  static const _salt = 'bani-device-v1';
  static String? _cached;

  static Future<String?> hash() async {
    if (_cached != null) return _cached;
    String? raw;
    try {
      if (Platform.isAndroid) {
        raw = await const AndroidId().getId();
      } else if (Platform.isIOS) {
        raw = (await DeviceInfoPlugin().iosInfo).identifierForVendor;
      }
    } catch (_) {}
    if (raw == null || raw.isEmpty) return null;
    return _cached = sha256.convert(utf8.encode('$_salt:$raw')).toString();
  }
}
