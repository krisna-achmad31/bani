import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/events/data/models/event_model.dart';
import 'package:bani/features/events/presentation/event_providers.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  13 Buat Acara — create or edit an event
// ─────────────────────────────────────────────────────────────────────────────

class EditEventPage extends ConsumerWidget {
  const EditEventPage({super.key, required this.familyId, this.eventId});
  final String familyId;
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventId == null) return _EventForm(familyId: familyId);
    final async = ref.watch(eventProvider((familyId: familyId, eventId: eventId!)));
    final event = async.value;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: async.isLoading
            ? const LoadingView()
            : MessageView(icon: Icons.event_busy_outlined, title: context.t.notFound),
      );
    }
    return _EventForm(familyId: familyId, initial: event);
  }
}

class _EventForm extends ConsumerStatefulWidget {
  const _EventForm({required this.familyId, this.initial});
  final String familyId;
  final EventModel? initial;

  @override
  ConsumerState<_EventForm> createState() => _EventFormState();
}

class _AgendaRow {
  _AgendaRow(String time, String text)
      : time = TextEditingController(text: time),
        text = TextEditingController(text: text);
  final TextEditingController time;
  final TextEditingController text;
  void dispose() {
    time.dispose();
    text.dispose();
  }
}

class _EventFormState extends ConsumerState<_EventForm> {
  late EventType _type;
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _dues;
  late DateTime _start;
  DateTime? _end;
  GeoPlace? _place;
  String? _branchId;
  late bool _hasDues;
  late final List<_AgendaRow> _agenda;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    final now = DateTime.now();
    _type = e?.type ?? EventType.reunion;
    _title = TextEditingController(text: e?.title ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _dues = TextEditingController(
        text: (e?.duesAmount ?? 0) > 0 ? e!.duesAmount.toString() : '');
    _hasDues = (e?.duesAmount ?? 0) > 0;
    _start = e?.startAt ?? DateTime(now.year, now.month, now.day + 14, 9);
    _end = e?.endAt;
    _place = e?.place;
    _branchId = e?.branchId;
    _agenda = [for (final a in e?.agenda ?? const <AgendaItem>[]) _AgendaRow(a.time, a.text)];
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _dues.dispose();
    for (final a in _agenda) {
      a.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d == null || !mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_start));
    setState(() {
      _start = DateTime(d.year, d.month, d.day, time?.hour ?? _start.hour,
          time?.minute ?? _start.minute);
      if (_end != null && _end!.isBefore(_start)) _end = null;
    });
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end ?? _start.add(const Duration(days: 1)),
      firstDate: _start,
      lastDate: _start.add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _end = DateTime(d.year, d.month, d.day, 23, 59));
  }

  Future<void> _save() async {
    final t = context.t;
    if (_title.text.trim().isEmpty) {
      showMessage(context, t.eventFormTitleRequired);
      return;
    }
    final dues = _hasDues ? int.tryParse(_dues.text.replaceAll('.', '')) ?? 0 : 0;
    final index = ref.read(familyIndexProvider(widget.familyId));
    final branch = _branchId == null ? null : index?.byId[_branchId];
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final me = ref.read(myMemberProvider(widget.familyId));
    final event = EventModel(
      eventId: widget.initial?.eventId ?? '',
      familyId: widget.familyId,
      type: _type,
      title: _title.text,
      startAt: _start,
      endAt: _end,
      place: _place,
      notes: _notes.text,
      branchId: branch?.memberId,
      branchName: branch?.fullName,
      duesAmount: dues,
      agenda: [for (final a in _agenda) AgendaItem(time: a.time.text, text: a.text.text)],
    );
    setState(() => _saving = true);
    try {
      final id = await ref.read(eventRepositoryProvider).saveEvent(event,
          uid: user.uid, userName: me?.fullName ?? user.displayName ?? '');
      if (!mounted) return;
      if (widget.initial == null) {
        context.pushReplacement(AppRoutes.event(widget.familyId, id));
        showMessage(context, t.eventCreated);
      } else {
        context.pop();
        showMessage(context, t.eventSaved);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final index = ref.watch(familyIndexProvider(widget.familyId));
    final branches = index?.branchHeads ?? const <MemberModel>[];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: t.cancel,
          onPressed: () => context.pop(),
        ),
        title: Text(widget.initial == null ? t.eventCreate : t.eventEdit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          FieldLabel(t.eventFormType),
          _TypeGrid(value: _type, onChanged: (v) => setState(() => _type = v)),
          const SizedBox(height: 20),
          FieldLabel(t.eventFormName),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 120,
            decoration: InputDecoration(hintText: t.eventFormNameHint, counterText: ''),
          ),
          const SizedBox(height: 20),
          FieldLabel(t.eventFormDate),
          Row(children: [
            Expanded(
              child: _PickerField(
                icon: Icons.calendar_today_outlined,
                text: '${formatShortDay(_start)} ${_start.year}, ${formatTime(_start)}',
                onTap: _pickStart,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _end == null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(t.eventFormAddEnd),
                  ),
                )
              : Row(children: [
                  Expanded(
                    child: _PickerField(
                      icon: Icons.event_available_outlined,
                      text: t.eventFormUntil(formatDate(_end!)),
                      onTap: _pickEnd,
                    ),
                  ),
                  IconButton(
                    tooltip: t.delete,
                    onPressed: () => setState(() => _end = null),
                    icon: const Icon(Icons.close_rounded, color: AppColors.ink3),
                  ),
                ]),
          const SizedBox(height: 12),
          FieldLabel(t.eventFormPlace),
          _PickerField(
            icon: Icons.place_outlined,
            text: _place?.text ?? t.eventFormPlacePick,
            muted: _place == null,
            onTap: () async {
              final p = await context.push<GeoPlace>(AppRoutes.location,
                  extra: LocationPickerArgs(title: t.eventFormPlace, initial: _place));
              if (p != null) setState(() => _place = p);
            },
          ),
          const SizedBox(height: 20),
          FieldLabel(t.eventFormInvite),
          Segmented<bool>(
            options: const [false, true],
            value: _branchId != null,
            labelOf: (b) => b ? t.eventFormInviteBranch : t.eventFormInviteAll,
            onChanged: (b) => setState(
                () => _branchId = b ? (branches.firstOrNull?.memberId) : null),
          ),
          if (_branchId != null && branches.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: branches.any((b) => b.memberId == _branchId) ? _branchId : null,
              items: [
                for (final b in branches)
                  DropdownMenuItem(value: b.memberId, child: Text(t.eventBranch(b.fullName))),
              ],
              onChanged: (v) => setState(() => _branchId = v),
            ),
          ],
          const SizedBox(height: 6),
          Text(t.eventFormInviteHint, style: AppText.body(12, color: AppColors.ink3)),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _hasDues,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => setState(() => _hasDues = v),
                title: Text(t.eventFormDues, style: AppText.body(14, weight: FontWeight.w700)),
                subtitle: Text(t.eventFormDuesHint, style: AppText.body(12, color: AppColors.ink2)),
              ),
              if (_hasDues)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _dues,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(prefixText: 'Rp ', hintText: '150000'),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: FieldLabel(t.eventAgenda)),
            TextButton.icon(
              onPressed: () => setState(() => _agenda.add(_AgendaRow('', ''))),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(t.eventFormAgendaAdd),
            ),
          ]),
          for (final (i, a) in _agenda.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: a.time,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      hintText: '09.00',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: a.text,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(hintText: t.eventFormAgendaHint),
                  ),
                ),
                IconButton(
                  tooltip: t.delete,
                  onPressed: () => setState(() => _agenda.removeAt(i).dispose()),
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink3),
                ),
              ]),
            ),
          const SizedBox(height: 16),
          FieldLabel(t.eventNotes),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: t.eventFormNotesHint),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(widget.initial == null ? t.eventFormSubmit : t.save),
          ),
        ],
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.value, required this.onChanged});
  final EventType value;
  final ValueChanged<EventType> onChanged;

  @override
  Widget build(BuildContext context) {
    const types = EventType.values;
    Widget cell(EventType type) {
      final on = type == value;
      return Expanded(
        child: Semantics(
          selected: on,
          button: true,
          child: Material(
            color: on ? AppColors.primarySoft : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                  color: on ? AppColors.primary : AppColors.line, width: on ? 1.5 : 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(type),
              child: SizedBox(
                height: 72,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(type.icon, size: 22, color: on ? AppColors.primary : AppColors.ink2),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(type.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12,
                            weight: on ? FontWeight.w700 : FontWeight.w600,
                            color: on ? AppColors.primary : AppColors.ink)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    return Column(children: [
      for (var r = 0; r < types.length; r += 3) ...[
        Row(children: [
          for (var c = r; c < r + 3; c++) ...[
            if (c > r) const SizedBox(width: 8),
            cell(types[c]),
          ],
        ]),
        if (r + 3 < types.length) const SizedBox(height: 8),
      ],
    ]);
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.text,
    required this.onTap,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: Row(children: [
              Icon(icon, size: 18, color: AppColors.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(15,
                        weight: FontWeight.w500,
                        color: muted ? AppColors.ink3 : AppColors.ink)),
              ),
            ]),
          ),
        ),
      );
}
