import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/services/launcher_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:bani/features/events/data/repositories/event_repository.dart';
import 'package:bani/features/events/presentation/event_providers.dart';
import 'package:bani/features/events/presentation/widgets/event_widgets.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  12 Detail Acara — RSVP, info, attendance per branch, rundown, dues
// ─────────────────────────────────────────────────────────────────────────────

class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.familyId, required this.eventId});
  final String familyId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (familyId: familyId, eventId: eventId);
    final eventAsync = ref.watch(eventProvider(key));
    final event = eventAsync.value;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: eventAsync.isLoading
            ? const LoadingView()
            : MessageView(icon: Icons.event_busy_outlined, title: context.t.notFound),
      );
    }
    final rsvps = ref.watch(rsvpsProvider(key)).value ?? const <Rsvp>[];
    final uid = ref.watch(currentUserProvider)?.uid;
    final access = ref.watch(accessProvider(familyId));
    final canEdit = event.createdBy == uid || access.canManage;
    final mine = rsvps.where((r) => r.uid == uid).firstOrNull;
    final past = event.isPastAt(DateTime.now());
    final t = context.t;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(event: event, canEdit: canEdit, past: past),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (!past) ...[
                _RsvpCard(event: event, mine: mine),
                const SizedBox(height: 24),
              ],
              _InfoRows(event: event),
              if (rsvps.isNotEmpty) ...[
                const SizedBox(height: 28),
                _Attendance(event: event, rsvps: rsvps),
              ],
              if (event.agenda.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHead(t.eventAgenda),
                const SizedBox(height: 12),
                _Agenda(items: event.agenda),
              ],
              if (event.duesAmount > 0) ...[
                const SizedBox(height: 28),
                _Dues(event: event, rsvps: rsvps, mine: mine, canConfirm: canEdit),
              ],
              if ((event.notes ?? '').isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionHead(t.eventNotes),
                const SizedBox(height: 8),
                Text(event.notes!, style: AppText.body(15, color: AppColors.ink2, height: 1.5)),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => LauncherService.whatsappShare(_shareText(context, event)),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(t.eventShareWa),
                style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _shareText(BuildContext context, EventModel e) {
    final t = context.t;
    return [
      e.title,
      '${formatDayDate(e.startAt)}, ${formatTime(e.startAt)}'
          '${e.endAt != null ? ' – ${formatDayDate(e.endAt!)}' : ''}',
      if (e.place != null) e.place!.text,
      if (e.duesAmount > 0) t.eventDuesPerHousehold(formatRupiah(e.duesAmount)),
      '',
      t.eventShareFooter,
    ].join('\n');
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.event, required this.canEdit, required this.past});
  final EventModel event;
  final bool canEdit;
  final bool past;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final when = event.endAt == null
        ? formatDayDate(event.startAt)
        : '${formatShortDay(event.startAt)} – ${formatShortDay(event.endAt!)} ${event.endAt!.year}';
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _HeroButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => context.pop(),
              ),
              const Spacer(),
              if (canEdit) ...[
                _HeroButton(
                  icon: Icons.edit_outlined,
                  tooltip: t.edit,
                  onTap: () => context.push(AppRoutes.editEvent(event.familyId, event.eventId)),
                ),
                const SizedBox(width: 8),
                _HeroButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: t.delete,
                  onTap: () => _delete(context, ref),
                ),
              ],
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OnPrimaryChip(label: event.type.label, icon: event.type.icon),
                  if (event.branchName != null)
                    OnPrimaryChip(label: t.eventForBranch(event.branchName!)),
                ]),
                const SizedBox(height: 12),
                Text(event.title, style: AppText.display(30, color: Colors.white)),
                const SizedBox(height: 8),
                Text(past ? '$when. ${t.eventDone}' : '$when. ${countdownLabel(context, event)}.',
                    style: AppText.body(14,
                        weight: FontWeight.w500, color: AppColors.onPrimarySoft)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.eventDeleteTitle),
        content: Text(context.t.eventDeleteBody),
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
    if (ok != true || !context.mounted) return;
    // The event stream turns empty while deleting and rebuilds this page as
    // "not found", so grab what we need before awaiting.
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final done = context.t.eventDeleted;
    final repo = ref.read(eventRepositoryProvider);
    try {
      await repo.deleteEvent(event.familyId, event.eventId);
      if (router.canPop()) router.pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _RsvpCard extends ConsumerStatefulWidget {
  const _RsvpCard({required this.event, required this.mine});
  final EventModel event;
  final Rsvp? mine;

  @override
  ConsumerState<_RsvpCard> createState() => _RsvpCardState();
}

class _RsvpCardState extends ConsumerState<_RsvpCard> {
  var _busy = false;

  Future<void> _answer(RsvpStatus status, int people) async {
    setState(() => _busy = true);
    await answerRsvp(context, ref, widget.event,
        status: status, people: people, current: widget.mine);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final mine = widget.mine;
    final people = mine?.people ?? 1;
    Widget option(RsvpStatus s, IconData icon, String label) {
      final on = mine?.status == s;
      return Expanded(
        child: Semantics(
          selected: on,
          button: true,
          child: Material(
            color: on ? AppColors.primary : AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: on ? BorderSide.none : const BorderSide(color: AppColors.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _busy ? null : () => _answer(s, people),
              child: SizedBox(
                height: 46,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 16, color: on ? Colors.white : AppColors.ink2),
                  const SizedBox(width: 4),
                  // Long labels ("Not coming") shrink instead of overflowing.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label,
                          style: AppText.body(13,
                              weight: FontWeight.w700,
                              color: on ? Colors.white : AppColors.ink2)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.rsvpQuestion, style: AppText.body(15, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          option(RsvpStatus.going, Icons.check_rounded, t.rsvpGoing),
          const SizedBox(width: 8),
          option(RsvpStatus.maybe, Icons.help_outline_rounded, t.rsvpMaybe),
          const SizedBox(width: 8),
          option(RsvpStatus.no, Icons.close_rounded, t.rsvpNo),
        ]),
        if (mine?.status == RsvpStatus.going) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Text(t.rsvpPeople, style: AppText.body(13, color: AppColors.ink2)),
            ),
            _StepButton(
              icon: Icons.remove_rounded,
              tooltip: t.rsvpFewer,
              onTap: _busy || people <= 1 ? null : () => _answer(RsvpStatus.going, people - 1),
            ),
            SizedBox(
              width: 76,
              child: Text(t.peopleCount(people),
                  textAlign: TextAlign.center,
                  style: AppText.body(14, weight: FontWeight.w700)),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              tooltip: t.rsvpMore,
              onTap: _busy || people >= 30 ? null : () => _answer(RsvpStatus.going, people + 1),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
        color: AppColors.surface,
        child: IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: onTap == null ? AppColors.ink3 : AppColors.ink),
        ),
      );
}

class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final e = event;
    return Column(children: [
      _InfoRow(
        icon: Icons.schedule_rounded,
        title: e.endAt == null
            ? t.eventFromTime(formatTime(e.startAt))
            : '${formatDate(e.startAt)} – ${formatDate(e.endAt!)}',
        subtitle: e.endAt == null ? formatDayDate(e.startAt) : t.eventStartsAt(formatTime(e.startAt)),
      ),
      if (e.place != null)
        _InfoRow(
          icon: Icons.place_outlined,
          title: e.place!.text,
          subtitle: e.place!.detail,
          action: t.detailOpenInMaps,
          onAction: () => LauncherService.maps(e.place!),
        ),
      if (e.createdByName.isNotEmpty)
        _InfoRow(
          icon: Icons.how_to_reg_outlined,
          title: t.eventOrganizer(e.createdByName),
          subtitle: e.branchName == null ? t.eventForAll : t.eventForBranch(e.branchName!),
        ),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.body(14, weight: FontWeight.w700)),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!, style: AppText.body(12, color: AppColors.ink2)),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(action!,
                        style: AppText.body(12,
                            weight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
            ]),
          ),
        ]),
      );
}

