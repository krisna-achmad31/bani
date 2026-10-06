import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AlbumPhoto — families/{fid}/members/{mid}/album/{pid}
//  The list document only holds a small thumbnail; the ~1280px photo lives in
//  album/{pid}/full/data and is fetched when the photo is opened.
//  (Base64 in Firestore while on the free plan; swap for Storage URLs later
//  without changing the UI.)
// ─────────────────────────────────────────────────────────────────────────────

class AlbumPhoto {
  const AlbumPhoto({
    required this.id,
    required this.thumb,
    this.caption,
    this.year,
    this.uploadedBy,
    this.uploadedByName,
    this.createdAt,
  });

  final String id;
  final String thumb;
  final String? caption;
  final int? year;
  final String? uploadedBy;
  final String? uploadedByName;
  final DateTime? createdAt;

  factory AlbumPhoto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return AlbumPhoto(
      id: s.id,
      thumb: d['thumb'] as String? ?? '',
      caption: d['caption'] as String?,
      year: (d['year'] as num?)?.toInt(),
      uploadedBy: d['uploadedBy'] as String?,
      uploadedByName: d['uploadedByName'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
