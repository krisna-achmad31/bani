import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/services/device_id.dart';
import 'package:bani/features/tree/data/models/app_config.dart';
import 'package:bani/features/tree/data/repositories/tree_repository.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/events/presentation/event_providers.dart';
import 'package:bani/features/events/presentation/widgets/event_widgets.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/limit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  03 Beranda — next event, birthdays/haul this week, trees, quota
// ─────────────────────────────────────────────────────────────────────────────

class FamilyListPage extends ConsumerWidget {
  const FamilyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bootstrap = ref.watch(bootstrapProvider);
    final familiesAsync = ref.watch(userFamiliesProvider);
    final firstName = (user?.displayName ?? '').split(' ').first;

    if (bootstrap.hasError) {
      return MessageView(
        icon: Icons.cloud_off_rounded,
        title: context.t.homeSetupFailed,
        message: bootstrap.error.toString(),
        action: FilledButton(
            onPressed: () => ref.invalidate(bootstrapProvider),
            child: Text(context.t.retry)),
      );
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(userFamiliesProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            ScreenTitle(
              context.t.homeTitle,
              subtitle: context.t.homeGreeting(firstName),
              trailing: GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: MemberAvatar(name: user?.displayName ?? '?', size: 44,
                    ring: false, background: AppColors.goldSoft,
                    foreground: AppColors.gold),
              ),
            ),
            const SizedBox(height: 24),
            const _ComingUp(),
            SectionLabel(context.t.homeTrees),
            const SizedBox(height: 12),
            familiesAsync.when(
              loading: () => const Padding(
                  padding: EdgeInsets.all(32), child: LoadingView()),
              error: (e, _) => Text(e.toString()),
              data: (families) => families.isEmpty
                  ? (bootstrap.isLoading
                      ? const Padding(padding: EdgeInsets.all(32), child: LoadingView())
                      : const _EmptyWelcome())
                  : Column(children: [
                      for (final (i, f) in families.indexed) ...[
                        FadeSlideIn(index: i, child: _FamilyCard(family: f)),
                        const SizedBox(height: 12),
                      ],
                    ]),
            ),
            _DashedButton(
              icon: Icons.add,
              label: context.t.homeNewTree,
              onTap: () => _createTree(context, ref),
            ),
            const SizedBox(height: 12),
            _DashedButton(
              icon: Icons.link_rounded,
              label: context.t.homeHaveCode,
              onTap: () => _openInviteLink(context),
            ),
            const SizedBox(height: 24),
            const _QuotaCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _createTree(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final families = ref.read(userFamiliesProvider).value ?? const [];
    final profile = ref.read(userProfileProvider).value;
    final isAdmin = ref.read(isSuperAdminProvider).value ?? false;
    final config = ref.read(configProvider).value ?? const AppConfig();
    final plan = profile?.effectivePlan ?? 'free';
    final repo = ref.read(treeRepositoryProvider);

    // Tree ids: 1st = uid, 2nd = uid_2 (Keluarga Besar). Super Admin: any id.
    final ownsFirst = families.any((f) => f.familyId == user.uid);
    final ownsSecond = families.any((f) => f.familyId == '${user.uid}_2');
    String? familyId;
    if (!ownsFirst) {
      familyId = user.uid;
    } else if (isAdmin) {
      familyId = null;
    } else if (config.plan(plan).trees >= 2 && !ownsSecond) {
      familyId = '${user.uid}_2';
    } else {
      await showLimitSheet(context, familyId: user.uid, reason: AddCheck.treeLimit);
      return;
    }

    // One free tree per phone: claim this device before creating it.
    String? deviceHash;
    if (familyId == user.uid && !isAdmin && plan == 'free') {
      deviceHash = await DeviceId.hash();
      if (deviceHash != null && !await repo.claimDevice(deviceHash, user.uid)) {
        if (context.mounted) showMessage(context, context.t.deviceUsed);
        return;
      }
    }
    if (!context.mounted) return;

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _NewTreeDialog(),
    );
    if (result == null) return;
    try {
      final fid = await repo.createFamily(
            familyId: familyId,
            name: result.$1,
            owner: user,
            rootName: result.$2,
            deviceHash: deviceHash,
            ownerPlan: isAdmin ? 'admin' : plan,
          );
      ref.read(selectedFamilyIdProvider.notifier).select(fid);
      if (context.mounted) context.go(AppRoutes.tree);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _openInviteLink(BuildContext context) async {
    final ctrl = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.enterCodeTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(context.t.enterCodeBody,
              style: AppText.body(13, color: AppColors.ink2, height: 1.4)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: AppText.body(20, weight: FontWeight.w700).copyWith(letterSpacing: 2),
            decoration: const InputDecoration(hintText: 'ABCD-EFGH'),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.t.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(context.t.open)),
        ],
      ),
    );
    final token = input == null ? null : parseInviteInput(input);
    if (token != null && context.mounted) context.push(AppRoutes.join(token));
  }
}

