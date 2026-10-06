import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/services/launcher_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/pages/tree_page.dart';
import 'package:bani/features/tree/presentation/widgets/album_section.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/move_member_sheet.dart';
import 'package:bani/features/tree/presentation/widgets/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  05 Detail anggota
// ─────────────────────────────────────────────────────────────────────────────

class MemberDetailPage extends ConsumerWidget {
  const MemberDetailPage({super.key, required this.familyId, required this.memberId});

  final String familyId;
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(familyIndexProvider(familyId));
    final member = index?.byId[memberId];
    if (index == null) return const Scaffold(body: LoadingView());
    if (member == null) {
      return Scaffold(
        appBar: AppBar(),
        body: MessageView(icon: Icons.person_off_outlined, title: context.t.detailNotFound),
      );
    }
    final access = ref.watch(accessProvider(familyId));
    final key = (familyId: familyId, memberId: memberId);
    final contact = ref.watch(contactProvider(key)).value;
    final fullPhoto = member.hasPhoto && member.photoThumb != null
        ? ref.watch(photoProvider((
            familyId: familyId,
            memberId: memberId,
            version: member.photoThumb.hashCode,
          ))).value
        : null;
    final parent = index.parentOf(member);
    final kids = index.childrenOf(memberId);
    final age = member.age;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(icon: Icons.arrow_back, onPressed: () => context.pop()),
        ),
        leadingWidth: 60,
        actions: [
          if (access.canEdit(member))
            CircleIconButton(
              icon: Icons.edit_outlined,
              tooltip: context.t.edit,
              onPressed: () => context.push(AppRoutes.editMember(familyId, memberId)),
            ),
          if (access.canManage && !member.isRoot) ...[
            const SizedBox(width: 8),
            CircleIconButton(
              icon: Icons.drive_file_move_outline,
              tooltip: context.t.treeMove,
              onPressed: () => startMoveMember(context, ref, familyId, member),
            ),
          ],
          if (access.canDelete(member)) ...[
            const SizedBox(width: 8),
            CircleIconButton(
              icon: Icons.delete_outline,
              tooltip: context.t.delete,
              onPressed: () => _delete(context, ref, member, kids.isNotEmpty),
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: GestureDetector(
              onTap: member.photoThumb == null
                  ? null
                  : () => openPhotoViewer(
                        context,
                        photo: member.photoThumb!,
                        bytes: fullPhoto,
                        heroTag: 'photo-$memberId',
                        title: member.fullName,
                        subtitle: context.t.generation(member.generation),
                      ),
              child: Hero(
                tag: 'photo-$memberId',
                child: MemberAvatar(
                  name: member.fullName,
                  photo: member.photoThumb,
                  photoBytes: fullPhoto,
                  size: 112,
                  deceased: member.isDeceased,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(member.fullName, textAlign: TextAlign.center, style: AppText.display(28)),
          if (member.nickname != null)
            Text('"${member.nickname}"', textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.ink2)),
          const SizedBox(height: 4),
          Text(
            [
              if (parent != null)
                member.birthOrder != null
                    ? context.t.detailChildOrder(member.birthOrder!, parent.fullName)
                    : context.t.detailChildOf(parent.fullName),
              context.t.generation(member.generation),
            ].join(' · '),
            textAlign: TextAlign.center,
            style: AppText.body(14, color: AppColors.ink2),
          ),
          const SizedBox(height: 10),
          Center(
            child: member.isDeceased
                ? Pill(age != null ? context.t.detailDeceasedAge(age) : context.t.deceased,
                    color: AppColors.ink2, background: AppColors.surface2)
                : Pill(age != null ? context.t.detailAliveAge(age) : context.t.alive,
                    icon: Icons.circle),
          ),
          if ((member.updatedByName ?? '').isNotEmpty && member.updatedAt != null) ...[
            const SizedBox(height: 8),
            Text(context.t.detailLastEdit(member.updatedByName!, formatDate(member.updatedAt)),
                textAlign: TextAlign.center,
                style: AppText.body(12, color: AppColors.ink3)),
          ],
          const SizedBox(height: 20),
          FadeSlideIn(
              child: _QuickActions(contact: contact, grave: member.grave, name: member.fullName)),
          const SizedBox(height: 20),
          FadeSlideIn(
              index: 1,
              child: _InfoCard(member: member, contact: contact, contactHidden: contact == null)),
          const SizedBox(height: 20),
          SectionLabel(
            context.t.detailChildren(kids.length),
            trailing: access.role != null
                ? TextButton.icon(
                    onPressed: () => startAddChild(context, ref, familyId, member),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.t.treeAddChild),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          if (kids.isEmpty)
            Text(context.t.detailNoChildren,
                style: AppText.body(14, color: AppColors.ink3))
          else
            _KidsList(
              kids: kids,
              index: index,
              onTap: (k) => context.push(AppRoutes.member(familyId, k.memberId)),
            ),
          if (_dateNote(context, member) case final note?) ...[
            const SizedBox(height: 16),
            note,
          ],
          const SizedBox(height: 24),
          AlbumSection(familyId: familyId, member: member),
          if (!member.isClaimed && access.canManage) ...[
            const SizedBox(height: 20),
            _ClaimBox(member: member, onInvite: () {
              ref.read(selectedFamilyIdProvider.notifier).select(familyId);
              context.go('${AppRoutes.share}?m=$memberId');
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, MemberModel member, bool hasKids) async {
    if (hasKids) {
      showMessage(context, context.t.detailDeleteKidsFirst(member.fullName));
      return;
    }
    final album = ref.read(albumProvider((familyId: familyId, memberId: member.memberId))).value;
    if (album != null && album.isNotEmpty) {
      showMessage(context, context.t.memberHasAlbum(member.fullName));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.detailDeleteTitle(member.fullName)),
        content: Text(context.t.detailDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(context.t.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(treeRepositoryProvider).deleteMember(familyId, member.memberId);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.contact, required this.grave, required this.name});
  final MemberContact? contact;
  final GeoPlace? grave;
  final String name;

  @override
  Widget build(BuildContext context) {
    final phone = contact?.phone;
    final place = contact?.address ?? grave;
    Widget action(IconData icon, String label, VoidCallback? onTap, {bool primary = false}) =>
        Expanded(
          child: Material(
            color: onTap == null
                ? AppColors.surface2
                : primary ? AppColors.primary : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: primary || onTap == null
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(
                height: 64,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 20,
                      color: onTap == null ? AppColors.ink3 : primary ? Colors.white : AppColors.ink),
                  const SizedBox(height: 4),
                  Text(label, style: AppText.body(12, weight: FontWeight.w700,
                      color: onTap == null ? AppColors.ink3 : primary ? Colors.white : AppColors.ink)),
                ]),
              ),
            ),
          ),
        );

    return Row(children: [
      action(Icons.chat_outlined, context.t.detailWhatsapp,
          phone == null ? null : () => LauncherService.whatsapp(phone,
              text: context.t.waGreeting(name)), primary: true),
      const SizedBox(width: 10),
      action(Icons.call_outlined, context.t.detailCall,
          phone == null ? null : () => LauncherService.call(phone)),
      const SizedBox(width: 10),
      action(Icons.place_outlined,
          contact?.address != null ? context.t.detailOpenMaps : context.t.detailGrave,
          place == null ? null : () => LauncherService.maps(place)),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.member, required this.contact, required this.contactHidden});
  final MemberModel member;
  final MemberContact? contact;
  final bool contactHidden;

  @override
  Widget build(BuildContext context) {
    final birth = [
      member.birthPlace,
      formatDate(member.birthDate, yearOnly: member.birthYearOnly),
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    final t = context.t;
    final rows = <(IconData, String, String, GeoPlace?)>[
      (Icons.cake_outlined, t.detailBorn, birth.isEmpty ? '-' : birth, null),
      if (member.isDeceased)
        (Icons.local_florist_outlined, t.detailDied,
            formatDate(member.deathDate, yearOnly: member.deathYearOnly).ifEmpty('-'), null),
      if (member.grave != null)
        (Icons.place_outlined, t.detailGrave, member.grave!.text, member.grave),
      if (contact?.address != null)
        (Icons.home_outlined, t.detailAddress,
            [contact!.address!.text, contact!.address!.detail]
                .whereType<String>().where((s) => s.isNotEmpty).join('\n'),
            contact!.address),
      if (contact?.phone != null) (Icons.phone_outlined, t.detailWhatsapp, contact!.phone!, null),
      if (member.spouses.isNotEmpty)
        (Icons.favorite_border, t.detailSpouse,
            member.spouses.map((s) => '${s.name} · ${s.status.label.toLowerCase()}').join('\n'),
            null),
      if (member.gender != Gender.unknown) (Icons.wc_outlined, t.detailGender, member.gender.label, null),
      if (member.occupation != null) (Icons.work_outline, t.detailOccupation, member.occupation!, null),
      if (member.notes != null) (Icons.notes_outlined, t.detailNotes, member.notes!, null),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(rows[i].$1, size: 18, color: AppColors.ink2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rows[i].$2, style: AppText.body(12, color: AppColors.ink3)),
                  const SizedBox(height: 2),
                  Text(rows[i].$3,
                      style: AppText.body(15, weight: FontWeight.w600, height: 1.35)),
                  if (rows[i].$4 != null)
                    InkWell(
                      onTap: () => LauncherService.maps(rows[i].$4!),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(t.detailOpenInMaps, style: AppText.body(13,
                              weight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
                        ]),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
          if (i < rows.length - 1) const Divider(),
        ],
        if (contactHidden)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(children: [
              const Icon(Icons.lock_outline, size: 14, color: AppColors.ink3),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t.detailContactHidden,
                    style: AppText.body(12, color: AppColors.ink3)),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _ClaimBox extends StatelessWidget {
  const _ClaimBox({required this.member, required this.onInvite});
  final MemberModel member;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.goldSoft, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Icon(Icons.person_add_alt_outlined, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.t.detailUnclaimed, style: AppText.body(14, weight: FontWeight.w700)),
              Text(context.t.detailUnclaimedBody(member.fullName.split(' ').first),
                  style: AppText.body(12, color: AppColors.ink2, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onInvite,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(context.t.detailInvite),
          ),
        ]),
      );
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// Birthday / haul note: these dates show up for everyone in the Acara tab.
Widget? _dateNote(BuildContext context, MemberModel m) {
  final date = m.isDeceased
      ? (m.deathYearOnly ? null : m.deathDate)
      : (m.birthYearOnly ? null : m.birthDate);
  if (date == null) return null;
  final day = '${date.day} ${monthName(date)}';
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: AppColors.goldSoft, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Icon(m.isDeceased ? Icons.nightlight_outlined : Icons.cake_outlined,
          color: AppColors.gold),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.isDeceased ? context.t.detailHaulOn(day) : context.t.detailBirthdayOn(day),
              style: AppText.body(14, weight: FontWeight.w700)),
          Text(context.t.detailDateInEvents,
              style: AppText.body(12, color: AppColors.ink2, height: 1.35)),
        ]),
      ),
    ]),
  );
}

/// Children as a vertical list hanging off one branch line.
class _KidsList extends StatelessWidget {
  const _KidsList({required this.kids, required this.index, required this.onTap});
  final List<MemberModel> kids;
  final FamilyIndex index;
  final ValueChanged<MemberModel> onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 18),
        child: Column(children: [
          for (final (i, k) in kids.indexed)
            SizedBox(
              height: 60,
              child: Row(children: [
                SizedBox(
                  width: 20,
                  child: CustomPaint(
                    size: const Size(20, 60),
                    painter: _KidRail(last: i == kids.length - 1),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onTap(k),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(children: [
                        MemberAvatar(name: k.fullName, photo: k.photoThumb, size: 38,
                            ring: false, deceased: k.isDeceased),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(k.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body(15, weight: FontWeight.w700)),
                              Text(_meta(context, k),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body(12, color: AppColors.ink2)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
        ]),
      );

  String _meta(BuildContext context, MemberModel k) {
    final children = index.childrenOf(k.memberId).length;
    final grand = (index.descendantCount[k.memberId] ?? 0) - children;
    return [
      if (k.birthDate != null) '${k.birthDate!.year}',
      if (k.isDeceased) context.t.deceasedShort,
      if (children > 0) context.t.focusChildCount(children),
      if (grand > 0) context.t.detailGrandchildCount(grand),
    ].join(', ');
  }
}

class _KidRail extends CustomPainter {
  _KidRail({required this.last});
  final bool last;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.branch
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final cy = size.height / 2;
    canvas.drawLine(Offset.zero, Offset(0, last ? cy : size.height), p);
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), p);
  }

  @override
  bool shouldRepaint(_KidRail old) => old.last != last;
}
