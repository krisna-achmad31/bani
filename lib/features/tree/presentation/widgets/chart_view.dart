import 'dart:math' as math;

import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/tree_canvas.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ChartView — the classic top-down chart (bani.pen 04c "Bagan"): zoom and
//  pan, good for seeing the shape of the whole family on a wide screen.
// ─────────────────────────────────────────────────────────────────────────────

class ChartView extends StatefulWidget {
  const ChartView({
    super.key,
    required this.index,
    required this.onOpen,
    required this.onActions,
    this.rootId,
    this.isMe = _never,
    this.atLimit = _never,
  });

  final FamilyIndex index;
  final String? rootId;
  final bool Function(MemberModel) isMe;
  final bool Function(MemberModel) atLimit;
  final ValueChanged<MemberModel> onOpen;
  final ValueChanged<MemberModel> onActions;

  static bool _never(MemberModel _) => false;

  @override
  State<ChartView> createState() => ChartViewState();
}

class ChartViewState extends State<ChartView> {
  final _transform = TransformationController();
  final _box = GlobalKey();
  TreeLayout? _layout;
  Object? _layoutKey;
  Object? _fittedFor;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Size get _viewport =>
      (_box.currentContext?.findRenderObject() as RenderBox?)?.size ?? const Size(360, 600);

  TreeLayout _layoutFor() {
    final key = (widget.index, widget.rootId);
    if (_layout != null && _layoutKey == key) return _layout!;
    _layoutKey = key;
    return _layout = TreeLayout.of(widget.index, rootId: widget.rootId);
  }

  /// Scales the whole tree into view (not below a readable minimum).
  void fit() {
    final layout = _layout;
    if (!mounted || layout == null) return;
    final vp = _viewport;
    final s = layout.size;
    final scale =
        math.min((vp.width - 16) / s.width, (vp.height - 140) / s.height).clamp(0.35, 1.0);
    final dx = math.max((vp.width - s.width * scale) / 2, 0.0);
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, 8, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  /// Centres the viewport on [memberId], keeping the current zoom.
  void reveal(String memberId) {
    final layout = _layout;
    if (layout == null || !layout.positions.containsKey(memberId)) return;
    final scale = _transform.value.getMaxScaleOnAxis();
    final c = layout.centerOf(memberId);
    final vp = _viewport;
    _transform.value = Matrix4.identity()
      ..translateByDouble(vp.width / 2 - c.dx * scale, vp.height / 3 - c.dy * scale, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _zoom(double factor) {
    final c = _viewport.center(Offset.zero);
    final m = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(factor, factor, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    _transform.value = m.multiplied(_transform.value);
  }

  @override
  Widget build(BuildContext context) {
    final layout = _layoutFor();
    final fitKey = widget.rootId ?? '';
    if (_fittedFor != fitKey) {
      _fittedFor = fitKey;
      WidgetsBinding.instance.addPostFrameCallback((_) => fit());
    }
    final t = context.t;
    return Container(
      key: _box,
      color: AppColors.surface2,
      child: Stack(children: [
        Positioned.fill(
          child: TreeCanvas(
            index: widget.index,
            layout: layout,
            controller: _transform,
            nodeBuilder: (m) => _MemberNode(
              member: m,
              isMe: widget.isMe(m),
              atLimit: widget.atLimit(m),
              onTap: () => widget.onOpen(m),
              onLongPress: () => widget.onActions(m),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(children: [
              IconButton(
                  tooltip: t.chartZoomIn,
                  icon: const Icon(Icons.add),
                  onPressed: () => _zoom(1.25)),
              IconButton(
                  tooltip: t.chartZoomOut,
                  icon: const Icon(Icons.remove),
                  onPressed: () => _zoom(0.8)),
              IconButton(
                  tooltip: t.chartFit,
                  icon: const Icon(Icons.fit_screen_outlined),
                  onPressed: fit),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MemberNode extends StatelessWidget {
  const _MemberNode({
    required this.member,
    required this.isMe,
    required this.atLimit,
    required this.onTap,
    required this.onLongPress,
  });

  final MemberModel member;
  final bool isMe;
  final bool atLimit;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final year = member.birthDate?.year;
    final meta = [
      if (year != null) '$year',
      if (member.isDeceased) context.t.deceasedShort,
    ].join(' · ');
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 104,
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
        decoration: BoxDecoration(
          color: member.isDeceased ? AppColors.deceasedCard : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe ? AppColors.primary : AppColors.line,
            width: isMe ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x141F2A24), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            MemberAvatar(
              name: member.fullName,
              photo: member.photoThumb,
              size: 44,
              deceased: member.isDeceased,
              ring: member.isRoot || isMe,
            ),
            if (member.isClaimed)
              const Positioned(
                right: -4,
                bottom: -2,
                child: Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
              ),
            if (atLimit)
              const Positioned(
                left: -4,
                bottom: -2,
                child: Icon(Icons.lock_rounded, size: 14, color: AppColors.gold),
              ),
          ]),
          const SizedBox(height: 6),
          Text(member.nickname?.isNotEmpty == true ? member.nickname! : member.fullName,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(12, weight: FontWeight.w700, height: 1.2)),
          if (meta.isNotEmpty) Text(meta, style: AppText.body(10.5, color: AppColors.ink2)),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(context.t.treeMe,
                  style: AppText.body(10, weight: FontWeight.w800, color: AppColors.primary)),
            ),
        ]),
      ),
    );
  }
}