class _SectionHead extends StatelessWidget {
  const _SectionHead(this.title, {this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: AppText.display(19))),
          if (trailing != null)
            Text(trailing!,
                style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ink2)),
        ],
      );
}

/// Bars per branch: people coming vs. living members of that branch.
class _Attendance extends ConsumerWidget {
  const _Attendance({required this.event, required this.rsvps});
  final EventModel event;
  final List<Rsvp> rsvps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final index = ref.watch(familyIndexProvider(event.familyId));
    final going = rsvps.where((r) => r.status == RsvpStatus.going).toList();
    final total = goingPeople(going);
    final rows = <(String, int, int)>[];
    if (index != null) {
      // Branch from the member as the tree is now (it may have been edited
      // since the answer); the stored branchId is only a fallback.
      String? branchOf(Rsvp r) {
        final m = r.memberId == null ? null : index.byId[r.memberId];
        return m != null ? index.branchOf(m)?.memberId : r.branchId;
      }

      var branches = index.branchHeads;
      if (event.branchId != null) {
        branches = branches.where((b) => b.memberId == event.branchId).toList();
      }
      final ids = {for (final b in branches) b.memberId};
      for (final b in branches) {
        final living = index.dfs(b.memberId).where((m) => !m.isDeceased).length;
        final coming = goingPeople(going.where((r) => branchOf(r) == b.memberId));
        if (living == 0 && coming == 0) continue;
        rows.add((t.eventBranch(b.nickname?.isNotEmpty == true ? b.nickname! : b.fullName),
            coming, living));
      }
      // Elders above the branches (e.g. the founder's household).
      final elders = goingPeople(going.where((r) =>
          r.memberId != null && index.byId.containsKey(r.memberId) && branchOf(r) == null));
      if (elders > 0) rows.add((t.eventBranchElders, elders, 0));
      final others = goingPeople(going.where((r) =>
          !ids.contains(branchOf(r)) &&
          !(r.memberId != null && index.byId.containsKey(r.memberId) && branchOf(r) == null)));
      if (others > 0) rows.add((t.eventBranchOther, others, 0));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _SectionHead(t.eventAttendance, trailing: t.peopleCount(total)),
      const SizedBox(height: 12),
      for (final (name, coming, of) in rows) ...[
        Row(children: [
          Expanded(child: Text(name, style: AppText.body(13, weight: FontWeight.w600))),
          Text(of > 0 ? '$coming/$of' : '$coming',
              style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ink2)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: of > 0 ? (coming / of).clamp(0.0, 1.0) : (coming > 0 ? 1 : 0),
            minHeight: 8,
            backgroundColor: AppColors.surface2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 4),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final r in rsvps)
          _GuestChip(rsvp: r),
      ]),
    ]);
  }
}