/// Next event and this week's birthdays / haul in the active tree.
class _ComingUp extends ConsumerWidget {
  const _ComingUp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fid = ref.watch(activeFamilyIdProvider);
    if (fid == null) return const SizedBox.shrink();
    final next = ref.watch(nextEventProvider(fid));
    final dates =
        ref.watch(familyIndexProvider(fid))?.upcomingDates(from: DateTime.now(), days: 7) ??
            const <FamilyDate>[];
    if (next == null && dates.isEmpty) return const SizedBox.shrink();
    final t = context.t;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (next != null) ...[
        FadeSlideIn(
          child: NextEventStrip(
            event: next,
            onTap: () => context.push(AppRoutes.event(fid, next.eventId)),
          ),
        ),
        const SizedBox(height: 24),
      ],
      if (dates.isNotEmpty) ...[
        SectionLabel(t.homeThisWeek),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final (i, d) in dates.indexed) ...[
              if (i > 0) const Divider(),
              ListTile(
                onTap: () => context.push(AppRoutes.member(fid, d.member.memberId)),
                leading: CircleAvatar(
                  backgroundColor: d.kind == FamilyDateKind.haul
                      ? AppColors.goldSoft
                      : AppColors.primarySoft,
                  child: Icon(
                      d.kind == FamilyDateKind.haul
                          ? Icons.nightlight_outlined
                          : Icons.cake_outlined,
                      size: 18,
                      color: d.kind == FamilyDateKind.haul ? AppColors.gold : AppColors.primary),
                ),
                title: Text(
                  d.kind == FamilyDateKind.haul
                      ? t.homeHaulOf(d.years, d.member.fullName)
                      : t.homeBirthdayOf(d.member.fullName, d.years),
                  style: AppText.body(14, weight: FontWeight.w700),
                ),
                subtitle: Text(formatShortDay(d.date),
                    style: AppText.body(12, color: AppColors.ink2)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 24),
      ],
    ]);
  }
}

class _QuotaCard extends ConsumerWidget {
  const _QuotaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final families = ref.watch(userFamiliesProvider).value ?? const [];
    final owned = families.where((f) => f.ownerId == user?.uid);
    final used = owned.fold<int>(0, (a, f) => a + f.memberCount);
    final unlimited = isAdmin || (profile?.isPaid ?? false);
    final limit = profile?.memberLimit ?? 0;
    final ratio = unlimited || limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    const soft = AppColors.onPrimarySoft;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.t.quotaTitle, style: AppText.body(13, color: soft)),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic, children: [
                Text('$used', style: AppText.display(34, color: Colors.white)),
                const SizedBox(width: 4),
                Text(unlimited ? context.t.quotaUnlimited : '/ $limit',
                    style: AppText.body(16, weight: FontWeight.w600, color: soft)),
              ]),
            ]),
          ),
          if (!unlimited && user != null)
            Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showLimitSheet(context,
                    familyId: owned.firstOrNull?.familyId ?? user.uid,
                    reason: AddCheck.memberLimit),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(children: [
                    const Icon(Icons.chat_outlined, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(context.t.quotaAdd, style: AppText.body(13,
                        weight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: unlimited ? 1 : ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              color: AppColors.onPrimarySoft,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isAdmin
              ? context.t.quotaSuperAdmin
              : unlimited
                  ? planLabel(context, profile!.effectivePlan)
                  : context.t.quotaLeft((limit - used).clamp(0, limit)),
          style: AppText.body(12, color: soft),
        ),
      ]),
    );
  }
}

class _FamilyCard extends ConsumerWidget {
  const _FamilyCard({required this.family});
  final FamilyModel family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final role = family.roleOf(uid);
    final index = ref.watch(familyIndexProvider(family.familyId));
    final preview = index?.dfs().take(3).toList() ?? const [];
    final isOwner = role == FamilyRole.owner;

    return AppCard(
      onTap: () {
        ref.read(selectedFamilyIdProvider.notifier).select(family.familyId);
        context.go(AppRoutes.tree);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(family.name, style: AppText.display(21))),
          if (role != null)
            isOwner ? Pill.gold(role.label) : Pill(role.label),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          SizedBox(
            height: 32,
            width: 32.0 + 24 * preview.length,
            child: Stack(children: [
              for (var i = 0; i < preview.length; i++)
                Positioned(
                  left: i * 24.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: MemberAvatar(name: preview[i].fullName,
                        photo: preview[i].photoThumb, size: 28, ring: false),
                  ),
                ),
              Positioned(
                left: preview.length * 24.0,
                child: Container(
                  width: 32, height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOwner ? AppColors.primary : AppColors.ink3,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ]),
          ),
          const Spacer(),
          Text(
            context.t.membersCount(family.memberCount) +
                (index != null ? ' · ${context.t.generationsCount(index.maxGeneration)}' : ''),
            style: AppText.body(13, weight: FontWeight.w600, color: AppColors.ink2),
          ),
        ]),
      ]),
    );
  }
}

/// Shown to a new account before it has any tree (e.g. a relative who is
/// about to enter an invite code).
class _EmptyWelcome extends StatelessWidget {
  const _EmptyWelcome();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.waving_hand_outlined, color: AppColors.gold),
          const SizedBox(height: 10),
          Text(context.t.homeWelcomeTitle, style: AppText.display(20)),
          const SizedBox(height: 6),
          Text(
            context.t.homeWelcomeBody,
            style: AppText.body(14, color: AppColors.ink2, height: 1.45),
          ),
        ]),
      );
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}

class _NewTreeDialog extends StatefulWidget {
  const _NewTreeDialog();

  @override
  State<_NewTreeDialog> createState() => _NewTreeDialogState();
}

class _NewTreeDialogState extends State<_NewTreeDialog> {
  final _name = TextEditingController();
  final _root = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _root.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.t.newTreeTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name,
              decoration: InputDecoration(hintText: context.t.newTreeName)),
          const SizedBox(height: 12),
          TextField(controller: _root,
              decoration: InputDecoration(hintText: context.t.newTreeRoot)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t.cancel)),
          TextButton(
            onPressed: () {
              if (_name.text.trim().isEmpty || _root.text.trim().isEmpty) return;
              Navigator.pop(context, (_name.text.trim(), _root.text.trim()));
            },
            child: Text(context.t.create),
          ),
        ],
      );
}
