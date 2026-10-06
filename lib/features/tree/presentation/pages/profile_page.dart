import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/providers/locale_provider.dart';
import 'package:bani/features/tree/presentation/widgets/feedback_sheet.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/features/tree/data/repositories/legacy_import_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:bani/core/services/excel_export_service.dart';
import 'package:bani/core/services/launcher_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/limit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  10 Profil — account, plan/quota and settings
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final families = ref.watch(userFamiliesProvider).value ?? const <FamilyModel>[];
    final config = ref.watch(configProvider).value;
    final activeId = ref.watch(activeFamilyIdProvider);
    final t = context.t;
    final used = families
        .where((f) => f.ownerId == user?.uid)
        .fold<int>(0, (a, f) => a + f.memberCount);
    final unlimited = isAdmin || (profile?.isPaid ?? false);
    final limit = profile?.memberLimit ?? 0;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Row(children: [
            MemberAvatar(name: user?.displayName ?? '?', size: 68,
                background: AppColors.goldSoft, foreground: AppColors.gold),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.displayName ?? '-', style: AppText.display(22)),
                Text(user?.email ?? '', style: AppText.body(13, color: AppColors.ink2)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                isAdmin
                    ? Pill.gold(t.profileSuperAdmin, icon: Icons.shield_outlined)
                    : unlimited
                        ? Pill.gold(planLabel(context, profile!.effectivePlan),
                            icon: Icons.workspace_premium_outlined)
                        : Pill(t.planFree, icon: Icons.spa_outlined),
                const Spacer(),
                if (!unlimited && user != null)
                  TextButton(
                    onPressed: () => showLimitSheet(context,
                        familyId: families.where((f) => f.ownerId == user.uid)
                                .firstOrNull?.familyId ?? user.uid,
                        reason: AddCheck.memberLimit),
                    child: Text(t.quotaAdd),
                  ),
              ]),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic, children: [
                Text('$used', style: AppText.display(32)),
                const SizedBox(width: 6),
                Text(unlimited ? t.profileUnlimited : t.profileOfLimit(limit),
                    style: AppText.body(14, color: AppColors.ink2)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: unlimited || limit == 0 ? 1 : (used / limit).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.surface2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(t.profileQuotaHint,
                  style: AppText.body(12, color: AppColors.ink3, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 20),
          _group(t.profileSettings, [
            _item(Icons.translate_rounded, t.profileLanguage,
                isEnglish ? t.languageEnglish : t.languageIndonesian,
                () => _pickLanguage(context, ref)),
            _item(Icons.shield_outlined, t.profileContactPrivacy, t.profileContactPrivacyValue, null),
            _item(Icons.table_chart_outlined, t.treeExport, null, activeId == null
                ? null
                : () async {
                    final index = ref.read(familyIndexProvider(activeId));
                    final family = families.where((f) => f.familyId == activeId).firstOrNull;
                    if (index == null || family == null) return;
                    try {
                      await ExcelExportService.export(family.name, index);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  }),
          ]),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            _group(t.profileSuperAdminSection, [
              _item(Icons.inbox_outlined, t.profileFeedbackInbox, null,
                  () => context.push(AppRoutes.feedbackInbox)),
              _item(Icons.move_down_rounded, t.profileImport, null,
                  () => _importLegacy(context, ref)),
            ]),
          ],
          const SizedBox(height: 20),
          _group(t.profileOther, [
            _item(Icons.lightbulb_outline_rounded, t.profileSendFeedback, null,
                () => showFeedbackSheet(context)),
            _item(Icons.chat_outlined, t.profileHelp, null,
                (config?.adminWhatsapp ?? '').isEmpty
                    ? null
                    : () => LauncherService.whatsapp(config!.adminWhatsapp,
                        text: t.profileHelpMessage)),
            _item(Icons.logout, t.profileLogout, null, () async {
              ref.read(selectedFamilyIdProvider.notifier).select(null);
              await ref.read(authRepositoryProvider).signOut();
            }, danger: true),
          ]),
          const SizedBox(height: 20),
          Text(
            t.profileVersion(ref.watch(appVersionProvider).value ?? '...'),
            style: AppText.body(12, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }

  Future<void> _importLegacy(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(legacyImportRepositoryProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(height: 80, child: LoadingView()),
      ),
    );
    LegacyPreview? preview;
    Object? error;
    try {
      preview = await repo.preview();
    } catch (e) {
      error = e;
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (error != null || preview == null) {
      showError(context, error ?? context.t.importReadFailed);
      return;
    }

    final gens = preview.perGeneration;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.importTitle),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(context.t.importFound(preview!.total), style: AppText.body(16, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final e in gens.entries)
              Text(context.t.importPerGen(e.key, e.value), style: AppText.body(14, color: AppColors.ink2)),
            const SizedBox(height: 12),
            Text(context.t.importChildrenOf(preview.root.name), style: AppText.body(13, weight: FontWeight.w700)),
            for (final c in preview.root.children)
              Text('• ${context.t.importKidCount(c.name, c.children.length)}', style: AppText.body(13)),
            const SizedBox(height: 12),
            Text(
              preview.alreadyImported
                  ? context.t.importAlready
                  : context.t.importWillCreate,
              style: AppText.body(12, color: preview.alreadyImported ? AppColors.danger : AppColors.ink3),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.cancel)),
          if (!preview.alreadyImported)
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.t.importDo)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final fid = await repo.commit(preview, user);
      ref.read(selectedFamilyIdProvider.notifier).select(fid);
      if (context.mounted) {
        showMessage(context, context.t.importDone(preview.total));
        context.go(AppRoutes.tree);
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(localeProvider).languageCode;
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final (code, label) in [
            ('id', ctx.t.languageIndonesian),
            ('en', ctx.t.languageEnglish),
          ])
            ListTile(
              leading: Icon(
                  code == current ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: AppColors.primary),
              title: Text(label, style: AppText.body(16, weight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, code),
            ),
        ]),
      ),
    );
    if (picked != null) await ref.read(localeProvider.notifier).set(picked);
  }

  Widget _group(String title, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.body(12, weight: FontWeight.w700, color: AppColors.ink3)
              .copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1) const Divider(),
              ],
            ]),
          ),
        ],
      );

  Widget _item(IconData icon, String label, String? value, VoidCallback? onTap,
          {bool danger = false}) =>
      ListTile(
        minTileHeight: 56,
        leading: Icon(icon, color: danger ? AppColors.danger : AppColors.ink2),
        title: Text(label, style: AppText.body(15, weight: FontWeight.w600,
            color: danger ? AppColors.danger : AppColors.ink)),
        trailing: danger
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (value != null)
                  Text(value, style: AppText.body(13, color: AppColors.ink3)),
                if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.ink3),
              ]),
        onTap: onTap,
      );
}
