import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/services/launcher_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/tree/data/models/app_config.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LimitSheet — shown when a branch or the tree hits its quota. Prices come
//  from config/app.packages and hide when config/app.showPricing is false.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showLimitSheet(
  BuildContext context, {
  required String familyId,
  required AddCheck reason,
  MemberModel? parent,
}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LimitSheet(familyId: familyId, reason: reason, parent: parent),
    );

class _LimitSheet extends ConsumerStatefulWidget {
  const _LimitSheet({required this.familyId, required this.reason, this.parent});
  final String familyId;
  final AddCheck reason;
  final MemberModel? parent;

  @override
  ConsumerState<_LimitSheet> createState() => _LimitSheetState();
}

class _LimitSheetState extends ConsumerState<_LimitSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(configProvider).value ?? const AppConfig();
    final family = ref.watch(familyProvider(widget.familyId)).value;
    final access = ref.watch(accessProvider(widget.familyId));
    final user = ref.watch(currentUserProvider);
    final isBranch = widget.reason == AddCheck.branchLimit;
    final maxGen = access.grant?.maxGeneration;
    final anchor = access.grant?.anchorMemberId;
    final anchorMember =
        anchor == null ? null : ref.watch(familyIndexProvider(widget.familyId))?.byId[anchor];

    final isAlbum = widget.reason == AddCheck.albumLimit;
    final isTree = widget.reason == AddCheck.treeLimit;

    // Offer what actually lifts this limit; add-ons first, then plans.
    final relevant = switch (widget.reason) {
      AddCheck.branchLimit => {'branch', 'keluarga', 'keluarga_besar'},
      AddCheck.albumLimit => {'photos30', 'keluarga', 'keluarga_besar'},
      AddCheck.treeLimit => {'keluarga_besar'},
      _ => {'keluarga', 'keluarga_besar'},
    };
    final packages = config.packages
        .where((p) => relevant.contains(p.id) || !const {
              'branch', 'photos30', 'keluarga', 'keluarga_besar'
            }.contains(p.id))
        .toList();
    final selected = packages.where((p) => p.id == _selected).firstOrNull ??
        packages.firstOrNull;

    final t = context.t;
    final title = isBranch
        ? t.limitBranchTitle
        : isAlbum
            ? t.albumLimitTitle
            : isTree
                ? t.treeLimitTitle
                : t.limitMemberTitle;
    final body = isBranch
        ? t.limitBranchBody(anchorMember?.fullName.split(' ').first ?? '', maxGen ?? 0)
        : isAlbum
            ? t.albumLimitBody(family?.name ?? '', family?.albumCount ?? 0)
            : isTree
                ? t.treeLimitBody
                : t.limitMemberBody(family?.name ?? '', family?.memberCount ?? 0);

    Future<void> contactAdmin() async {
      final pkg = selected == null
          ? t.limitAddQuota
          : '${selected.title}'
              '${config.showPricing ? ' (${formatRupiah(selected.price)})' : ''}';
      final text = [
        t.limitWaMessage(pkg, family?.name ?? '-', widget.familyId, user?.email ?? '-',
            user?.uid ?? '-'),
        if (isBranch && anchor != null) anchorMember?.fullName ?? anchor,
      ].join('\n');
      if (config.adminWhatsapp.isEmpty) {
        showMessage(context, t.limitNoAdminWa);
        return;
      }
      await LauncherService.whatsapp(config.adminWhatsapp, text: text);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: AppColors.goldSoft, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.gold),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppText.display(22))),
          ]),
          const SizedBox(height: 16),
          Text(body, style: AppText.body(15, color: AppColors.ink2, height: 1.5)),
          if (isBranch && maxGen != null) ...[
            const SizedBox(height: 16),
            _GenerationStrip(maxGeneration: maxGen, anchorGeneration: anchorMember?.generation),
          ],
          if (config.showPricing && packages.isNotEmpty) ...[
            const SizedBox(height: 16),
            FieldLabel(t.limitPickPackage),
            for (final p in packages) ...[
              _PackageTile(package: p, selected: p == selected,
                  onTap: () => setState(() => _selected = p.id)),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: contactAdmin,
            icon: const Icon(Icons.chat_outlined),
            label: Text(config.showPricing && selected != null
                ? t.limitPay(formatRupiah(selected.price))
                : t.limitContactAdmin),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (!access.isOwner)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.limitAskOwner),
                )
              else
                const SizedBox.shrink(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.ink2),
                child: Text(t.later),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.ink3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    t.limitAfterTransfer,
                    style: AppText.body(12, color: AppColors.ink2, height: 1.4)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GenerationStrip extends StatelessWidget {
  const _GenerationStrip({required this.maxGeneration, this.anchorGeneration});
  final int maxGeneration;
  final int? anchorGeneration;

  @override
  Widget build(BuildContext context) {
    final start = anchorGeneration ?? (maxGeneration - 2);
    final gens = [for (var g = start; g <= maxGeneration + 1; g++) g];
    return Row(children: [
      for (final g in gens) ...[
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: g <= maxGeneration ? AppColors.primarySoft : AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Icon(g <= maxGeneration ? Icons.check_rounded : Icons.lock_outline_rounded,
                  size: 16,
                  color: g <= maxGeneration ? AppColors.primary : AppColors.danger),
              const SizedBox(height: 4),
              Text(context.t.limitGen(g), style: AppText.body(13, weight: FontWeight.w700,
                  color: g <= maxGeneration ? AppColors.primary : AppColors.danger)),
            ]),
          ),
        ),
        if (g != gens.last) const SizedBox(width: 6),
      ],
    ]);
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, required this.selected, required this.onTap});
  final PricePackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.line,
                width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(package.title,
                      style: AppText.body(15, weight: FontWeight.w700))),
                  if (package.tagText != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                      child: Text(package.tagText!, style: AppText.body(10,
                          weight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ]),
                Text(package.subtitle, style: AppText.body(12, color: AppColors.ink2)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(formatRupiah(package.price), style: AppText.body(15,
                  weight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.ink)),
              Text(package.periodText, style: AppText.body(11, color: AppColors.ink3)),
            ]),
          ]),
        ),
      );
}
