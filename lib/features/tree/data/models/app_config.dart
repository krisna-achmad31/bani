import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/l10n/l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppConfig — config/app, editable online by the Super Admin
// ─────────────────────────────────────────────────────────────────────────────

class PricePackage {
  const PricePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    this.tag,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String period;
  final String? tag;

  factory PricePackage.fromMap(Map<String, dynamic> m) => PricePackage(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        description: m['description'] as String? ?? '',
        price: (m['price'] as num?)?.toInt() ?? 0,
        period: m['period'] as String? ?? '',
        tag: m['tag'] as String?,
      );

  /// Subscriptions change users/{uid}.plan; the rest are one-time add-ons.
  bool get isSubscription => id == 'keluarga' || id == 'keluarga_besar';
}

/// Built-in packages are shown in the app language; custom ones (added in
/// config/app) use their stored text.
extension PricePackageText on PricePackage {
  String get title => switch (id) {
        'keluarga' => tr.pkgFamilyName,
        'keluarga_besar' => tr.pkgBigFamilyName,
        'branch' => tr.pkgBranchName,
        'photos30' => tr.pkgPhotosName,
        _ => name,
      };
  String get subtitle => switch (id) {
        'keluarga' => tr.pkgFamilyDesc,
        'keluarga_besar' => tr.pkgBigFamilyDesc,
        'branch' => tr.pkgBranchDesc,
        'photos30' => tr.pkgPhotosDesc,
        _ => description,
      };
  String get periodText => switch (id) {
        'branch' || 'photos30' => tr.pkgOnce,
        'keluarga' || 'keluarga_besar' => tr.pkgYearly,
        _ => period,
      };
  String? get tagText => id == 'keluarga_besar' && tag != null ? tr.pkgSave : tag;
}

/// Limits of one plan. `null` = unlimited.
class PlanLimits {
  const PlanLimits({
    required this.trees,
    this.members,
    this.branchDepth,
    required this.album,
    required this.uploadsPerDay,
  });

  final int trees;
  final int? members;
  final int? branchDepth;
  final int album;
  final int uploadsPerDay;

  factory PlanLimits.fromMap(Map? m, PlanLimits fallback) {
    if (m == null) return fallback;
    int? opt(String k, int? d) =>
        m.containsKey(k) ? (m[k] == null ? null : (m[k] as num).toInt()) : d;
    return PlanLimits(
      trees: (m['trees'] as num?)?.toInt() ?? fallback.trees,
      members: opt('members', fallback.members),
      branchDepth: opt('branchDepth', fallback.branchDepth),
      album: (m['album'] as num?)?.toInt() ?? fallback.album,
      uploadsPerDay: (m['uploadsPerDay'] as num?)?.toInt() ?? fallback.uploadsPerDay,
    );
  }

  Map<String, dynamic> toMap() => {
        'trees': trees,
        'members': members,
        'branchDepth': branchDepth,
        'album': album,
        'uploadsPerDay': uploadsPerDay,
      };
}

class AppConfig {
  const AppConfig({
    this.defaultMemberLimit = AppConstants.defaultMemberLimit,
    this.defaultBranchDepth = AppConstants.defaultBranchDepth,
    this.minMembersForAlbum = 5,
    this.plans = defaultPlans,
    this.showPricing = true,
    this.adminWhatsapp = '',
    this.packages = defaultPackages,
  });

  final int defaultMemberLimit;
  final int defaultBranchDepth;

  /// Free trees need at least this many members before photos can be added.
  final int minMembersForAlbum;
  final Map<String, PlanLimits> plans;
  final bool showPricing;

  /// Admin WhatsApp number in international format, e.g. 6281234567890.
  final String adminWhatsapp;
  final List<PricePackage> packages;

  PlanLimits plan(String key) => plans[key] ?? plans['free'] ?? defaultPlans['free']!;

  static const defaultPlans = {
    'free': PlanLimits(
        trees: 1, members: 50, branchDepth: 2, album: 6, uploadsPerDay: 10),
    'keluarga': PlanLimits(trees: 1, album: 60, uploadsPerDay: 50),
    'keluarga_besar': PlanLimits(trees: 2, album: 150, uploadsPerDay: 50),
  };

  static const defaultPackages = [
    PricePackage(
        id: 'keluarga',
        name: 'Keluarga',
        description: 'Anggota & cabang tanpa batas, 60 foto',
        price: 49000,
        period: 'per tahun'),
    PricePackage(
        id: 'keluarga_besar',
        name: 'Keluarga Besar',
        description: '2 pohon, tanpa batas, 150 foto per pohon',
        price: 99000,
        period: 'per tahun',
        tag: 'Hemat'),
    PricePackage(
        id: 'branch',
        name: 'Buka Cabang',
        description: '+2 generasi untuk satu cabang',
        price: 15000,
        period: 'sekali bayar'),
    PricePackage(
        id: 'photos30',
        name: 'Paket Foto +30',
        description: '+30 foto album untuk pohonmu',
        price: 15000,
        period: 'sekali bayar'),
  ];

  factory AppConfig.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const AppConfig();
    final pk = (m['packages'] as List?)
        ?.whereType<Map>()
        .map((e) => PricePackage.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final rawPlans = m['plans'] as Map?;
    return AppConfig(
      defaultMemberLimit: (m['defaultMemberLimit'] as num?)?.toInt() ??
          AppConstants.defaultMemberLimit,
      defaultBranchDepth: (m['defaultBranchDepth'] as num?)?.toInt() ??
          AppConstants.defaultBranchDepth,
      minMembersForAlbum: (m['minMembersForAlbum'] as num?)?.toInt() ?? 5,
      plans: {
        for (final e in defaultPlans.entries)
          e.key: PlanLimits.fromMap(rawPlans?[e.key] as Map?, e.value),
      },
      showPricing: m['showPricing'] as bool? ?? true,
      adminWhatsapp: m['adminWhatsapp'] as String? ?? '',
      packages: (pk == null || pk.isEmpty) ? defaultPackages : pk,
    );
  }
}
