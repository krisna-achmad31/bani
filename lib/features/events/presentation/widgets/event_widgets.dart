import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:bani/features/events/presentation/event_providers.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Building blocks shared by Acara, Detail Acara and Beranda (bani.pen 11–13)
// ─────────────────────────────────────────────────────────────────────────────

/// People coming (households × their headcount) among "going" answers.
int goingPeople(Iterable<Rsvp> rsvps) => rsvps
    .where((r) => r.status == RsvpStatus.going)
    .fold(0, (a, r) => a + r.people);

/// Saves the user's answer, tagging it with their member and branch so the
/// organizer sees attendance per branch.
Future<void> answerRsvp(
  BuildContext context,
  WidgetRef ref,
  EventModel event, {
  required RsvpStatus status,
  required int people,
  required Rsvp? current,
}) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;
  final me = ref.read(myMemberProvider(event.familyId));
  final index = ref.read(familyIndexProvider(event.familyId));
  try {
    await ref.read(eventRepositoryProvider).setRsvp(
          event.familyId,
          event.eventId,
          Rsvp(
            uid: user.uid,
            name: me?.fullName ?? user.displayName ?? '',
            status: status,
            people: people.clamp(1, 30),
            memberId: me?.memberId,
            branchId: me == null || index == null ? null : index.branchOf(me)?.memberId,
          ),
          exists: current != null,
        );
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// "24 / Okt" block used in event lists.
class DateTile extends StatelessWidget {
  const DateTile({super.key, required this.date, this.onDark = false});
  final DateTime date;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Container(
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: onDark ? null : Border.all(color: AppColors.line),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${date.day}', style: AppText.display(24).copyWith(height: 1)),
          const SizedBox(height: 2),
          Text(monthShort(date),
              style: AppText.body(12, weight: FontWeight.w700, color: AppColors.primary)),
        ]),
      );
}

/// Translucent label on the sogan cards ("Reuni", "22 hari lagi").
class OnPrimaryChip extends StatelessWidget {
  const OnPrimaryChip({super.key, required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppText.body(12, weight: FontWeight.w700, color: Colors.white)),
        ]),
      );
}

String countdownLabel(BuildContext context, EventModel e) {
  final days = e.daysUntil(DateTime.now());
  if (days <= 0) return context.t.eventToday;
  if (days == 1) return context.t.eventTomorrow;
  return context.t.eventInDays(days);
}

/// Big sogan card for the next event, with a one-tap "I'm coming".
class NextEventCard extends ConsumerWidget {
  const NextEventCard({super.key, required this.event, required this.onTap});
  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final key = (familyId: event.familyId, eventId: event.eventId);
    final rsvps = ref.watch(rsvpsProvider(key)).value ?? const [];
    final uid = ref.watch(currentUserProvider)?.uid;
    final mine = rsvps.where((r) => r.uid == uid).firstOrNull;
    final going = goingPeople(rsvps);
    const soft = AppColors.onPrimarySoft;

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              OnPrimaryChip(label: event.type.label, icon: event.type.icon),
              const Spacer(),
              Text(countdownLabel(context, event),
                  style: AppText.body(12, weight: FontWeight.w600, color: soft)),
            ]),
            const SizedBox(height: 14),
            Text(event.title, style: AppText.display(25, color: Colors.white)),
            const SizedBox(height: 12),
            _InfoLine(icon: Icons.calendar_today_outlined,
                text: '${formatDayDate(event.startAt)}, ${formatTime(event.startAt)}'),
            if (event.place != null) ...[
              const SizedBox(height: 6),
              _InfoLine(icon: Icons.place_outlined, text: event.place!.text),
            ],
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.groups_2_outlined, size: 18, color: soft),
              const SizedBox(width: 6),
              Expanded(
                child: Text(t.eventGoingCount(going),
                    style: AppText.body(13, weight: FontWeight.w700, color: Colors.white)),
              ),
              if (mine?.status == RsvpStatus.going)
                Row(children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(t.eventYouAreGoing,
                      style: AppText.body(13, weight: FontWeight.w700, color: Colors.white)),
                ])
              else
                FilledButton.icon(
                  onPressed: () => answerRsvp(context, ref, event,
                      status: RsvpStatus.going, people: mine?.people ?? 1, current: mine),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(t.eventImGoing),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 38),
                    shape: const StadiumBorder(),
                    textStyle: AppText.body(13, weight: FontWeight.w700),
                  ),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: AppColors.onPrimarySoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(13, weight: FontWeight.w500, color: Colors.white)),
        ),
      ]);
}

/// Compact version for Beranda.
class NextEventStrip extends StatelessWidget {
  const NextEventStrip({super.key, required this.event, required this.onTap});
  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              DateTile(date: event.startAt, onDark: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.t.eventNext,
                      style: AppText.body(12,
                          weight: FontWeight.w600, color: AppColors.onPrimarySoft)),
                  const SizedBox(height: 2),
                  Text(event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(18, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(countdownLabel(context, event),
                      style: AppText.body(12, color: Colors.white)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ]),
          ),
        ),
      );
}

/// Birthday / haul taken from the tree.
class FamilyDateCard extends StatelessWidget {
  const FamilyDateCard({super.key, required this.date, required this.onTap});
  final FamilyDate date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final haul = date.kind == FamilyDateKind.haul;
    final t = context.t;
    return Material(
      color: haul ? AppColors.goldSoft : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(haul ? Icons.nightlight_outlined : Icons.cake_outlined,
                  size: 18, color: haul ? AppColors.gold : AppColors.primary),
              const Spacer(),
              Text(formatShortDay(date.date),
                  style: AppText.body(11, weight: FontWeight.w600, color: AppColors.ink2)),
            ]),
            const Spacer(),
            Text(date.member.nickname?.isNotEmpty == true
                    ? date.member.nickname!
                    : date.member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(15, weight: FontWeight.w700)),
            Text(haul ? t.dateHaul(date.years) : t.dateBirthday(date.years),
                style: AppText.body(12, color: AppColors.ink2)),
          ]),
        ),
      ),
    );
  }
}

/// "Hadir" / "Belum jawab" label on list rows.
class RsvpPill extends StatelessWidget {
  const RsvpPill({super.key, required this.rsvp});
  final Rsvp? rsvp;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return switch (rsvp?.status) {
      null => Pill(t.rsvpNone, color: AppColors.danger, background: AppColors.dangerSoft),
      RsvpStatus.going => Pill(t.rsvpGoing),
      RsvpStatus.maybe => Pill.gold(t.rsvpMaybe),
      RsvpStatus.no => Pill(t.rsvpNo, color: AppColors.ink2, background: AppColors.surface2),
    };
  }
}
