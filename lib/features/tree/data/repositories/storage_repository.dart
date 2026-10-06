import 'dart:convert';
import 'dart:typed_data';

import 'package:bani/core/constants/app_constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  StorageRepository — photos as base64 strings in Firestore (no Firebase
//  Storage, which needs the Blaze plan for new buckets).
// ─────────────────────────────────────────────────────────────────────────────

class PickedPhoto {
  const PickedPhoto({required this.thumbBase64, required this.fullBase64});

  /// ~128px, stored on the member document so the tree can show avatars.
  final String thumbBase64;

  /// ~512px, stored in members/{id}/media/photo and loaded on the detail page.
  final String fullBase64;

  Uint8List get thumbBytes => base64Decode(thumbBase64);
}

class StorageRepository {
  StorageRepository({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Returns null when the user cancels.
  Future<PickedPhoto?> pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1600);
    if (file == null) return null;
    final bytes = await file.readAsBytes();

    final thumb = await _compress(
        bytes, AppConstants.photoThumbSize, AppConstants.photoThumbQuality);
    var quality = AppConstants.photoFullQuality;
    var full = await _compress(bytes, AppConstants.photoFullSize, quality);
    while (full.length > AppConstants.photoMaxBytes && quality > 30) {
      quality -= 15;
      full = await _compress(bytes, AppConstants.photoFullSize, quality);
    }
    return PickedPhoto(
        thumbBase64: base64Encode(thumb), fullBase64: base64Encode(full));
  }

  /// Old family photos for the album: ~300px thumbnail + ~1280px photo kept
  /// under ~700 KB so its base64 stays below Firestore's 1 MiB document limit.
  Future<List<PickedPhoto>> pickAlbumPhotos({required int max}) async {
    if (max <= 0) return const [];
    final files = await _picker.pickMultiImage(maxWidth: 2400, limit: max);
    final out = <PickedPhoto>[];
    for (final file in files.take(max)) {
      final bytes = await file.readAsBytes();
      final thumb = await _compress(bytes, 300, 60);
      var quality = 72;
      var full = await _compress(bytes, 1280, quality);
      while (full.length > 700 * 1024 && quality > 35) {
        quality -= 12;
        full = await _compress(bytes, 1280, quality);
      }
      out.add(PickedPhoto(thumbBase64: base64Encode(thumb), fullBase64: base64Encode(full)));
    }
    return out;
  }

  Future<Uint8List> _compress(Uint8List input, int size, int quality) =>
      FlutterImageCompress.compressWithList(
        input,
        minWidth: size,
        minHeight: size,
        quality: quality,
        format: CompressFormat.jpeg,
      );
}
