import 'dart:typed_data';

import 'package:bani/core/services/photo_cache.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bani/features/auth/domain/entities/app_user.dart';
import 'package:bani/features/auth/domain/entities/user_profile.dart';
import 'package:bani/features/auth/domain/repositories/auth_repository.dart';
import 'package:bani/features/tree/data/models/app_config.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/invite_model.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/data/repositories/legacy_import_repository.dart';
import 'package:bani/features/tree/data/repositories/storage_repository.dart';
import 'package:bani/features/tree/data/repositories/tree_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Repositories
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepositoryImpl());
final treeRepositoryProvider = Provider((ref) => TreeRepository());
final storageRepositoryProvider = Provider((ref) => StorageRepository());
final legacyImportRepositoryProvider = Provider((ref) => LegacyImportRepository());

// ─────────────────────────────────────────────────────────────────────────────
//  Session
// ─────────────────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AppUser?>(
    (ref) => ref.watch(authRepositoryProvider).authStateChanges);

final currentUserProvider =
    Provider<AppUser?>((ref) => ref.watch(authStateProvider).value);

/// "1.0.1 (2)" — shown in Profil so we can tell which APK someone runs.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

final configProvider = StreamProvider<AppConfig>(
    (ref) => ref.watch(treeRepositoryProvider).watchConfig());

AppConfig readConfig(Ref ref) =>
    ref.watch(configProvider).value ?? const AppConfig();

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(treeRepositoryProvider).watchUserProfile(user.uid);
});

final isSuperAdminProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(false);
  return ref.watch(treeRepositoryProvider).watchIsSuperAdmin(user.uid);
});

/// Invite token from a deep link, kept until the user has signed in.
class PendingInvite extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? token) => state = token;
}

final pendingInviteProvider =
    NotifierProvider<PendingInvite, String?>(PendingInvite.new);

/// Runs once per login: creates users/{uid}. Trees are never auto-created —
/// the user either enters an invite code or taps "Buat pohon baru".
final bootstrapProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final repo = ref.read(treeRepositoryProvider);
  await repo.ensureUserProfile(user);
  await repo.ensureOwnerAdmin(user);
  // Mirror the owner's plan onto their trees (display only; rules re-check).
  final profile = await ref.read(userProfileProvider.future);
  final isAdmin = await ref.read(isSuperAdminProvider.future);
  if (profile != null) {
    await repo.syncOwnerPlan(user.uid, isAdmin ? 'admin' : profile.effectivePlan);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
//  Families
// ─────────────────────────────────────────────────────────────────────────────

final userFamiliesProvider = StreamProvider<List<FamilyModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(treeRepositoryProvider).watchUserFamilies(user.uid);
});

/// Family shown in the "Pohon" and "Undang" tabs.
class SelectedFamily extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? familyId) => state = familyId;
}

final selectedFamilyIdProvider =
    NotifierProvider<SelectedFamily, String?>(SelectedFamily.new);

/// The selected family, falling back to the first one the user belongs to.
final activeFamilyIdProvider = Provider<String?>((ref) {
  final selected = ref.watch(selectedFamilyIdProvider);
  final families = ref.watch(userFamiliesProvider).value ?? const [];
  if (selected != null && families.any((f) => f.familyId == selected)) {
    return selected;
  }
  return families.firstOrNull?.familyId;
});

final familyProvider = StreamProvider.family<FamilyModel?, String>(
    (ref, fid) => ref.watch(treeRepositoryProvider).watchFamily(fid));

final membersProvider = StreamProvider.family<List<MemberModel>, String>(
    (ref, fid) => ref.watch(treeRepositoryProvider).watchMembers(fid));

final familyIndexProvider = Provider.family<FamilyIndex?, String>((ref, fid) {
  final members = ref.watch(membersProvider(fid)).value;
  return members == null ? null : FamilyIndex(members);
});

final myGrantProvider = StreamProvider.family<GrantModel?, String>((ref, fid) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(treeRepositoryProvider).watchGrant(fid, user.uid);
});

