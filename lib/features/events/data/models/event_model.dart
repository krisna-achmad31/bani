import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Acara keluarga — families/{familyId}/events/{eventId}
//  RSVPs live in events/{eventId}/rsvps/{uid}; counts are computed from them
//  (families are small, so no counters to keep in sync).
// ─────────────────────────────────────────────────────────────────────────────

enum EventType { reunion, halalBihalal, holiday, arisan, haul, other }

extension EventTypeX on EventType {
  static EventType from(String? s) =>
      EventType.values.where((t) => t.name == s).firstOrNull ?? EventType.other;

  IconData get icon => switch (this) {
        EventType.reunion => Icons.groups_2_outlined,
        EventType.halalBihalal => Icons.volunteer_activism_outlined,
        EventType.holiday => Icons.landscape_outlined,
        EventType.arisan => Icons.savings_outlined,
        EventType.haul => Icons.nightlight_outlined,
        EventType.other => Icons.event_outlined,
      };

  String get label => switch (this) {
        EventType.reunion => tr.eventTypeReunion,
        EventType.halalBihalal => tr.eventTypeHalalBihalal,
        EventType.holiday => tr.eventTypeHoliday,
        EventType.arisan => tr.eventTypeArisan,
        EventType.haul => tr.eventTypeHaul,
        EventType.other => tr.eventTypeOther,
      };
}

/// One line of the rundown ("09.00 — Pembukaan").
class AgendaItem {
  const AgendaItem({required this.time, required this.text});
  final String time;
  final String text;

  factory AgendaItem.fromMap(Map m) =>
      AgendaItem(time: m['time'] as String? ?? '', text: m['text'] as String? ?? '');

  Map<String, dynamic> toMap() => {'time': time.trim(), 'text': text.trim()};
}

class EventModel {
  const EventModel({
    required this.eventId,
    required this.familyId,
    required this.type,
    required this.title,
    required this.startAt,
    this.endAt,
    this.place,
    this.notes,
    this.branchId,
    this.branchName,
    this.duesAmount = 0,
    this.agenda = const [],
    this.createdBy = '',
    this.createdByName = '',
  });

  /// Empty for an event not saved yet.
  final String eventId;
  final String familyId;
  final EventType type;
  final String title;
  final DateTime startAt;

  /// Last day of a multi-day event (holiday, trip).
  final DateTime? endAt;
  final GeoPlace? place;
  final String? notes;

  /// Invited branch (a child of the root); null = the whole tree.
  final String? branchId;
  final String? branchName;

  /// Contribution per household in Rupiah; 0 = none. Bani only records who
  /// paid — money goes straight to the family treasurer.
  final int duesAmount;
  final List<AgendaItem> agenda;
  final String createdBy;
  final String createdByName;

  DateTime get lastDay => endAt ?? startAt;

  /// Past once the last day has ended.
  bool isPastAt(DateTime now) {
    final d = lastDay;
    return now.isAfter(DateTime(d.year, d.month, d.day, 23, 59));
  }

  int daysUntil(DateTime now) {
    final a = DateTime(now.year, now.month, now.day);
    final b = DateTime(startAt.year, startAt.month, startAt.day);
    return b.difference(a).inDays;
  }

  factory EventModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s, String familyId) {
    final d = s.data() ?? const {};
    DateTime? ts(Object? v) => v is Timestamp ? v.toDate() : null;
    return EventModel(
      eventId: s.id,
      familyId: familyId,
      type: EventTypeX.from(d['type'] as String?),
      title: d['title'] as String? ?? '',
      startAt: ts(d['startAt']) ?? DateTime.now(),
      endAt: ts(d['endAt']),
      place: GeoPlace.fromMap(d['place']),
      notes: d['notes'] as String?,
      branchId: d['branchId'] as String?,
      branchName: d['branchName'] as String?,
      duesAmount: (d['duesAmount'] as num?)?.toInt() ?? 0,
      agenda: (d['agenda'] as List? ?? const [])
          .whereType<Map>()
          .map(AgendaItem.fromMap)
          .toList(),
      createdBy: d['createdBy'] as String? ?? '',
      createdByName: d['createdByName'] as String? ?? '',
    );
  }

  /// Editable fields; createdBy/createdAt are added by the repository on create.
  Map<String, dynamic> toEditableMap() => {
        'type': type.name,
        'title': title.trim(),
        'startAt': Timestamp.fromDate(startAt),
        'endAt': endAt == null ? null : Timestamp.fromDate(endAt!),
        'place': place?.toMap(),
        'notes': (notes == null || notes!.trim().isEmpty) ? null : notes!.trim(),
        'branchId': branchId,
        'branchName': branchName,
        'duesAmount': duesAmount,
        'agenda': [
          for (final a in agenda)
            if (a.text.trim().isNotEmpty) a.toMap(),
        ],
      };
}

enum RsvpStatus { going, maybe, no }

class Rsvp {
  const Rsvp({
    required this.uid,
    required this.name,
    required this.status,
    this.people = 1,
    this.memberId,
    this.branchId,
    this.paidClaimed = false,
    this.paid = false,
  });

  final String uid;
  final String name;
  final RsvpStatus status;

  /// People coming in this household, the user included.
  final int people;

  /// The user's member in the tree and its branch, for attendance per branch.
  final String? memberId;
  final String? branchId;

  /// The guest says they transferred the dues…
  final bool paidClaimed;

  /// …and the organizer confirmed it.
  final bool paid;

  factory Rsvp.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return Rsvp(
      uid: s.id,
      name: d['name'] as String? ?? '',
      status: RsvpStatus.values.where((v) => v.name == d['status']).firstOrNull ??
          RsvpStatus.maybe,
      people: (d['people'] as num?)?.toInt() ?? 1,
      memberId: d['memberId'] as String?,
      branchId: d['branchId'] as String?,
      paidClaimed: d['paidClaimed'] as bool? ?? false,
      paid: d['paid'] as bool? ?? false,
    );
  }
}
