import 'dart:math' as math;

import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TreeCanvas — a tidy top-down family tree: leaves side by side, each parent
//  centred over its children, elbow connectors in gold. Zoom/pan via
//  InteractiveViewer. Replaces graphview, which painted nothing on Android.
// ─────────────────────────────────────────────────────────────────────────────

class TreeLayout {
  TreeLayout._(this.positions, this.size, this.edges);

  static const nodeWidth = 104.0;
  static const nodeHeight = 132.0;
  static const hGap = 16.0;
  static const vGap = 44.0;
  static const margin = 24.0;

  /// Top-left of each member's node.
  final Map<String, Offset> positions;
  final Size size;

  /// parentId → children ids (only those laid out).
  final Map<String, List<String>> edges;

  factory TreeLayout.of(FamilyIndex index, {String? rootId}) {
    final positions = <String, Offset>{};
    final edges = <String, List<String>>{};
    var nextSlot = 0.0;
    var maxDepth = 0;

    double place(MemberModel m, int depth) {
      maxDepth = math.max(maxDepth, depth);
      final kids = index.childrenOf(m.memberId);
      double x;
      if (kids.isEmpty) {
        x = nextSlot;
        nextSlot += nodeWidth + hGap;
      } else {
        final xs = [for (final k in kids) place(k, depth + 1)];
        x = (xs.first + xs.last) / 2;
        edges[m.memberId] = [for (final k in kids) k.memberId];
      }
      positions[m.memberId] = Offset(margin + x, margin + depth * (nodeHeight + vGap));
      return x;
    }

    final roots = rootId != null && index.byId.containsKey(rootId)
        ? [index.byId[rootId]!]
        : index.roots;
    for (final r in roots) {
      place(r, 0);
      nextSlot += hGap * 2;
    }
    final width = math.max(nextSlot - hGap, nodeWidth) + margin * 2;
    final height = (maxDepth + 1) * (nodeHeight + vGap) - vGap + margin * 2;
    return TreeLayout._(positions, Size(width, height), edges);
  }

  Offset centerOf(String id) =>
      positions[id]! + const Offset(nodeWidth / 2, nodeHeight / 2);
}

class TreeCanvas extends StatelessWidget {
  const TreeCanvas({
    super.key,
    required this.index,
    required this.layout,
    required this.controller,
    required this.nodeBuilder,
  });

  final FamilyIndex index;
  final TreeLayout layout;
  final TransformationController controller;
  final Widget Function(MemberModel member) nodeBuilder;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(600),
      minScale: 0.15,
      maxScale: 2.5,
      child: SizedBox.fromSize(
        size: layout.size,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _EdgePainter(layout))),
          for (final e in layout.positions.entries)
            Positioned(
              left: e.value.dx,
              top: e.value.dy,
              width: TreeLayout.nodeWidth,
              height: TreeLayout.nodeHeight,
              child: nodeBuilder(index.byId[e.key]!),
            ),
        ]),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter(this.layout);
  final TreeLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.branch
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const w = TreeLayout.nodeWidth, h = TreeLayout.nodeHeight;
    for (final e in layout.edges.entries) {
      final p = layout.positions[e.key]!;
      final top = p.dy + h;
      final midY = top + TreeLayout.vGap / 2;
      final px = p.dx + w / 2;
      final kids = [for (final id in e.value) layout.positions[id]!];
      final path = Path()
        ..moveTo(px, top)
        ..lineTo(px, midY)
        ..moveTo(kids.first.dx + w / 2, midY)
        ..lineTo(kids.last.dx + w / 2, midY);
      for (final k in kids) {
        path
          ..moveTo(k.dx + w / 2, midY)
          ..lineTo(k.dx + w / 2, k.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) => old.layout != layout;
}
