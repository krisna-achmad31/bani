import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FocusView — one person at a time: parent above, children below, siblings
//  one swipe away (bani.pen 04b). Tapping a relative moves the focus to them.
// ─────────────────────────────────────────────────────────────────────────────

class FocusView extends StatefulWidget {
  const FocusView({
    super.key,
    required this.index,
    required this.onOpen,
    required this.onAddChild,
    this.rootId,
    this.initialId,
    this.isMe = _never,
    this.canAddChild = _never,
  });

  final FamilyIndex index;

  /// Limits the lineage crumbs to this branch.
  final String? rootId;
  final String? initialId;
  final bool Function(MemberModel) isMe;
  final bool Function(MemberModel) canAddChild;
  final ValueChanged<MemberModel> onOpen;
  final ValueChanged<MemberModel> onAddChild;

  static bool _never(MemberModel _) => false;

  @override
  State<FocusView> createState() => FocusViewState();
}

class FocusViewState extends State<FocusView> {
  String? _id;

  void focus(String id) => setState(() => _id = id);

  MemberModel? get _current {
    final i = widget.index;
    return i.byId[_id] ??
        i.byId[widget.initialId] ??
        i.byId[widget.rootId] ??
        i.roots.firstOrNull;
  }

  List<MemberModel> _siblings(MemberModel m) => m.parentId == null
      ? widget.index.roots
      : widget.index.childrenOf(m.parentId!);

