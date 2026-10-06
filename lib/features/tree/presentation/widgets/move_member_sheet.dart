import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Move a member (with all descendants) under another parent — Owner/Admin.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> startMoveMember(
    BuildContext context, WidgetRef ref, String familyId, MemberModel member) async {
  final index = ref.read(familyIndexProvider(familyId));
  if (index == null) return;
  if (member.isRoot) {
    showMessage(context, context.t.moveRootNotAllowed);
    return;
  }
  final subtree = index.dfs(member.memberId);
  final excluded = {for (final m in subtree) m.memberId, member.parentId};
  final candidates = index.dfs().where((m) => !excluded.contains(m.memberId)).toList();

  final target = await showModalBottomSheet<MemberModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ParentPicker(member: member, candidates: candidates, index: index),
  );
  if (target == null || !context.mounted) return;

  final descendants = subtree.length - 1;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.t.moveConfirmTitle),
      content: Text(
        descendants > 0
            ? context.t.moveConfirmBodyWithKids(
                member.fullName, descendants, target.fullName, target.generation + 1)
            : context.t.moveConfirmBody(member.fullName, target.fullName, target.generation + 1),
        style: AppText.body(14, height: 1.45),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.cancel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.t.moveDo)),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  try {
    await ref.read(treeRepositoryProvider).moveMember(
        familyId: familyId, member: member, newParent: target, index: index);
    if (context.mounted) {
      showMessage(context, context.t.moveDone(member.fullName, target.fullName));
    }
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _ParentPicker extends StatefulWidget {
  const _ParentPicker({required this.member, required this.candidates, required this.index});
  final MemberModel member;
  final List<MemberModel> candidates;
  final FamilyIndex index;

  @override
  State<_ParentPicker> createState() => _ParentPickerState();
}

class _ParentPickerState extends State<_ParentPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase().trim();
    final list = widget.candidates
        .where((m) => q.isEmpty || m.fullName.toLowerCase().contains(q))
        .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (_, scroll) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.t.movePickTitle(widget.member.fullName), style: AppText.display(20)),
            const SizedBox(height: 4),
            Text(context.t.movePickHint,
                style: AppText.body(13, color: AppColors.ink2)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: context.t.searchName,
                prefixIcon: const Icon(Icons.search, color: AppColors.ink3),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: scroll,
            itemCount: list.length,
            itemBuilder: (_, i) {
              final m = list[i];
              final parent = widget.index.parentOf(m);
              return ListTile(
                leading: MemberAvatar(name: m.fullName, photo: m.photoThumb, size: 40, ring: false),
                title: Text(m.fullName),
                subtitle: Text(context.t.generation(m.generation) +
                    (parent != null ? ' · ${context.t.childOf(parent.fullName)}' : '')),
                onTap: () => Navigator.pop(context, m),
              );
            },
          ),
        ),
      ]),
    );
  }
}
