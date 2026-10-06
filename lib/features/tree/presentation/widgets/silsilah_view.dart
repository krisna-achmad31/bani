import 'dart:async';
import 'dart:math' as math;

import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SilsilahView — the tree as an indented list that grows downward, so it
//  reads on a portrait phone without sideways panning (bani.pen 04a).
//  Each generation is one indent column; branch lines join parent to child.
//  Big trees start with deep branches folded, except the path to the user.
// ─────────────────────────────────────────────────────────────────────────────

class SilsilahView extends StatefulWidget {
  const SilsilahView({
    super.key,
    required this.index,
    required this.onOpen,
    required this.onActions,
    this.rootId,
    this.meId,
    this.isMe = _never,
    this.atLimit = _never,
  });

  final FamilyIndex index;

  /// Show only this member's branch.
  final String? rootId;

  /// Member the user is (claimed or grant anchor); kept unfolded.
  final String? meId;
  final bool Function(MemberModel) isMe;
  final bool Function(MemberModel) atLimit;
  final ValueChanged<MemberModel> onOpen;
  final ValueChanged<MemberModel> onActions;

  static bool _never(MemberModel _) => false;

  @override
  State<SilsilahView> createState() => SilsilahViewState();
}

class _Row {
  const _Row(this.member, this.depth, this.rails, this.last, this.hasKids, this.open);
  final MemberModel member;
  final int depth;

  /// rails[k]: the line of indent column k runs through this row.
  final List<bool> rails;
  final bool last;
  final bool hasKids;
  final bool open;
}

class SilsilahViewState extends State<SilsilahView> {
  static const rowHeight = 58.0;
  static const _avatar = 36.0;
  static const _left = 20.0;

  final _scroll = ScrollController();
  var _collapsed = <String>{};
  Object? _initFor;
  String? _flash;
  Timer? _flashTimer;

  /// Deepest generation shown, picked on the ruler; null = no limit.
  int? _limit;

  @override
  void dispose() {
    _scroll.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  List<MemberModel> get _tops {
    final r = widget.rootId == null ? null : widget.index.byId[widget.rootId];
    return r != null ? [r] : widget.index.roots;
  }

  /// Folds generations 3+ of big trees, but never the user's own lineage.
  void _initCollapsed() {
    final key = (widget.rootId, widget.index.byId.isEmpty);
    if (_initFor == key) return;
    _initFor = key;
    final all = widget.index.dfs(widget.rootId);
    if (all.length <= 40) {
      _collapsed = {};
      return;
    }
    final me = widget.meId == null ? null : widget.index.byId[widget.meId];
    final keep = {...?me?.ancestors};
    final base = _tops.firstOrNull?.generation ?? 1;
    _collapsed = {
      for (final m in all)
        if (m.generation - base >= 2 &&
            !keep.contains(m.memberId) &&
            widget.index.childrenOf(m.memberId).isNotEmpty)
          m.memberId,
    };
  }

  List<_Row> _rows() {
    final out = <_Row>[];
    void visit(MemberModel m, int depth, List<bool> rails, bool last) {
      final kids = widget.index.childrenOf(m.memberId);
      final open = kids.isNotEmpty && !_collapsed.contains(m.memberId);
      out.add(_Row(m, depth, rails, last, kids.isNotEmpty, open));
      if (!open) return;
      final childRails = depth == 0 ? const <bool>[] : [...rails, !last];
      for (var i = 0; i < kids.length; i++) {
        visit(kids[i], depth + 1, childRails, i == kids.length - 1);
      }
    }

    final tops = _tops;
    for (var i = 0; i < tops.length; i++) {
      visit(tops[i], 0, const [], true);
    }
    return out;
  }

  /// Shows generations down to [generation] and folds everything below, so
  /// a deep tree keeps wide indents. Tapping the same number again unfolds.
  void showUpTo(int generation) => setState(() {
        if (_limit == generation) {
          _limit = null;
          _collapsed = {};
          return;
        }
        _limit = generation;
        _collapsed = {
          for (final m in widget.index.dfs(widget.rootId))
            if (m.generation >= generation && widget.index.childrenOf(m.memberId).isNotEmpty)
              m.memberId,
        };
      });

  void _toggle(String id) => setState(() {
        if (!_collapsed.remove(id)) _collapsed.add(id);
      });

  void expandAll() => setState(() {
        _collapsed = {};
        _limit = null;
      });

  void collapseAll() => setState(() {
        _limit = null;
        final base = _tops.firstOrNull?.generation ?? 1;
        _collapsed = {
          for (final m in widget.index.dfs(widget.rootId))
            if (m.generation - base >= 1 && widget.index.childrenOf(m.memberId).isNotEmpty)
              m.memberId,
        };
      });

  /// Unfolds the path to [id], scrolls to it and highlights it briefly.
  void reveal(String id) {
    final m = widget.index.byId[id];
    if (m == null) return;
    setState(() {
      _collapsed.removeAll(m.ancestors);
      _flash = id;
    });
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _flash = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final i = _rows().indexWhere((r) => r.member.memberId == id);
      if (i < 0) return;
      final pos = _scroll.position;
      final target = (i * rowHeight - pos.viewportDimension / 3)
          .clamp(0.0, pos.maxScrollExtent);
      _scroll.animateTo(target,
          duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    });
  }