  @override
  Widget build(BuildContext context) {
    final m = _current;
    if (m == null) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _content(context, m),
    );
  }

  Widget _content(BuildContext context, MemberModel m) {
    final t = context.t;
    final index = widget.index;
    var lineage = index.lineage(m);
    final start = lineage.indexWhere((x) => x.memberId == widget.rootId);
    if (start > 0) lineage = lineage.sublist(start);
    final parent = index.parentOf(m);
    final showParent = parent != null && (widget.rootId == null || m.memberId != widget.rootId);
    final siblings = _siblings(m);
    final pos = siblings.indexOf(m);
    final kids = index.childrenOf(m.memberId);

    return ListView(
      key: ValueKey(m.memberId),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
      children: [
        if (lineage.length > 1)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: false,
              itemCount: lineage.length,
              separatorBuilder: (_, _) =>
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.ink3),
              itemBuilder: (_, i) {
                final a = lineage[i];
                final last = i == lineage.length - 1;
                return Center(
                  child: GestureDetector(
                    onTap: last ? null : () => focus(a.memberId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      child: Text(_short(a),
                          style: AppText.body(13,
                              weight: last ? FontWeight.w700 : FontWeight.w500,
                              color: last ? AppColors.ink : AppColors.ink2)),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        if (showParent) ...[
          _PersonTile(
            member: parent,
            subtitle: parent.spouses.firstOrNull?.name.isNotEmpty == true
                ? t.focusParentWith(parent.spouses.first.name)
                : t.focusParent,
            onTap: () => focus(parent.memberId),
            compact: true,
          ),
          Center(child: Container(width: 1.5, height: 22, color: AppColors.branch)),
        ],
        _FocusCard(
          member: m,
          index: index,
          isMe: widget.isMe(m),
          canAddChild: widget.canAddChild(m),
          onOpen: () => widget.onOpen(m),
          onAddChild: () => widget.onAddChild(m),
        ),
        if (siblings.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(children: [
              _SiblingButton(
                label: pos > 0 ? _short(siblings[pos - 1]) : null,
                back: true,
                onTap: pos > 0 ? () => focus(siblings[pos - 1].memberId) : null,
              ),
              Expanded(
                child: Text(t.focusSibling(pos + 1, siblings.length),
                    textAlign: TextAlign.center,
                    style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ink3)),
              ),
              _SiblingButton(
                label: pos < siblings.length - 1 ? _short(siblings[pos + 1]) : null,
                back: false,
                onTap: pos < siblings.length - 1
                    ? () => focus(siblings[pos + 1].memberId)
                    : null,
              ),
            ]),
          ),
        const SizedBox(height: 22),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(t.detailChildren(kids.length), style: AppText.display(18))),
          if (kids.isNotEmpty)
            Text(t.focusTapHint, style: AppText.body(12, color: AppColors.ink3)),
        ]),
        const SizedBox(height: 10),
        if (kids.isEmpty)
          Text(t.detailNoChildren, style: AppText.body(14, color: AppColors.ink3))
        else
          for (final k in kids) ...[
            _PersonTile(
              member: k,
              highlight: widget.isMe(k),
              subtitle: _kidMeta(context, k),
              onTap: () => focus(k.memberId),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  String _short(MemberModel m) =>
      m.nickname?.isNotEmpty == true ? m.nickname! : m.fullName;

  String _kidMeta(BuildContext context, MemberModel k) {
    final n = widget.index.childrenOf(k.memberId).length;
    return [
      if (k.birthDate != null) '${k.birthDate!.year}',
      if (k.isDeceased) context.t.deceasedShort,
      if (widget.isMe(k)) context.t.silsilahThisIsYou,
      if (n > 0) context.t.focusChildCount(n),
    ].join(', ');
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.member,
    required this.index,
    required this.isMe,
    required this.canAddChild,
    required this.onOpen,
    required this.onAddChild,
  });

  final MemberModel member;
  final FamilyIndex index;
  final bool isMe;
  final bool canAddChild;
  final VoidCallback onOpen;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final m = member;
    final siblings = m.parentId == null ? index.roots : index.childrenOf(m.parentId!);
    final meta = [
      if (m.birthDate != null) t.focusBorn(m.birthDate!.year),
      if (m.isDeceased) t.deceasedShort,
      if (siblings.length > 1)
        t.focusChildOrder(siblings.indexOf(m) + 1, siblings.length),
      t.generation(m.generation),
    ].join(', ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.branch, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x1F8A4B2A), blurRadius: 28, offset: Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          MemberAvatar(
              name: m.fullName,
              photo: m.photoThumb,
              size: 64,
              ring: false,
              deceased: m.isDeceased),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.fullName, style: AppText.display(26)),
              const SizedBox(height: 2),
              Text(meta, style: AppText.body(13, color: AppColors.ink2, height: 1.35)),
              if (isMe) ...[
                const SizedBox(height: 6),
                Pill(t.silsilahThisIsYou),
              ],
            ]),
          ),
        ]),
        for (final s in m.spouses.where((s) => s.name.isNotEmpty)) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.status == SpouseStatus.married
                      ? t.focusSpouse(s.name)
                      : '${t.focusSpouse(s.name)} (${s.status.label})',
                  style: AppText.body(13, weight: FontWeight.w600),
                ),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: Text(t.focusProfile),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: AppText.body(14, weight: FontWeight.w700),
              ),
            ),
          ),
          if (canAddChild) ...[
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onAddChild,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(t.treeAddChild),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: AppText.body(14, weight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.member,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
    this.compact = false,
  });

  final MemberModel member;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
        color: highlight ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highlight ? BorderSide.none : const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 10),
            child: Row(children: [
              MemberAvatar(
                  name: member.fullName,
                  photo: member.photoThumb,
                  size: compact ? 34 : 38,
                  ring: false,
                  deceased: member.isDeceased),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(compact ? 14 : 15, weight: FontWeight.w700)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12,
                            color: highlight ? AppColors.primary : AppColors.ink2)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
            ]),
          ),
        ),
      );
}

class _SiblingButton extends StatelessWidget {
  const _SiblingButton({required this.label, required this.back, required this.onTap});
  final String? label;
  final bool back;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox(width: 72);
    final icon = Icon(back ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        size: 18, color: AppColors.primary);
    final text = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: Text(label!,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.primary)),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(mainAxisSize: MainAxisSize.min,
            children: back ? [icon, text] : [text, icon]),
      ),
    );
  }
}
