import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/invite_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  02 Klaim undangan — "Apakah ini kamu?"
// ─────────────────────────────────────────────────────────────────────────────

class ClaimInvitePage extends ConsumerStatefulWidget {
  const ClaimInvitePage({super.key, required this.token});
  final String token;

  @override
  ConsumerState<ClaimInvitePage> createState() => _ClaimInvitePageState();
}

class _ClaimInvitePageState extends ConsumerState<ClaimInvitePage> {
  var _busy = false;

  Future<void> _leave() async {
    ref.read(pendingInviteProvider.notifier).set(null);
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _claim(InviteModel invite) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(treeRepositoryProvider).claimInvite(invite, user.uid);
      ref.read(pendingInviteProvider.notifier).set(null);
      ref.read(selectedFamilyIdProvider.notifier).select(invite.familyId);
      if (mounted) {
        showMessage(context, context.t.inviteClaimed);
        context.go(AppRoutes.tree);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(inviteProvider(widget.token));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _leave),
        title: Text(context.t.inviteTitle, style: AppText.body(14,
            weight: FontWeight.w600, color: AppColors.ink2)),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => MessageView(
          icon: Icons.link_off_rounded,
          title: context.t.inviteCannotOpen,
          message: e.toString(),
          action: FilledButton(onPressed: _leave, child: Text(context.t.inviteToHome)),
        ),
        data: (invite) {
          if (invite == null || !invite.isValid) {
            return MessageView(
              icon: Icons.link_off_rounded,
              title: invite == null ? context.t.inviteNotFound : context.t.inviteInvalid,
              message: invite?.isUsed == true
                  ? context.t.inviteUsed
                  : context.t.inviteExpired,
              action: FilledButton(onPressed: _leave, child: Text(context.t.inviteToHome)),
            );
          }
          return _body(invite);
        },
      ),
    );
  }

  Widget _body(InviteModel invite) {
    final t = context.t;
    final access = <(IconData, String)>[
      if (invite.role != FamilyRole.viewer)
        (Icons.edit_note_rounded, t.inviteCanEditSelf),
      if (invite.role == FamilyRole.contributor)
        (Icons.account_tree_outlined, invite.maxGeneration == null
            ? t.inviteCanAddKids
            : t.inviteCanAddKidsUntil(invite.maxGeneration!)),
      if (invite.role == FamilyRole.admin)
        (Icons.admin_panel_settings_outlined, t.inviteCanManage),
      (Icons.visibility_outlined, t.inviteCanView(invite.familyName)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Row(children: [
          MemberAvatar(name: invite.createdByName, size: 40, ring: false,
              background: AppColors.goldSoft, foreground: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.inviteFrom(invite.createdByName, invite.familyName),
              style: AppText.body(14, color: AppColors.ink2, height: 1.45),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Column(children: [
            MemberAvatar(name: invite.memberName, size: 88),
            const SizedBox(height: 14),
            Text(t.inviteIsThisYou, style: AppText.body(13,
                weight: FontWeight.w600, color: AppColors.gold)),
            const SizedBox(height: 4),
            Text(invite.memberName, textAlign: TextAlign.center, style: AppText.display(26)),
            const SizedBox(height: 4),
            Text('${t.generation(invite.memberGeneration)} · ${invite.role.label}',
                style: AppText.body(14, color: AppColors.ink2)),
          ]),
        ),
        const SizedBox(height: 20),
        Text(t.inviteAfterClaim, style: AppText.body(15, weight: FontWeight.w700)),
        const SizedBox(height: 14),
        for (final (icon, text) in access)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: AppText.body(14, height: 1.4))),
            ]),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _busy ? null : () => _claim(invite),
          icon: const Icon(Icons.check_rounded),
          label: Text(_busy ? t.saving : t.inviteYesMe),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _busy ? null : _leave,
          style: TextButton.styleFrom(foregroundColor: AppColors.ink2),
          child: Text(t.inviteNotMe, style: AppText.body(15)),
        ),
      ],
    );
  }
}
