import 'package:bani/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Gender
// ─────────────────────────────────────────────────────────────────────────────

enum Gender { male, female, unknown }

extension GenderX on Gender {
  static Gender from(String? s) =>
      Gender.values.where((g) => g.name == s).firstOrNull ?? Gender.unknown;
  String get label => switch (this) {
        Gender.male => tr.genderMale,
        Gender.female => tr.genderFemale,
        Gender.unknown => '-',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
//  GeoPlace — an address or grave location that can open Google Maps
// ─────────────────────────────────────────────────────────────────────────────

class GeoPlace {
  const GeoPlace({required this.text, this.detail, this.lat, this.lng});

  final String text;
  final String? detail;
  final double? lat;
  final double? lng;

  bool get hasCoordinates => lat != null && lng != null;

  static GeoPlace? fromMap(Object? m) {
    if (m is! Map) return null;
    final text = m['text'] as String? ?? '';
    if (text.isEmpty && m['lat'] == null) return null;
    return GeoPlace(
      text: text,
      detail: m['detail'] as String?,
      lat: (m['lat'] as num?)?.toDouble(),
      lng: (m['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() =>
      {'text': text, 'detail': detail, 'lat': lat, 'lng': lng};

  GeoPlace copyWith({String? detail}) =>
      GeoPlace(text: text, detail: detail ?? this.detail, lat: lat, lng: lng);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Spouse
// ─────────────────────────────────────────────────────────────────────────────

enum SpouseStatus { married, divorced, deceased }

extension SpouseStatusX on SpouseStatus {
  static SpouseStatus from(String? s) =>
      SpouseStatus.values.where((v) => v.name == s).firstOrNull ??
      SpouseStatus.married;
  String get label => switch (this) {
        SpouseStatus.married => tr.spouseMarried,
        SpouseStatus.divorced => tr.spouseDivorced,
        SpouseStatus.deceased => tr.spouseDeceased,
      };
}

class Spouse {
  const Spouse({required this.name, this.status = SpouseStatus.married, this.memberId});

  final String name;
  final SpouseStatus status;

  /// Set when the spouse is also a member of this tree.
  final String? memberId;

  factory Spouse.fromMap(Map m) => Spouse(
        name: m['name'] as String? ?? '',
        status: SpouseStatusX.from(m['status'] as String?),
        memberId: m['memberId'] as String?,
      );

  Map<String, dynamic> toMap() =>
      {'name': name, 'status': status.name, 'memberId': memberId};
}

// ─────────────────────────────────────────────────────────────────────────────
//  MemberModel — families/{familyId}/members/{memberId}
//  Contact data lives in members/{id}/private/contact, the large photo in
//  members/{id}/media/photo. Only the small thumbnail stays on this document.
// ─────────────────────────────────────────────────────────────────────────────

class MemberModel {
  const MemberModel({
    required this.memberId,
    required this.fullName,
    this.nickname,
    this.parentId,
    this.generation = 1,
    this.ancestors = const [],
    this.birthOrder,
    this.gender = Gender.unknown,
    this.birthPlace,
    this.birthDate,
    this.birthYearOnly = false,
    this.isDeceased = false,
    this.deathDate,
    this.deathYearOnly = false,
    this.grave,
    this.spouses = const [],
    this.occupation,
    this.notes,
    this.photoThumb,
    this.hasPhoto = false,
    this.claimedByUid,
    this.createdBy,
    this.version = 0,
    this.updatedByName,
    this.updatedAt,
  });

  final String memberId;
  final String fullName;
  final String? nickname;
  final String? parentId;
  final int generation;
  final List<String> ancestors;
  final int? birthOrder;
  final Gender gender;
  final String? birthPlace;
  final DateTime? birthDate;
  final bool birthYearOnly;
  final bool isDeceased;
  final DateTime? deathDate;
  final bool deathYearOnly;
  final GeoPlace? grave;
  final List<Spouse> spouses;
  final String? occupation;
  final String? notes;

  /// 128px JPEG, base64.
  final String? photoThumb;
  final bool hasPhoto;
  final String? claimedByUid;
  final String? createdBy;

  /// Optimistic lock: every edit must write version + 1 (enforced by rules),
  /// so a save based on stale data is rejected instead of overwriting.
  final int version;
  final String? updatedByName;
  final DateTime? updatedAt;

  bool get isRoot => parentId == null;
  bool get isClaimed => claimedByUid != null && claimedByUid!.isNotEmpty;

  int? get age {
    if (birthDate == null) return null;
    final end = isDeceased ? deathDate : DateTime.now();
    if (end == null) return null;
    var years = end.year - birthDate!.year;
    if (!birthYearOnly &&
        (end.month < birthDate!.month ||
            (end.month == birthDate!.month && end.day < birthDate!.day))) {
      years--;
    }
    return years;
  }

  factory MemberModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    DateTime? ts(Object? v) => v is Timestamp ? v.toDate() : null;
    return MemberModel(
      memberId: s.id,
      fullName: d['fullName'] as String? ?? '',
      nickname: d['nickname'] as String?,
      parentId: d['parentId'] as String?,
      generation: (d['generation'] as num?)?.toInt() ?? 1,
      ancestors: List<String>.from(d['ancestors'] as List? ?? const []),
      birthOrder: (d['birthOrder'] as num?)?.toInt(),
      gender: GenderX.from(d['gender'] as String?),
      birthPlace: d['birthPlace'] as String?,
      birthDate: ts(d['birthDate']),
      birthYearOnly: d['birthYearOnly'] as bool? ?? false,
      isDeceased: d['isDeceased'] as bool? ?? false,
      deathDate: ts(d['deathDate']),
      deathYearOnly: d['deathYearOnly'] as bool? ?? false,
      grave: GeoPlace.fromMap(d['grave']),
      spouses: (d['spouses'] as List? ?? const [])
          .whereType<Map>()
          .map(Spouse.fromMap)
          .toList(),
      occupation: d['occupation'] as String?,
      notes: d['notes'] as String?,
      photoThumb: d['photoThumb'] as String?,
      hasPhoto: d['hasPhoto'] as bool? ?? false,
      claimedByUid: d['claimedByUid'] as String?,
      createdBy: d['createdBy'] as String?,
      version: (d['version'] as num?)?.toInt() ?? 0,
      updatedByName: d['updatedByName'] as String?,
      updatedAt: ts(d['updatedAt']),
    );
  }

  /// Editable fields only. Structural fields (parentId, generation, ancestors,
  /// claimedByUid, createdBy) are written once on create by the repository.
  Map<String, dynamic> toEditableMap() => {
        'fullName': fullName.trim(),
        'nickname': _blank(nickname),
        'birthOrder': birthOrder,
        'gender': gender.name,
        'birthPlace': _blank(birthPlace),
        'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate!),
        'birthYearOnly': birthYearOnly,
        'isDeceased': isDeceased,
        'deathDate': isDeceased && deathDate != null
            ? Timestamp.fromDate(deathDate!)
            : null,
        'deathYearOnly': deathYearOnly,
        'grave': isDeceased ? grave?.toMap() : null,
        'spouses': spouses.map((s) => s.toMap()).toList(),
        'occupation': _blank(occupation),
        'notes': _blank(notes),
        'photoThumb': photoThumb,
        'hasPhoto': hasPhoto,
      };

  static String? _blank(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  MemberModel copyWith({
    String? memberId,
    String? fullName,
    String? nickname,
    String? parentId,
    int? generation,
    List<String>? ancestors,
    int? birthOrder,
    Gender? gender,
    String? birthPlace,
    DateTime? birthDate,
    bool? birthYearOnly,
    bool? isDeceased,
    DateTime? deathDate,
    bool? deathYearOnly,
    GeoPlace? grave,
    List<Spouse>? spouses,
    String? occupation,
    String? notes,
    String? photoThumb,
    bool? hasPhoto,
    String? claimedByUid,
    String? createdBy,
  }) =>
      MemberModel(
        memberId: memberId ?? this.memberId,
        fullName: fullName ?? this.fullName,
        nickname: nickname ?? this.nickname,
        parentId: parentId ?? this.parentId,
        generation: generation ?? this.generation,
        ancestors: ancestors ?? this.ancestors,
        birthOrder: birthOrder ?? this.birthOrder,
        gender: gender ?? this.gender,
        birthPlace: birthPlace ?? this.birthPlace,
        birthDate: birthDate ?? this.birthDate,
        birthYearOnly: birthYearOnly ?? this.birthYearOnly,
        isDeceased: isDeceased ?? this.isDeceased,
        deathDate: deathDate ?? this.deathDate,
        deathYearOnly: deathYearOnly ?? this.deathYearOnly,
        grave: grave ?? this.grave,
        spouses: spouses ?? this.spouses,
        occupation: occupation ?? this.occupation,
        notes: notes ?? this.notes,
        photoThumb: photoThumb ?? this.photoThumb,
        hasPhoto: hasPhoto ?? this.hasPhoto,
        claimedByUid: claimedByUid ?? this.claimedByUid,
        createdBy: createdBy ?? this.createdBy,
        version: version,
        updatedByName: updatedByName,
        updatedAt: updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberModel && memberId == other.memberId;

  @override
  int get hashCode => memberId.hashCode;
}

// ─────────────────────────────────────────────────────────────────────────────
//  MemberContact — members/{id}/private/contact (readable per `visibility`)
// ─────────────────────────────────────────────────────────────────────────────

enum ContactVisibility { family, admins }

class MemberContact {
  const MemberContact({
    this.phone,
    this.address,
    this.visibility = ContactVisibility.family,
  });

  final String? phone;
  final GeoPlace? address;
  final ContactVisibility visibility;

  bool get isEmpty => (phone == null || phone!.isEmpty) && address == null;

  factory MemberContact.fromMap(Map<String, dynamic>? d) {
    if (d == null) return const MemberContact();
    return MemberContact(
      phone: d['phone'] as String?,
      address: GeoPlace.fromMap(d['address']),
      visibility: d['visibility'] == 'admins'
          ? ContactVisibility.admins
          : ContactVisibility.family,
    );
  }

  Map<String, dynamic> toMap() => {
        'phone': (phone == null || phone!.trim().isEmpty) ? null : phone!.trim(),
        'address': address?.toMap(),
        'visibility': visibility.name,
      };
}
