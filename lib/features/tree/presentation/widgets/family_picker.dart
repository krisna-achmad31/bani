import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the user switch the tree shown in Pohon, Acara and Undang.
Future<void> showFamilyPicker(BuildContext context, WidgetRef ref,
    {required String current}) async {
  final families = ref.read(userFamiliesProvider).value ?? const [];
  if (families.length < 2) return;
  final picked = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        for (final f in families)
          ListTile(
            title: Text(f.name, style: AppText.body(16, weight: FontWeight.w600)),
            subtitle: Text(context.t.membersCount(f.memberCount)),
            trailing: f.familyId == current
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () => Navigator.pop(ctx, f.familyId),
          ),
      ]),
    ),
  );
  if (picked != null) ref.read(selectedFamilyIdProvider.notifier).select(picked);
}