final grantsProvider = StreamProvider.family<List<GrantModel>, String>(
    (ref, fid) => ref.watch(treeRepositoryProvider).watchGrants(fid));

final invitesProvider = StreamProvider.family<List<InviteModel>, String>(
    (ref, fid) => ref.watch(treeRepositoryProvider).watchInvites(fid));

typedef MemberKey = ({String familyId, String memberId});

final contactProvider = StreamProvider.family<MemberContact?, MemberKey>(
    (ref, k) => ref.watch(treeRepositoryProvider).watchContact(k.familyId, k.memberId));

/// Full profile photo, cached on the device. [version] changes whenever the
/// photo does (hash of the thumbnail), so a new photo is never served stale.
typedef PhotoKey = ({String familyId, String memberId, int version});

final photoProvider = FutureProvider.family<Uint8List?, PhotoKey>((ref, k) =>
    PhotoCache.instance.get('profile_${k.familyId}_${k.memberId}_${k.version}',
        () => ref.read(treeRepositoryProvider).getPhoto(k.familyId, k.memberId)));

final inviteProvider = FutureProvider.family<InviteModel?, String>(
    (ref, token) => ref.watch(treeRepositoryProvider).getInvite(token));

// ─────────────────────────────────────────────────────────────────────────────
//  Access — mirrors firestore.rules so the UI can explain limits up front
// ─────────────────────────────────────────────────────────────────────────────

enum AddCheck { ok, branchLimit, memberLimit, albumLimit, treeLimit, notAllowed }

class FamilyAccess {
  const FamilyAccess({
    required this.uid,
    required this.family,
    required this.grant,
    required this.isSuperAdmin,
    required this.ownerProfile,
  });

  final String uid;
  final FamilyModel? family;
  final GrantModel? grant;
  final bool isSuperAdmin;

  /// Only known when the current user is the owner (users/{uid} is private).
  final UserProfile? ownerProfile;

  FamilyRole? get role => family?.roleOf(uid);
  bool get canManage => isSuperAdmin || (role?.canManage ?? false);
  bool get isOwner => family?.ownerId == uid;

  bool inBranch(MemberModel m) {
    final anchor = grant?.anchorMemberId;
    return anchor != null && (m.memberId == anchor || m.ancestors.contains(anchor));
  }

  bool canEdit(MemberModel m) =>
      canManage ||
      (role == FamilyRole.contributor && inBranch(m)) ||
      (role != FamilyRole.viewer && m.claimedByUid == uid);

  bool canDelete(MemberModel m) =>
      !m.isRoot && (canManage || (role == FamilyRole.contributor && m.createdBy == uid));

  AddCheck canAddChild(MemberModel parent) {
    if (!canManage) {
      if (role != FamilyRole.contributor || !inBranch(parent)) {
        return AddCheck.notAllowed;
      }
      // A paid owner's tree has no branch-depth limit for contributors.
      final max = grant?.maxGeneration;
      if (max != null && !(family?.ownerPaid ?? false) && parent.generation + 1 > max) {
        return AddCheck.branchLimit;
      }
    }
    final p = ownerProfile;
    if (!isSuperAdmin && p != null && !p.isPaid &&
        (family?.memberCount ?? 0) >= p.memberLimit) {
      return AddCheck.memberLimit;
    }
    return AddCheck.ok;
  }
}

final accessProvider = Provider.family<FamilyAccess, String>((ref, fid) {
  final user = ref.watch(currentUserProvider);
  final family = ref.watch(familyProvider(fid)).value;
  final profile = ref.watch(userProfileProvider).value;
  return FamilyAccess(
    uid: user?.uid ?? '',
    family: family,
    grant: ref.watch(myGrantProvider(fid)).value,
    isSuperAdmin: ref.watch(isSuperAdminProvider).value ?? false,
    ownerProfile: family?.ownerId == user?.uid ? profile : null,
  );
});