  @override
  Widget build(BuildContext context) {
    _initCollapsed();
    final rows = _rows();
    final maxDepth = rows.fold<int>(0, (a, r) => math.max(a, r.depth));
    final me = widget.meId == null ? null : widget.index.byId[widget.meId];
    final base = _tops.firstOrNull?.generation ?? 1;

    return LayoutBuilder(builder: (context, box) {
      // Indent shrinks for deep trees so names keep room on narrow phones.
      final indent = maxDepth == 0
          ? 30.0
          : ((box.maxWidth - _left - 200) / maxDepth).clamp(14.0, 30.0);
      double x(int k) => _left + _avatar / 2 + k * indent;

      return Column(children: [
        _Ruler(
          // Keep every generation of the tree tappable, not only the open ones.
          columns: math.max(maxDepth + 1, widget.index.maxGeneration - base + 1),
          x: x,
          base: base,
          myGeneration: me?.generation,
          limit: _limit,
          onTap: showUpTo,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.only(top: 6, bottom: 140),
            itemExtent: rowHeight,
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              return _SilsilahRow(
                row: r,
                x: x,
                isMe: widget.isMe(r.member),
                atLimit: widget.atLimit(r.member),
                flash: _flash == r.member.memberId,
                hidden: widget.index.descendantCount[r.member.memberId] ?? 0,
                onTap: () => widget.onOpen(r.member),
                onLongPress: () => widget.onActions(r.member),
                onToggle: () => _toggle(r.member.memberId),
              );
            },
          ),
        ),
      ]);
    });
  }
}

class _Ruler extends StatelessWidget {
  const _Ruler({
    required this.columns,
    required this.x,
    required this.base,
    required this.myGeneration,
    required this.limit,
    required this.onTap,
  });

  final int columns;
  final double Function(int) x;
  final int base;
  final int? myGeneration;
  final int? limit;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final label = limit != null
        ? context.t.silsilahUpTo(limit!)
        : myGeneration != null
            ? context.t.silsilahMyGeneration(myGeneration!)
            : context.t.silsilahTapGeneration;
    // Dots sit on the indent columns while those are wide enough; deep trees
    // spread them at a fixed step and the row scrolls sideways instead.
    final step = math.max(x(1) - x(0), 30.0);
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: x(0) - 20 - step / 2),
        child: Row(children: [
          for (var k = 0; k < columns; k++)
            SizedBox(
              width: step,
              child: _GenDot(
                n: base + k,
                mine: myGeneration == base + k,
                selected: limit == base + k,
                faded: limit != null && base + k > limit!,
                onTap: () => onTap(base + k),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Text(
              label,
              style: AppText.body(12,
                  weight: FontWeight.w600,
                  color: limit != null ? AppColors.primary : AppColors.ink2),
            ),
          ),
        ]),
      ),
    );
  }
}

/// One generation on the ruler; the whole column cell is the tap target.
class _GenDot extends StatelessWidget {
  const _GenDot({
    required this.n,
    required this.mine,
    required this.selected,
    required this.faded,
    required this.onTap,
  });

