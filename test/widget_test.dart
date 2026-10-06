import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/data/repositories/tree_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLegacyDob', () {
    test('parses "Kediri, 01 Januari 1945"', () {
      final r = parseLegacyDob('Kediri, 01 Januari 1945');
      expect(r.place, 'Kediri');
      expect(r.date, DateTime(1945, 1, 1));
      expect(r.yearOnly, isFalse);
    });

    test('parses year only', () {
      final r = parseLegacyDob('1970');
      expect(r.date, DateTime(1970));
      expect(r.yearOnly, isTrue);
    });

    test('keeps unparseable text as place', () {
      expect(parseLegacyDob('tidak tahu').place, 'tidak tahu');
    });
  });

  test('normalizePhone converts leading 0 to 62', () {
    expect(normalizePhone('0812-3456 7890'), '6281234567890');
    expect(normalizePhone('+62 812'), '62812');
  });

  group('invite code', () {
    test('8 unambiguous characters', () {
      final code = inviteCode();
      expect(code, matches(RegExp(r'^[A-HJKMNP-Z2-79]{8}$')));
      expect(formatInviteCode('KDRT7XQM'), 'KDRT-7XQM');
    });

    test('parses code, link and legacy token', () {
      expect(parseInviteInput(' kdrt-7xqm '), 'KDRT7XQM');
      expect(parseInviteInput('https://bani-app.web.app/invite?t=KDRT7XQM'), 'KDRT7XQM');
      expect(parseInviteInput('0123456789abcdef0123456789abcdef'),
          '0123456789abcdef0123456789abcdef');
      expect(parseInviteInput('   '), isNull);
    });
  });

  test('diffMember returns only changed editable fields', () {
    const before = MemberModel(memberId: 'x', fullName: 'Wiji', occupation: 'Guru',
        spouses: [Spouse(name: 'Muslikan')]);
    final after = MemberModel(memberId: 'x', fullName: 'Wiji Masnipah', occupation: 'Guru',
        spouses: const [Spouse(name: 'Muslikan')], birthDate: DateTime(1945));
    final d = diffMember(before, after);
    expect(d.keys.toSet(), {'fullName', 'birthDate'});
    expect(diffMember(before, before), isEmpty);
  });

  test('formatRupiah', () {
    expect(formatRupiah(15000), 'Rp15.000');
    expect(formatRupiah(79000), 'Rp79.000');
  });

  group('FamilyIndex', () {
    const root = MemberModel(memberId: 'r', fullName: 'Mungin');
    const a = MemberModel(memberId: 'a', fullName: 'Wiji', parentId: 'r',
        generation: 2, ancestors: ['r'], birthOrder: 1);
    const b = MemberModel(memberId: 'b', fullName: 'Kedua', parentId: 'r',
        generation: 2, ancestors: ['r'], birthOrder: 2);
    const c = MemberModel(memberId: 'c', fullName: "Ma'sum", parentId: 'a',
        generation: 3, ancestors: ['r', 'a']);
    final index = FamilyIndex([c, b, a, root]);

    test('dfs orders by birth order', () {
      expect(index.dfs().map((m) => m.memberId), ['r', 'a', 'c', 'b']);
    });

    test('lineage and branch', () {
      expect(index.lineage(c).map((m) => m.memberId), ['r', 'a', 'c']);
      expect(index.isInBranch(c, 'a'), isTrue);
      expect(index.isInBranch(b, 'a'), isFalse);
      expect(index.maxGeneration, 3);
    });

    test('descendant counts and branch of a member', () {
      expect(index.descendantCount['r'], 3);
      expect(index.descendantCount['a'], 1);
      expect(index.descendantCount['c'], 0);
      expect(index.branchOf(c)?.memberId, 'a');
      expect(index.branchOf(a)?.memberId, 'a');
      expect(index.branchOf(root), isNull);
    });

    test('branches start where a founder with one child splits', () {
      const only = MemberModel(memberId: 'o', fullName: 'Satu', parentId: 'r',
          generation: 2, ancestors: ['r']);
      const g1 = MemberModel(memberId: 'g1', fullName: 'Cucu 1', parentId: 'o',
          generation: 3, ancestors: ['r', 'o']);
      const g2 = MemberModel(memberId: 'g2', fullName: 'Cucu 2', parentId: 'o',
          generation: 3, ancestors: ['r', 'o']);
      const gg = MemberModel(memberId: 'gg', fullName: 'Cicit', parentId: 'g2',
          generation: 4, ancestors: ['r', 'o', 'g2']);
      final i = FamilyIndex([root, only, g1, g2, gg]);
      expect(i.branchHeads.map((m) => m.memberId), ['g1', 'g2']);
      expect(i.branchOf(gg)?.memberId, 'g2');
      expect(i.branchOf(only), isNull);
    });
  });

  group('upcomingDates', () {
    final alive = MemberModel(memberId: 'l', fullName: 'Laila',
        birthDate: DateTime(2004, 10, 5));
    final dead = MemberModel(memberId: 'k', fullName: 'Karim', isDeceased: true,
        birthDate: DateTime(1942), birthYearOnly: true, deathDate: DateTime(2015, 10, 8));
    final yearOnly = MemberModel(memberId: 'y', fullName: 'Yusuf',
        birthDate: DateTime(1973), birthYearOnly: true);
    final index = FamilyIndex([alive, dead, yearOnly]);

    test('birthday and haul within the window, sorted', () {
      final d = index.upcomingDates(from: DateTime(2026, 10, 2), days: 7);
      expect(d.map((x) => x.member.memberId), ['l', 'k']);
      expect(d.first.kind, FamilyDateKind.birthday);
      expect(d.first.years, 22);
      expect(d.last.kind, FamilyDateKind.haul);
      expect(d.last.years, 11);
    });

    test('wraps to next year and skips year-only dates', () {
      final d = index.upcomingDates(from: DateTime(2026, 10, 6), days: 365);
      expect(d.map((x) => x.member.memberId), ['k', 'l']);
      expect(d.last.date, DateTime(2027, 10, 5));
    });
  });
}
