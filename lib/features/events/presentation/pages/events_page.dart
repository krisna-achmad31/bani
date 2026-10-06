import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:bani/features/events/presentation/event_providers.dart';
import 'package:bani/features/events/presentation/widgets/event_widgets.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/family_picker.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  11 Acara — next event, birthdays/haul from the tree, upcoming & past list
// ─────────────────────────────────────────────────────────────────────────────

/// Owner, admin and contributors may organise; viewers only answer.
bool canCreateEvents(FamilyAccess a) =>
    a.isSuperAdmin || (a.role != null && a.role != FamilyRole.viewer);

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fid = ref.watch(activeFamilyIdProvider);
    if (fid == null) {
      return ref.watch(userFamiliesProvider).isLoading
          ? const LoadingView()
          : MessageView(
              icon: Icons.event_outlined,
              title: context.t.treeEmptyTitle,
              message: context.t.treeEmptyBody,
            );
    }
    return _EventsView(key: ValueKey(fid), familyId: fid);
  }
}

class _EventsView extends ConsumerStatefulWidget {
  const _EventsView({super.key, required this.familyId});
  final String familyId;

  @override
  ConsumerState<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<_EventsView> {
  var _past = false;

  @override
  Widget build(BuildContext context) {
    final fid = widget.familyId;
    final t = context.t;
    final family = ref.watch(familyProvider(fid)).value;
    final access = ref.watch(accessProvider(fid));
    final eventsAsync = ref.watch(eventsProvider(fid));
    final index = ref.watch(familyIndexProvider(fid));
    final now = DateTime.now();
    final events = eventsAsync.value ?? const <EventModel>[];
    final upcoming = events.where((e) => !e.isPastAt(now)).toList();
    final past = events.where((e) => e.isPastAt(now)).toList().reversed.toList();
    final next = upcoming.firstOrNull;
    final dates = index?.upcomingDates(from: now, days: 30) ?? const [];
    final list = _past ? past : upcoming.skip(1).toList();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(eventsProvider(fid)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.eventsTitle, style: AppText.display(28)),
                  InkWell(
                    onTap: () => showFamilyPicker(context, ref, current: fid),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(family?.name ?? '...',
                          style: AppText.body(13, weight: FontWeight.w600, color: AppColors.ink2)),
                      const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.ink2),
                    ]),
                  ),
                ]),
              ),
              if (canCreateEvents(access))
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.newEvent(fid)),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(t.eventCreate),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    shape: const StadiumBorder(),
                    textStyle: AppText.body(13, weight: FontWeight.w700),
                  ),
                ),
            ]),
            const SizedBox(height: 20),
            if (eventsAsync.isLoading && !eventsAsync.hasValue)
              const Padding(padding: EdgeInsets.all(32), child: LoadingView())
            else if (eventsAsync.hasError)
              Row(children: [
                Expanded(
                  child: Text(t.loadFailed,
                      style: AppText.body(14, color: AppColors.danger)),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(eventsProvider(fid)),
                  child: Text(t.retry),
                ),
              ])
            else if (next != null)
              FadeSlideIn(
                child: NextEventCard(
                  event: next,
                  onTap: () => context.push(AppRoutes.event(fid, next.eventId)),
                ),
              )
            else
              _EmptyEvents(canCreate: canCreateEvents(access)),
            if (dates.isNotEmpty) ...[
              const SizedBox(height: 26),
              Text(t.eventsFromTree, style: AppText.display(18)),
              const SizedBox(height: 10),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SizedBox(
                    width: 160,
                    child: FamilyDateCard(
                      date: dates[i],
                      onTap: () =>
                          context.push(AppRoutes.member(fid, dates[i].member.memberId)),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 26),
            Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line))),
              child: Row(children: [
                _Tab(
                  label: t.eventsUpcoming(upcoming.length),
                  selected: !_past,
                  onTap: () => setState(() => _past = false),
                ),
                const SizedBox(width: 20),
                _Tab(
                  label: t.eventsPast,
                  selected: _past,
                  onTap: () => setState(() => _past = true),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            if (list.isEmpty && (_past || upcoming.isNotEmpty))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  _past ? t.eventsNoPast : t.eventsNoMore,
                  style: AppText.body(14, color: AppColors.ink3),
                ),
              )
            else
              for (final e in list) _EventRow(event: e, past: _past),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: selected ? AppColors.primary : Colors.transparent, width: 2),
              ),
            ),
            child: Text(label,
                style: AppText.body(14,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.ink : AppColors.ink3)),
          ),
        ),
      );
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event, required this.past});
  final EventModel event;
  final bool past;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    final rsvps = ref
            .watch(rsvpsProvider((familyId: event.familyId, eventId: event.eventId)))
            .value ??
        const <Rsvp>[];
    final mine = rsvps.where((r) => r.uid == uid).firstOrNull;
    final sub = [
      if (event.place != null) event.place!.text,
      if (past) context.t.eventGoingCount(goingPeople(rsvps)),
    ].join(', ');
    return InkWell(
      onTap: () => context.push(AppRoutes.event(event.familyId, event.eventId)),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Opacity(opacity: past ? 0.6 : 1, child: DateTile(date: event.startAt)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(sub.isEmpty ? event.type.label : sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, color: AppColors.ink2)),
            ]),
          ),
          if (!past) ...[const SizedBox(width: 8), RsvpPill(rsvp: mine)],
        ]),
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.canCreate});
  final bool canCreate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.celebration_outlined, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(context.t.eventsEmptyTitle, style: AppText.display(20)),
          const SizedBox(height: 6),
          Text(
            canCreate ? context.t.eventsEmptyBody : context.t.eventsEmptyViewer,
            style: AppText.body(14, color: AppColors.ink2, height: 1.45),
          ),
        ]),
      );
}
