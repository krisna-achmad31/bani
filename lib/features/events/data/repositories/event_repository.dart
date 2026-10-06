import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  EventRepository — families/{fid}/events and their rsvps (see firestore.rules)
// ─────────────────────────────────────────────────────────────────────────────

class EventRepository {
  EventRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _events(String fid) => _db
      .collection(AppConstants.familiesCollection)
      .doc(fid)
      .collection(AppConstants.eventsCollection);
  CollectionReference<Map<String, dynamic>> _rsvps(String fid, String eid) =>
      _events(fid).doc(eid).collection(AppConstants.rsvpsCollection);

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw AppFailure.from(e);
    }
  }

  Stream<List<EventModel>> watchEvents(String fid) => _events(fid)
      .orderBy('startAt')
      .snapshots()
      .map((q) => q.docs.map((d) => EventModel.fromSnapshot(d, fid)).toList());

  Stream<EventModel?> watchEvent(String fid, String eid) => _events(fid)
      .doc(eid)
      .snapshots()
      .map((s) => s.exists ? EventModel.fromSnapshot(s, fid) : null);

  /// Creates the event when [event].eventId is empty; returns its id.
  Future<String> saveEvent(EventModel event,
          {required String uid, required String userName}) =>
      _guard(() async {
        if (event.eventId.isNotEmpty) {
          await _events(event.familyId).doc(event.eventId).update({
            ...event.toEditableMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return event.eventId;
        }
        final ref = _events(event.familyId).doc();
        await ref.set({
          ...event.toEditableMap(),
          'createdBy': uid,
          'createdByName': userName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return ref.id;
      });

  /// Deletes the event and its RSVPs (families are small: one batch).
  Future<void> deleteEvent(String fid, String eid) => _guard(() async {
        final rsvps = await _rsvps(fid, eid).get();
        final batch = _db.batch();
        for (final d in rsvps.docs) {
          batch.delete(d.reference);
        }
        batch.delete(_events(fid).doc(eid));
        await batch.commit();
      });

  Stream<List<Rsvp>> watchRsvps(String fid, String eid) => _rsvps(fid, eid)
      .snapshots()
      .map((q) => q.docs.map(Rsvp.fromSnapshot).toList());

  /// The user's own answer. `paid` is only ever set by the organizer.
  Future<void> setRsvp(String fid, String eid, Rsvp r, {required bool exists}) =>
      _guard(() async {
        final data = {
          'name': r.name,
          'status': r.status.name,
          'people': r.people,
          'memberId': r.memberId,
          'branchId': r.branchId,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        final ref = _rsvps(fid, eid).doc(r.uid);
        if (exists) {
          await ref.update(data);
        } else {
          await ref.set({...data, 'paidClaimed': false, 'paid': false});
        }
      });

  /// Guest: "I have transferred".
  Future<void> claimPaid(String fid, String eid, String uid, bool value) =>
      _guard(() => _rsvps(fid, eid).doc(uid).update({
            'paidClaimed': value,
            'updatedAt': FieldValue.serverTimestamp(),
          }));

  /// Organizer: confirms (or undoes) a household's payment.
  Future<void> setPaid(String fid, String eid, String uid, bool value) =>
      _guard(() => _rsvps(fid, eid).doc(uid).update({
            'paid': value,
            if (value) 'paidClaimed': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }));
}
