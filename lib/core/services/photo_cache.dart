import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PhotoCache — keeps decoded photos so base64 is downloaded and decoded once:
//   1. memory: LRU of decoded bytes (bounded, so long sessions don't grow RAM)
//   2. disk:   <app support>/photo_cache/<key>.jpg, survives app restarts
//  Keys must change when the photo changes (album ids are immutable; profile
//  photos use a hash of their thumbnail as the version).
// ─────────────────────────────────────────────────────────────────────────────

class PhotoCache {
  PhotoCache._();
  static final instance = PhotoCache._();

  static const _maxMemoryItems = 120;
  static const _maxDiskBytes = 150 * 1024 * 1024;

  final _memory = <String, Uint8List>{}; // insertion-ordered (LinkedHashMap)
  Directory? _dir;

  Future<Directory> _cacheDir() async {
    if (_dir != null) return _dir!;
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/photo_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return _dir = dir;
  }

  String _safe(String key) => key.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');

  Uint8List? memory(String key) {
    final hit = _memory.remove(key);
    if (hit != null) _memory[key] = hit; // move to most-recent
    return hit;
  }

  void _remember(String key, Uint8List bytes) {
    _memory.remove(key);
    _memory[key] = bytes;
    while (_memory.length > _maxMemoryItems) {
      _memory.remove(_memory.keys.first);
    }
  }

  /// Returns cached bytes, or calls [fetchBase64] (network), decodes and
  /// stores the result in memory + on disk.
  Future<Uint8List?> get(String key, Future<String?> Function() fetchBase64) async {
    final mem = memory(key);
    if (mem != null) return mem;
    try {
      final file = File('${(await _cacheDir()).path}/${_safe(key)}.jpg');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        _remember(key, bytes);
        return bytes;
      }
      final data = await fetchBase64();
      if (data == null || data.isEmpty) return null;
      final bytes = base64Decode(data);
      _remember(key, bytes);
      await file.writeAsBytes(bytes, flush: false);
      _trimDisk();
      return bytes;
    } catch (_) {
      final data = await fetchBase64();
      return data == null ? null : base64Decode(data);
    }
  }

  Future<void> evict(String key) async {
    _memory.remove(key);
    try {
      final file = File('${(await _cacheDir()).path}/${_safe(key)}.jpg');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Drops the oldest files once the folder grows past [_maxDiskBytes].
  Future<void> _trimDisk() async {
    try {
      final files = (await _cacheDir()).listSync().whereType<File>().toList();
      var total = files.fold<int>(0, (a, f) => a + f.lengthSync());
      if (total <= _maxDiskBytes) return;
      files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      for (final f in files) {
        if (total <= _maxDiskBytes * 0.8) break;
        total -= f.lengthSync();
        await f.delete();
      }
    } catch (_) {}
  }
}