  final int n;
  final bool mine;
  final bool selected;
  final bool faded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: context.t.silsilahUpTo(n),
        child: InkResponse(
          onTap: onTap,
          radius: 20,
          child: SizedBox(
            height: 34,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: faded ? 0.35 : 1,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mine ? AppColors.primary : AppColors.surface,
                    border: selected
                        ? Border.all(color: AppColors.ink, width: 2)
                        : mine
                            ? null
                            : Border.all(color: AppColors.branch),
                  ),
                  child: Text('$n',
                      style: AppText.body(11,
                          weight: FontWeight.w700,
                          color: mine ? Colors.white : AppColors.primary)),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SilsilahRow extends StatelessWidget {
  const _SilsilahRow({
    required this.row,
    required this.x,
    required this.isMe,
    required this.atLimit,
    required this.flash,
    required this.hidden,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
  });

  final _Row row;
  final double Function(int) x;
  final bool isMe;
  final bool atLimit;
  final bool flash;

  /// Descendants behind the fold when collapsed.
  final int hidden;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;

  String _meta(BuildContext context) {
    final m = row.member;
    final born = m.birthDate?.year;
    final died = m.deathDate?.year;
    final years = m.isDeceased
        ? (born != null && died != null
            ? '$born–$died'
            : born != null
                ? '$born, ${context.t.deceasedShort}'
                : context.t.deceasedShort)
        : (born?.toString() ?? '');
    final spouse = m.spouses.firstOrNull?.name;
    return [
      if (years.isNotEmpty) years,
      if (isMe) context.t.silsilahThisIsYou,
      if (spouse != null && spouse.isNotEmpty) '& $spouse',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final m = row.member;
    final cx = x(row.depth);
    final meta = _meta(context);
    final name = m.nickname?.isNotEmpty == true ? m.nickname! : m.fullName;

    return Semantics(
      button: true,
      label: '$name, ${context.t.generation(m.generation)}',
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(children: [
          Positioned.fill(
            child: CustomPaint(painter: _RailPainter(row: row, x: x)),
          ),
          if (isMe || flash)
            Positioned(
              left: cx - SilsilahViewState._avatar / 2 - 6,
              right: 12,
              top: 4,
              bottom: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: flash ? AppColors.goldSoft : AppColors.primarySoft,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(26), right: Radius.circular(12)),
                ),
              ),
            ),
          Positioned(
            left: cx - SilsilahViewState._avatar / 2,
            right: 12,
            top: 0,
            bottom: 0,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMe ? AppColors.primarySoft : AppColors.bg,
                ),
                child: isMe
                    ? MemberAvatar(
                        name: m.fullName,
                        photo: m.photoThumb,
                        size: SilsilahViewState._avatar - 4,
                        ring: false,
                        background: AppColors.primary,
                        foreground: Colors.white)
                    : MemberAvatar(
                        name: m.fullName,
                        photo: m.photoThumb,
                        size: SilsilahViewState._avatar - 4,
                        ring: false,
                        deceased: m.isDeceased),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(15, weight: FontWeight.w700)),
                      ),
                      if (m.isClaimed) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                      ],
                      if (atLimit) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_rounded, size: 13, color: AppColors.gold),
                      ],
                    ]),
                    if (meta.isNotEmpty)
                      Text(meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12,
                              weight: isMe ? FontWeight.w600 : FontWeight.w400,
                              color: isMe ? AppColors.primary : AppColors.ink2)),
                  ],
                ),
              ),
              if (row.hasKids && !row.open)
                _ExpandPill(count: hidden, onTap: onToggle)
              else if (row.open && row.depth > 0)
                IconButton(
                  onPressed: onToggle,
                  tooltip: context.t.silsilahCollapse,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.expand_less_rounded, color: AppColors.ink3, size: 20),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ExpandPill extends StatelessWidget {
  const _ExpandPill({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: context.t.silsilahExpand(count),
        child: Material(
          color: AppColors.surface,
          shape: const StadiumBorder(side: BorderSide(color: AppColors.line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('+$count',
                    style: AppText.body(12, weight: FontWeight.w700, color: AppColors.ink2)),
                const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.ink2),
              ]),
            ),
          ),
        ),
      );
}

/// Branch lines for one row: pass-through rails of ancestors, the elbow from
/// the parent's column, and the stem down to this member's first child.
class _RailPainter extends CustomPainter {
  _RailPainter({required this.row, required this.x});
  final _Row row;
  final double Function(int) x;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.branch
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final h = size.height, cy = h / 2;
    const r = SilsilahViewState._avatar / 2, bend = 9.0;
    final path = Path();
    for (var k = 0; k < row.rails.length; k++) {
      if (row.rails[k]) {
        path
          ..moveTo(x(k), 0)
          ..lineTo(x(k), h);
      }
    }
    if (row.depth > 0) {
      final px = x(row.depth - 1);
      path
        ..moveTo(px, 0)
        ..lineTo(px, cy - bend)
        ..quadraticBezierTo(px, cy, px + bend, cy)
        ..lineTo(x(row.depth) - r, cy);
      if (!row.last) {
        path
          ..moveTo(px, cy - bend)
          ..lineTo(px, h);
      }
    }
    if (row.open) {
      path
        ..moveTo(x(row.depth), cy + r)
        ..lineTo(x(row.depth), h);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.row != row || old.x(1) != x(1);
}
