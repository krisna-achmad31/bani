import 'package:bani/features/tree/data/models/member_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers over the flat member list
// ─────────────────────────────────────────────────────────────────────────────

class FamilyIndex {
  FamilyIndex(List<MemberModel> members)
      : byId = {for (final m in members) m.memberId: m},
        children = _childrenOf(members);

  final Map<String, MemberModel> byId;
  final Map<String?, List<MemberModel>> children;

  static Map<String?, List<MemberModel>> _childrenOf(List<MemberModel> all) {
    final map = <String?, List<MemberModel>>{};
    for (final m in all) {
      map.putIfAbsent(m.parentId, () => []).add(m);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        final o = (a.birthOrder ?? 999).compareTo(b.birthOrder ?? 999);
        return o != 0 ? o : a.fullName.compareTo(b.fullName);
      });
    }
    return map;
  }

  List<MemberModel> get roots => children[null] ?? const [];
  List<MemberModel> childrenOf(String id) => children[id] ?? const [];
  MemberModel? parentOf(MemberModel m) => m.parentId == null ? null : byId[m.parentId];

  /// Depth-first order starting from the roots (or from [rootId]).
  List<MemberModel> dfs([String? rootId]) {
    final out = <MemberModel>[];
    void visit(MemberModel m) {
      out.add(m);
      childrenOf(m.memberId).forEach(visit);
    }

    if (rootId != null) {
      final r = byId[rootId];
      if (r != null) visit(r);
    } else {
      roots.forEach(visit);
    }
    return out;
  }

  /// Ancestor chain from the root down to [m] (inclusive).
  List<MemberModel> lineage(MemberModel m) => [
        ...m.ancestors.map((id) => byId[id]).whereType<MemberModel>(),
        m,
      ];

  int get maxGeneration =>
      byId.values.fold(0, (a, m) => m.generation > a ? m.generation : a);

  bool isInBranch(MemberModel m, String anchorId) =>
      m.memberId == anchorId || m.ancestors.contains(anchorId);

  /// Children, grandchildren, ... below each member.
  late final Map<String, int> descendantCount = _countDescendants();

  Map<String, int> _countDescendants() {
    final out = <String, int>{};
    int count(MemberModel m) {
      var n = 0;
      for (final k in childrenOf(m.memberId)) {
        n += 1 + count(k);
      }
      return out[m.memberId] = n;
    }

    roots.forEach(count);
    return out;
  }

  /// Birthdays of living members and death anniversaries (haul) of deceased
  /// ones falling within [days] days from [from]. Needs a full date, not a
  /// year only. Gregorian calendar.
  List<FamilyDate> upcomingDates({required DateTime from, int days = 30}) {
    final start = DateTime(from.year, from.month, from.day);
    final end = start.add(Duration(days: days));
    final out = <FamilyDate>[];
    for (final m in byId.values) {
      final src = m.isDeceased
          ? (m.deathYearOnly ? null : m.deathDate)
          : (m.birthYearOnly ? null : m.birthDate);
      if (src == null) continue;
      var next = DateTime(start.year, src.month, src.day);
      if (next.isBefore(start)) next = DateTime(start.year + 1, src.month, src.day);
      if (next.isAfter(end)) continue;
      final years = next.year - src.year;
      if (years <= 0) continue;
      out.add(FamilyDate(
        member: m,
        kind: m.isDeceased ? FamilyDateKind.haul : FamilyDateKind.birthday,
        date: next,
        years: years,
      ));
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  /// Heads of the family branches ("cabang"): the first generation below the
  /// roots that actually splits. A tree whose founder had one child (who had
  /// several) branches at that child's children, not at the only child.
  late final List<MemberModel> branchHeads = _branchHeads();

  List<MemberModel> _branchHeads() {
    var level = roots;
    while (level.length == 1 && childrenOf(level.first.memberId).isNotEmpty) {
      level = childrenOf(level.first.memberId);
    }
    return level;
  }

  /// The branch head [m] belongs to, or null for the elders above the
  /// branches. Used to group event attendance by branch.
  MemberModel? branchOf(MemberModel m) {
    final heads = {for (final h in branchHeads) h.memberId};
    if (heads.contains(m.memberId)) return m;
    for (final a in m.ancestors) {
      if (heads.contains(a)) return byId[a];
    }
    return null;
  }
}

enum FamilyDateKind { birthday, haul }

class FamilyDate {
  const FamilyDate({
    required this.member,
    required this.kind,
    required this.date,
    required this.years,
  });

  final MemberModel member;
  final FamilyDateKind kind;
  final DateTime date;

  /// Age reached on a birthday, or years since death for a haul.
  final int years;
}
