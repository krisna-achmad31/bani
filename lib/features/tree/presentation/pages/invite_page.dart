import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/services/launcher_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/invite_model.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/data/repositories/tree_repository.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  08 Undang & akses
// ─────────────────────────────────────────────────────────────────────────────

String inviteLink(String token) => '${AppConstants.inviteBaseUrl}?t=$token';

class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  String? _memberId;
  var _role = FamilyRole.contributor;
  var _busy = false;
  String? _lastQueryMember;

  @override
  Widget build(BuildContext context) {
    final fid = ref.watch(activeFamilyIdProvider);
    final queryMember = GoRouterState.of(context).uri.queryParameters['m'];
    if (queryMember != null && queryMember != _lastQueryMember) {
      _lastQueryMember = queryMember;
      _memberId = queryMember;
    }
    if (fid == null) {
      return MessageView(icon: Icons.account_tree_outlined, title: context.t.treeEmptyTitle);
    }
    final family = ref.watch(familyProvider(fid)).value;
    final access = ref.watch(accessProvider(fid));
    final index = ref.watch(familyIndexProvider(fid));
    final config = ref.watch(configProvider).value;
    final depth = config?.defaultBranchDepth ?? AppConstants.defaultBranchDepth;
    final target = index?.byId[_memberId];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          ScreenTitle(context.t.invPageTitle, subtitle: family?.name),
          const SizedBox(height: 6),
          Text(context.t.invPageBody(depth),
              style: AppText.body(14, color: AppColors.ink2, height: 1.45)),
          const SizedBox(height: 20),
          if (!access.canManage)
            AppCard(
              child: Row(children: [
                const Icon(Icons.lock_outline, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(child: Text(
                    context.t.invOnlyManagers,
                    style: AppText.body(14, color: AppColors.ink2, height: 1.45))),
              ]),
            )
          else ...[
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FieldLabel(context.t.invForWho),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: index == null ? null : () => _pickMember(index),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      MemberAvatar(name: target?.fullName ?? '?', photo: target?.photoThumb,
                          size: 40, ring: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(target?.fullName ?? context.t.invPickMember,
                              style: AppText.body(15, weight: FontWeight.w700)),
                          Text(target == null
                              ? context.t.invPickMemberHint
                              : '${context.t.generation(target.generation)} · '
                                  '${target.isClaimed ? context.t.invClaimed : context.t.invUnclaimed}',
                              style: AppText.body(12, color: AppColors.ink2)),
                        ]),
                      ),
                      const Icon(Icons.expand_more, color: AppColors.ink3),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                Segmented<FamilyRole>(
                  options: [
                    FamilyRole.contributor,
                    FamilyRole.viewer,
                    if (access.isOwner || access.isSuperAdmin) FamilyRole.admin,
                  ],
                  value: _role,
                  labelOf: (r) => r.label,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.account_tree_outlined, size: 16, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    switch (_role) {
                      FamilyRole.contributor => target == null
                          ? context.t.invContributorDepth(depth, AppConstants.inviteExpiryDays)
                          : context.t.invContributorUntil(
                              target.generation + depth, AppConstants.inviteExpiryDays),
                      FamilyRole.admin => context.t.invAdminHint,
                      _ => context.t.invViewerHint,
                    },
                    style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ink2),
                  )),
                ]),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy || target == null || family == null
                      ? null
                      : () => _send(family, target, depth),
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: Text(_busy ? context.t.invCreating : context.t.invCreate),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            _PendingInvites(familyId: fid),
            _ActiveAccess(familyId: fid, index: index),
          ],
        ],
      ),
    );
  }

  Future<void> _pickMember(FamilyIndex index) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, scroll) => ListView(
          controller: scroll,
          children: [
            for (final m in index.dfs())
              ListTile(
                leading: MemberAvatar(name: m.fullName, photo: m.photoThumb, size: 36, ring: false),
                title: Text(m.fullName),
                subtitle: Text(context.t.generation(m.generation) +
                    (m.isClaimed ? ' · ${context.t.invClaimed}' : '')),
                enabled: !m.isClaimed,
                onTap: () => Navigator.pop(ctx, m.memberId),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _memberId = picked);
  }

  Future<void> _send(FamilyModel family, MemberModel member, int depth) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      // Trees of paid owners have no branch-depth limit for contributors.
      final invite = await ref.read(treeRepositoryProvider).createInvite(
          family: family,
          member: member,
          role: _role,
          maxDepth: family.ownerPaid ? null : depth,
          creator: user);
      if (mounted) await showInviteCodeSheet(context, invite);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

String inviteMessage(InviteModel invite) =>
    tr.invMessage(invite.memberName.split(' ').first, invite.familyName,
        formatInviteCode(invite.token), AppConstants.inviteExpiryDays, inviteLink(invite.token));

/// Shows the short code big, with WhatsApp / copy actions.
Future<void> showInviteCodeSheet(BuildContext context, InviteModel invite) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(ctx.t.invCodeFor, style: AppText.body(13, color: AppColors.ink2)),
            const SizedBox(height: 2),
            Text(invite.memberName, textAlign: TextAlign.center, style: AppText.display(22)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SelectableText(
                formatInviteCode(invite.token),
                textAlign: TextAlign.center,
                style: AppText.display(34, color: AppColors.ink).copyWith(letterSpacing: 4),
              ),
            ),
            const SizedBox(height: 8),
            Text(ctx.t.invCodeMeta(invite.role.label, AppConstants.inviteExpiryDays),
                style: AppText.body(12, color: AppColors.ink3)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => LauncherService.whatsapp('', text: inviteMessage(invite)),
              icon: const Icon(Icons.chat_outlined),
              label: Text(ctx.t.invSendWhatsapp),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: formatInviteCode(invite.token)));
                if (ctx.mounted) showMessage(ctx, ctx.t.invCodeCopied);
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(ctx.t.invCopyCode),
            ),
          ]),
        ),
      ),
    );