class _GuestChip extends StatelessWidget {
  const _GuestChip({required this.rsvp});
  final Rsvp rsvp;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (rsvp.status) {
      RsvpStatus.going => (AppColors.primarySoft, AppColors.primary),
      RsvpStatus.maybe => (AppColors.goldSoft, AppColors.gold),
      RsvpStatus.no => (AppColors.surface2, AppColors.ink3),
    };
    final first = rsvp.name.split(' ').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        rsvp.status == RsvpStatus.going && rsvp.people > 1 ? '$first +${rsvp.people - 1}' : first,
        style: AppText.body(12, weight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.items});
  final List<AgendaItem> items;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 48,
                child: Text(items[i].time,
                    style: AppText.body(13, weight: FontWeight.w700, color: AppColors.primary)),
              ),
              SizedBox(
                width: 22,
                child: Column(children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0 ? AppColors.primary : AppColors.surface,
                      border: Border.all(color: AppColors.branch, width: 1.5),
                    ),
                  ),
                  if (i < items.length - 1)
                    Expanded(child: Container(width: 1.5, color: AppColors.branch)),
                ]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(items[i].text, style: AppText.body(14, height: 1.35)),
                ),
              ),
            ]),
          ),
      ]);
}

class _Dues extends ConsumerWidget {
  const _Dues({
    required this.event,
    required this.rsvps,
    required this.mine,
    required this.canConfirm,
  });

  final EventModel event;
  final List<Rsvp> rsvps;
  final Rsvp? mine;
  final bool canConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final households = rsvps.where((r) => r.status == RsvpStatus.going).toList();
    final paid = households.where((r) => r.paid).length;
    final left = households.length - paid;

    Future<void> run(Future<void> Function(EventRepository repo) f) async {
      try {
        await f(ref.read(eventRepositoryProvider));
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _SectionHead(t.eventDues,
          trailing: t.eventDuesPerHousehold(formatRupiah(event.duesAmount))),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.goldSoft, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(formatRupiah(paid * event.duesAmount), style: AppText.display(24)),
                Text(t.eventDuesCollected(paid),
                    style: AppText.body(12, color: AppColors.ink2)),
              ]),
            ),
            if (left > 0)
              Text(t.eventDuesLeft(left),
                  style: AppText.body(12, weight: FontWeight.w700, color: AppColors.gold)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: households.isEmpty ? 0 : paid / households.length,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              color: AppColors.gold,
            ),
          ),
          if (mine?.status == RsvpStatus.going && !mine!.paid) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => run((repo) => repo.claimPaid(
                  event.familyId, event.eventId, mine!.uid, !mine!.paidClaimed)),
              icon: Icon(
                  mine!.paidClaimed ? Icons.hourglass_top_rounded : Icons.receipt_long_outlined,
                  size: 18),
              label: Text(mine!.paidClaimed ? t.eventDuesWaiting : t.eventDuesClaim),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: BorderSide.none,
                minimumSize: const Size.fromHeight(44),
                textStyle: AppText.body(14, weight: FontWeight.w700),
              ),
            ),
          ],
          if (mine?.paid == true) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.verified_rounded, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(t.eventDuesConfirmed,
                  style: AppText.body(13, weight: FontWeight.w700, color: AppColors.gold)),
            ]),
          ],
        ]),
      ),
      if (canConfirm && households.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(t.eventDuesTreasurer, style: AppText.body(13, weight: FontWeight.w700)),
        for (final r in households)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: r.paid,
            activeColor: AppColors.gold,
            onChanged: (v) =>
                run((repo) => repo.setPaid(event.familyId, event.eventId, r.uid, v ?? false)),
            title: Text(r.name, style: AppText.body(14, weight: FontWeight.w600)),
            subtitle: r.paidClaimed && !r.paid
                ? Text(t.eventDuesClaimed, style: AppText.body(12, color: AppColors.gold))
                : null,
          ),
      ],
      const SizedBox(height: 8),
      Text(t.eventDuesNote, style: AppText.body(12, color: AppColors.ink3, height: 1.4)),
    ]);
  }
}

