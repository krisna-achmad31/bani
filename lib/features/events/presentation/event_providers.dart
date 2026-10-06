import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:bani/features/events/data/repositories/event_repository.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

/// All events of a tree, oldest first.
final eventsProvider = StreamProvider.family<List<EventModel>, String>(
    (ref, fid) => ref.watch(eventRepositoryProvider).watchEvents(fid));

typedef EventKey = ({String familyId, String eventId});

final eventProvider = StreamProvider.family<EventModel?, EventKey>(
    (ref, k) => ref.watch(eventRepositoryProvider).watchEvent(k.familyId, k.eventId));

final rsvpsProvider = StreamProvider.family<List<Rsvp>, EventKey>(
    (ref, k) => ref.watch(eventRepositoryProvider).watchRsvps(k.familyId, k.eventId));

/// The member the current user is in this tree: the one they claimed, else
/// the anchor of their invite.
final myMemberProvider = Provider.family<MemberModel?, String>((ref, fid) {
  final index = ref.watch(familyIndexProvider(fid));
  final uid = ref.watch(currentUserProvider)?.uid;
  if (index == null || uid == null) return null;
  final claimed = index.byId.values.where((m) => m.claimedByUid == uid).firstOrNull;
  if (claimed != null) return claimed;
  final anchor = ref.watch(myGrantProvider(fid)).value?.anchorMemberId;
  return anchor == null ? null : index.byId[anchor];
});

/// Next upcoming event of a tree, if any.
final nextEventProvider = Provider.family<EventModel?, String>((ref, fid) {
  final now = DateTime.now();
  return ref
      .watch(eventsProvider(fid))
      .value
      ?.where((e) => !e.isPastAt(now))
      .firstOrNull;
});