class _PendingInvites extends ConsumerWidget {
  const _PendingInvites({required this.familyId});
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = (ref.watch(invitesProvider(familyId)).value ?? const <InviteModel>[])
        .where((i) => i.isValid)
        .toList();
    if (invites.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel(context.t.invSent,
          trailing: Text('${invites.length}', style: AppText.body(13, color: AppColors.ink3))),
      const SizedBox(height: 12),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (final i in invites)
            ListTile(
              leading: MemberAvatar(name: i.memberName, size: 40, ring: false,
                  background: AppColors.surface2, foreground: AppColors.ink3),
              title: Text(i.memberName, style: AppText.body(15, weight: FontWeight.w700)),
              subtitle: Text(context.t.invSentMeta(i.role.label, formatInviteCode(i.token))),
              onTap: () => showInviteCodeSheet(context, i),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Pill.gold(context.t.invDaysLeft(i.expiresAt.difference(DateTime.now()).inDays + 1)),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'copy') {
                      await Clipboard.setData(
                          ClipboardData(text: formatInviteCode(i.token)));
                      if (context.mounted) showMessage(context, context.t.invCodeCopied);
                    } else {
                      await ref.read(treeRepositoryProvider).cancelInvite(i.token);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'copy', child: Text(context.t.invCopyCode)),
                    PopupMenuItem(value: 'cancel', child: Text(context.t.invCancel)),
                  ],
                ),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

class _ActiveAccess extends ConsumerWidget {
  const _ActiveAccess({required this.familyId, required this.index});
  final String familyId;
  final FamilyIndex? index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider)?.uid;
    final access = ref.watch(accessProvider(familyId));
    final grants = (ref.watch(grantsProvider(familyId)).value ?? const <GrantModel>[])
        .where((g) => g.uid != me)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel(context.t.invActive,
          trailing: Text(context.t.peopleCount(grants.length), style: AppText.body(13, color: AppColors.ink3))),
      const SizedBox(height: 12),
      if (grants.isEmpty)
        Text(context.t.invNoneYet, style: AppText.body(14, color: AppColors.ink3))
      else
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (final g in grants)
              Builder(builder: (context) {
                final m = index?.byId[g.anchorMemberId];
                final name = m?.fullName ?? context.t.invMember;
                return ListTile(
                  leading: MemberAvatar(name: name, photo: m?.photoThumb, size: 40, ring: false),
                  title: Text(name, style: AppText.body(15, weight: FontWeight.w700)),
                  subtitle: Text(g.role == FamilyRole.contributor && g.maxGeneration != null
                      ? context.t.invUntilGen(g.role.label, g.maxGeneration!)
                      : g.role.label),
                  trailing: Pill(g.role == FamilyRole.owner ? context.t.roleOwner : context.t.invStatusActive),
                  onTap: g.role == FamilyRole.owner || !access.canManage
                      ? null
                      : () => _manage(context, ref, g, name),
                );
              }),
          ]),
        ),
    ]);
  }

  Future<void> _manage(BuildContext context, WidgetRef ref, GrantModel g, String name) async {
    final action = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text(name, style: AppText.body(16, weight: FontWeight.w700))),
          for (final r in [FamilyRole.admin, FamilyRole.contributor, FamilyRole.viewer])
            ListTile(
              leading: Icon(g.role == r ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: AppColors.primary),
              title: Text(r.label),
              onTap: () => Navigator.pop(ctx, r),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_remove_outlined, color: AppColors.danger),
            title: Text(context.t.invRevoke, style: const TextStyle(color: AppColors.danger)),
            onTap: () => Navigator.pop(ctx, 'revoke'),
          ),
        ]),
      ),
    );
    if (action == null) return;
    final repo = ref.read(treeRepositoryProvider);
    try {
      if (action == 'revoke') {
        await repo.revokeAccess(familyId, g.uid);
      } else if (action is FamilyRole && action != g.role) {
        await repo.setRole(familyId, g.uid, action);
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}
