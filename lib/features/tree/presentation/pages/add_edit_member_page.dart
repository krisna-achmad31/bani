import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/features/tree/data/repositories/tree_repository.dart';
import 'package:collection/collection.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/data/repositories/storage_repository.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/limit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  06 Tambah / Edit anggota — 4 steps: Identitas · Lahir · Pasangan · Kontak
// ─────────────────────────────────────────────────────────────────────────────

class AddEditMemberPage extends ConsumerStatefulWidget {
  const AddEditMemberPage({super.key, required this.familyId, this.parentId, this.editMemberId})
      : assert(parentId != null || editMemberId != null);

  final String familyId;
  final String? parentId;
  final String? editMemberId;

  bool get isEdit => editMemberId != null;

  @override
  ConsumerState<AddEditMemberPage> createState() => _AddEditMemberPageState();
}

class _SpouseDraft {
  _SpouseDraft([Spouse? s])
      : name = TextEditingController(text: s?.name),
        status = s?.status ?? SpouseStatus.married,
        memberId = s?.memberId;
  final TextEditingController name;
  SpouseStatus status;
  String? memberId;
}

class _AddEditMemberPageState extends ConsumerState<AddEditMemberPage> {
  List<String> get _steps => [
        context.t.formStepIdentity,
        context.t.formStepBirth,
        context.t.formStepSpouse,
        context.t.formStepContact,
      ];

  final _fullName = TextEditingController();
  final _nickname = TextEditingController();
  final _birthOrder = TextEditingController();
  final _occupation = TextEditingController();
  final _birthPlace = TextEditingController();
  final _phone = TextEditingController();
  final _addressDetail = TextEditingController();
  final _notes = TextEditingController();

  var _step = 0;
  var _saving = false;
  var _loaded = false;

  Gender _gender = Gender.male;
  DateTime? _birthDate;
  var _birthYearOnly = false;
  var _isDeceased = false;
  DateTime? _deathDate;
  var _deathYearOnly = false;
  GeoPlace? _grave;
  final _spouses = <_SpouseDraft>[];
  GeoPlace? _address;
  var _visibility = ContactVisibility.family;
  PickedPhoto? _newPhoto;
  String? _existingThumb;
  var _removePhoto = false;
  MemberModel? _original;
  MemberContact? _originalContact;

  @override
  void dispose() {
    for (final c in [_fullName, _nickname, _birthOrder, _occupation, _birthPlace,
        _phone, _addressDetail, _notes]) {
      c.dispose();
    }
    for (final s in _spouses) {
      s.name.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExisting(MemberModel m) async {
    _loaded = true;
    _original = m;
    for (final s in _spouses) {
      s.name.dispose();
    }
    _spouses.clear();
    _newPhoto = null;
    _removePhoto = false;
    _fullName.text = m.fullName;
    _nickname.text = m.nickname ?? '';
    _birthOrder.text = m.birthOrder?.toString() ?? '';
    _occupation.text = m.occupation ?? '';
    _birthPlace.text = m.birthPlace ?? '';
    _notes.text = m.notes ?? '';
    _gender = m.gender == Gender.unknown ? Gender.male : m.gender;
    _birthDate = m.birthDate;
    _birthYearOnly = m.birthYearOnly;
    _isDeceased = m.isDeceased;
    _deathDate = m.deathDate;
    _deathYearOnly = m.deathYearOnly;
    _grave = m.grave;
    _spouses.addAll(m.spouses.map(_SpouseDraft.new));
    _existingThumb = m.photoThumb;
    final contact = await ref
        .read(contactProvider((familyId: widget.familyId, memberId: m.memberId)).future)
        .catchError((_) => null);
    _originalContact = contact;
    if (!mounted || contact == null) return;
    setState(() {
      _phone.text = contact.phone ?? '';
      _address = contact.address;
      _addressDetail.text = contact.address?.detail ?? '';
      _visibility = contact.visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(familyIndexProvider(widget.familyId));
    if (index == null) return const Scaffold(body: LoadingView());

    final editing = widget.isEdit ? index.byId[widget.editMemberId] : null;
    final parent = widget.isEdit
        ? (editing == null ? null : index.parentOf(editing))
        : index.byId[widget.parentId];
    if (widget.isEdit && editing == null || !widget.isEdit && parent == null) {
      return Scaffold(appBar: AppBar(),
          body: MessageView(icon: Icons.person_off_outlined, title: context.t.notFound));
    }
    if (!_loaded) {
      if (editing != null) {
        _loadExisting(editing);
      } else {
        _loaded = true;
        _birthOrder.text = '${index.childrenOf(parent!.memberId).length + 1}';
      }
    }
    final generation = editing?.generation ?? parent!.generation + 1;
    final remaining = _remainingSlots();

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
          title: Text(widget.isEdit ? context.t.formEditTitle : context.t.formAddTitle),
          actions: [
            TextButton(onPressed: _saving ? null : () => _save(parent), child: Text(context.t.save)),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                if (parent != null) ...[
                  MemberAvatar(name: parent.fullName, photo: parent.photoThumb, size: 28,
                      ring: false, background: AppColors.surface),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    parent != null
                        ? context.t.formChildOf(parent.fullName, generation)
                        : context.t.formRoot(generation),
                    style: AppText.body(13, weight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ]),
            ),
            if (editing != null && _original != null && editing.version != _original!.version) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.goldSoft, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.sync_problem_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.t.formChangedBy((editing.updatedByName ?? '').isEmpty
                          ? context.t.someoneElse
                          : editing.updatedByName!),
                      style: AppText.body(13, weight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _loadExisting(editing);
                      if (mounted) setState(() {});
                    },
                    child: Text(context.t.formReload),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 18),
            Row(children: [
              for (var i = 0; i < _steps.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _step = i),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 4, decoration: BoxDecoration(
                          color: i <= _step ? AppColors.primary : AppColors.line,
                          borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 6),
                      Text(_steps[i], style: AppText.body(12,
                          weight: i == _step ? FontWeight.w700 : FontWeight.w500,
                          color: i == _step ? AppColors.primary
                              : i < _step ? AppColors.ink2 : AppColors.ink3)),
                    ]),
                  ),
                ),
                if (i < _steps.length - 1) const SizedBox(width: 6),
              ],
            ]),
            const SizedBox(height: 20),
            ...switch (_step) {
              0 => _identity(),
              1 => _birth(),
              2 => _spouseStep(),
              _ => _contactStep(),
            },
            if (_step == 0 && !widget.isEdit && remaining != null) ...[
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.ink3),
                const SizedBox(width: 8),
                Text(context.t.formQuotaUse(remaining),
                    style: AppText.body(12, color: AppColors.ink3)),
              ]),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line))),
            child: Row(children: [
              if (_step > 0) ...[
                SizedBox(
                  width: 52,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero,
                        foregroundColor: AppColors.ink),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving
                      ? null
                      : _step < _steps.length - 1
                          ? () {
                              if (_step == 0 && _fullName.text.trim().isEmpty) {
                                showMessage(context, context.t.formNameRequired);
                                return;
                              }
                              setState(() => _step++);
                            }
                          : () => _save(parent),
                  icon: Icon(_step < _steps.length - 1 ? Icons.arrow_forward : Icons.check),
                  label: Text(_saving
                      ? context.t.saving
                      : _step < _steps.length - 1
                          ? _nextLabel()
                          : widget.isEdit ? context.t.formSaveChanges : context.t.formSaveMember),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _nextLabel() =>
      [context.t.formNextBirth, context.t.formNextSpouse, context.t.formNextContact][_step];

  int? _remainingSlots() {
    final access = ref.watch(accessProvider(widget.familyId));
    final p = access.ownerProfile;
    if (p == null || p.isPaid || access.isSuperAdmin) return null;
    return (p.memberLimit - (access.family?.memberCount ?? 0)).clamp(0, p.memberLimit);
  }

  // ── Step 1: Identitas ─────────────────────────────────────────────────────

  List<Widget> _identity() {
    final thumb = _newPhoto?.thumbBase64 ?? (_removePhoto ? null : _existingThumb);
    return [
      Row(children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: thumb != null
              ? MemberAvatar(name: _fullName.text, photo: thumb, size: 84)
              : Container(
                  width: 84, height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: const Icon(Icons.photo_camera_outlined, color: AppColors.gold, size: 28),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(thumb == null ? context.t.formAddPhoto : context.t.formChangePhoto,
                style: AppText.body(15, weight: FontWeight.w700)),
            Text(context.t.formPhotoHint,
                style: AppText.body(12, color: AppColors.ink2, height: 1.4)),
          ]),
        ),
      ]),
      const SizedBox(height: 18),
      FieldLabel(context.t.formFullName),
      TextField(controller: _fullName, textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: context.t.formFullNameHint)),
      const SizedBox(height: 16),
      FieldLabel(context.t.formNickname),
      TextField(controller: _nickname, textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: context.t.formNicknameHint)),
      const SizedBox(height: 16),
      FieldLabel(context.t.formGender),
      Segmented<Gender>(
        options: const [Gender.male, Gender.female],
        value: _gender,
        labelOf: (g) => g.label,
        onChanged: (g) => setState(() => _gender = g),
      ),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 110,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel(context.t.formBirthOrder),
            TextField(controller: _birthOrder, keyboardType: TextInputType.number),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FieldLabel(context.t.formOccupation),
            TextField(controller: _occupation,
                decoration: InputDecoration(hintText: context.t.formOccupationHint)),
          ]),
        ),
      ]),
    ];
  }

  Future<void> _pickPhoto() async {
    final hasPhoto = _newPhoto != null || (!_removePhoto && _existingThumb != null);
    final source = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.photo_camera_outlined), title: Text(context.t.formCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: Text(context.t.formGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          if (hasPhoto)
            ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: Text(context.t.formRemovePhoto), onTap: () => Navigator.pop(ctx, 'remove')),
        ]),
      ),
    );
    if (source == null) return;
    if (source == 'remove') {
      setState(() {
        _newPhoto = null;
        _removePhoto = true;
      });
      return;
    }
    try {
      final photo = await ref.read(storageRepositoryProvider).pickPhoto(source as ImageSource);
      if (photo != null) {
        setState(() {
          _newPhoto = photo;
          _removePhoto = false;
        });
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  // ── Step 2: Lahir & wafat ─────────────────────────────────────────────────

  List<Widget> _birth() => [
        FieldLabel(context.t.formBirthPlace),
        TextField(controller: _birthPlace, textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: context.t.formBirthPlaceHint,
                prefixIcon: const Icon(Icons.place_outlined, color: AppColors.primary))),
        const SizedBox(height: 16),
        FieldLabel(context.t.formBirthDate),
        _DateField(
          value: _birthDate,
          yearOnly: _birthYearOnly,
          onChanged: (d) => setState(() => _birthDate = d),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _birthYearOnly,
          onChanged: (v) => setState(() => _birthYearOnly = v),
          title: Text(context.t.formYearOnlyKnown,
              style: AppText.body(14, color: AppColors.ink2)),
        ),
        const SizedBox(height: 8),
        FieldLabel(context.t.formStatus),
        Segmented<bool>(
          options: const [false, true],
          value: _isDeceased,
          labelOf: (d) => d ? context.t.deceased : context.t.alive,
          onChanged: (d) => setState(() => _isDeceased = d),
        ),
        if (_isDeceased) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface2, borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(context.t.formDeathDate),
              _DateField(
                value: _deathDate,
                yearOnly: _deathYearOnly,
                onChanged: (d) => setState(() => _deathDate = d),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _deathYearOnly,
                onChanged: (v) => setState(() => _deathYearOnly = v ?? false),
                title: Text(context.t.formYearOnly, style: AppText.body(14, color: AppColors.ink2)),
              ),
              FieldLabel(context.t.formGrave),
              _PlaceCard(
                place: _grave,
                emptyLabel: context.t.formGravePick,
                icon: Icons.place_outlined,
                onTap: () async {
                  final p = await context.push<GeoPlace>(AppRoutes.location,
                      extra: LocationPickerArgs(title: context.t.formGrave, initial: _grave));
                  if (p != null) setState(() => _grave = p);
                },
              ),
              const SizedBox(height: 8),
              Text(context.t.formGraveHint,
                  style: AppText.body(12, color: AppColors.ink3)),
            ]),
          ),
        ],
      ];

  // ── Step 3: Pasangan ──────────────────────────────────────────────────────

  List<Widget> _spouseStep() => [
        Text(context.t.formSpouseIntro,
            style: AppText.body(14, color: AppColors.ink2, height: 1.45)),
        const SizedBox(height: 16),
        for (var i = 0; i < _spouses.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface2, borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(context.t.formSpouseN(i + 1),
                    style: AppText.body(14, weight: FontWeight.w700))),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.ink3),
                  onPressed: () => setState(() => _spouses.removeAt(i).name.dispose()),
                ),
              ]),
              FieldLabel(context.t.formName),
              TextField(controller: _spouses[i].name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: context.t.formSpouseNameHint)),
              const SizedBox(height: 12),
              FieldLabel(context.t.formStatus),
              Segmented<SpouseStatus>(
                options: SpouseStatus.values,
                value: _spouses[i].status,
                labelOf: (s) => s.label,
                onChanged: (s) => setState(() => _spouses[i].status = s),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => setState(() => _spouses.add(_SpouseDraft())),
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.t.formAddSpouse),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: AppColors.line, width: 1.5),
          ),
        ),
      ];

  // ── Step 4: Kontak ────────────────────────────────────────────────────────

  List<Widget> _contactStep() => [
        FieldLabel(context.t.formWhatsapp),
        TextField(controller: _phone, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '0812 3456 7890',
                prefixIcon: Icon(Icons.chat_outlined, color: AppColors.primary))),
        const SizedBox(height: 16),
        FieldLabel(context.t.formHomeAddress),
        _PlaceCard(
          place: _address,
          emptyLabel: context.t.formAddressPick,
          icon: Icons.home_outlined,
          onTap: () async {
            final p = await context.push<GeoPlace>(AppRoutes.location,
                extra: LocationPickerArgs(title: context.t.formHomeAddress, initial: _address));
            if (p != null) {
              setState(() {
                _address = p;
                if (p.detail != null) _addressDetail.text = p.detail!;
              });
            }
          },
        ),
        if (_address != null) ...[
          const SizedBox(height: 8),
          TextField(controller: _addressDetail,
              decoration: InputDecoration(hintText: context.t.formAddressDetail)),
        ],
        const SizedBox(height: 16),
        FieldLabel(context.t.formWhoSeesContact),
        for (final (v, t, d) in [
          (ContactVisibility.family, context.t.formVisibilityFamily,
              context.t.formVisibilityFamilyHint),
          (ContactVisibility.admins, context.t.formVisibilityAdmins,
              context.t.formVisibilityAdminsHint),
        ]) ...[
          InkWell(
            onTap: () => setState(() => _visibility = v),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _visibility == v ? AppColors.primarySoft : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _visibility == v ? AppColors.primary : AppColors.line,
                    width: _visibility == v ? 1.5 : 1),
              ),
              child: Row(children: [
                Icon(_visibility == v ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _visibility == v ? AppColors.primary : AppColors.ink3),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: AppText.body(14, weight: FontWeight.w700)),
                  Text(d, style: AppText.body(12, color: AppColors.ink2)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        FieldLabel(context.t.formNotes),
        TextField(controller: _notes, maxLines: 3,
            decoration: InputDecoration(hintText: context.t.formNotesHint)),
      ];

  /// Saves [changes]; on a concurrent edit asks whether to reload or overwrite
  /// only the fields this user changed. Returns true when saved.
  Future<bool> _saveEdit(
      Map<String, dynamic> changes, int baseVersion, MemberContact? contact) async {
    final user = ref.read(currentUserProvider)!;
    try {
      await ref.read(treeRepositoryProvider).updateMember(
            familyId: widget.familyId,
            memberId: widget.editMemberId!,
            baseVersion: baseVersion,
            changes: changes,
            editor: user,
            newPhoto: _newPhoto,
            removePhoto: _removePhoto && _newPhoto == null,
            contact: contact,
          );
      return true;
    } on MemberConflict catch (c) {
      if (!mounted) return false;
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.t.formConflictTitle),
          content: Text(
            context.t.formConflictBody(c.message),
            style: AppText.body(14, height: 1.45),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'reload'),
                child: Text(context.t.formLoadLatest)),
            TextButton(onPressed: () => Navigator.pop(ctx, 'overwrite'),
                child: Text(context.t.formKeepMine)),
          ],
        ),
      );
      if (choice == 'overwrite') return _saveEdit(changes, c.latest.version, contact);
      if (choice == 'reload') {
        await _loadExisting(c.latest);
        if (mounted) setState(() {});
      }
      return false;
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save(MemberModel? parent) async {
    if (_fullName.text.trim().isEmpty) {
      setState(() => _step = 0);
      showMessage(context, context.t.formNameRequired);
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final base = _original ?? const MemberModel(memberId: '', fullName: '');
    final member = MemberModel(
      memberId: base.memberId,
      fullName: _fullName.text.trim(),
      nickname: _nickname.text,
      parentId: base.parentId,
      generation: base.generation,
      ancestors: base.ancestors,
      birthOrder: int.tryParse(_birthOrder.text.trim()),
      gender: _gender,
      birthPlace: _birthPlace.text,
      birthDate: _birthDate == null
          ? null
          : _birthYearOnly ? DateTime(_birthDate!.year) : _birthDate,
      birthYearOnly: _birthYearOnly,
      isDeceased: _isDeceased,
      deathDate: _deathDate == null
          ? null
          : _deathYearOnly ? DateTime(_deathDate!.year) : _deathDate,
      deathYearOnly: _deathYearOnly,
      grave: _grave,
      spouses: [
        for (final s in _spouses)
          if (s.name.text.trim().isNotEmpty)
            Spouse(name: s.name.text.trim(), status: s.status, memberId: s.memberId),
      ],
      occupation: _occupation.text,
      notes: _notes.text,
      photoThumb: base.photoThumb,
      hasPhoto: base.hasPhoto,
      claimedByUid: base.claimedByUid,
      createdBy: base.createdBy,
    );
    final contact = MemberContact(
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      address: _address?.copyWith(
          detail: _addressDetail.text.trim().isEmpty ? null : _addressDetail.text.trim()),
      visibility: _visibility,
    );

    setState(() => _saving = true);
    final repo = ref.read(treeRepositoryProvider);
    try {
      if (widget.isEdit) {
        final changes = diffMember(_original!, member);
        final contactChanged = !const DeepCollectionEquality().equals(
            contact.toMap(), (_originalContact ?? const MemberContact()).toMap());
        final saved = await _saveEdit(changes, _original!.version,
            contactChanged ? contact : null);
        if (saved && mounted) context.pop();
      } else {
        final id = await repo.addMember(
          familyId: widget.familyId,
          parent: parent!,
          member: member,
          uid: user.uid,
          photo: _newPhoto,
          contact: contact,
        );
        if (mounted) context.pushReplacement(AppRoutes.member(widget.familyId, id));
      }
    } catch (e) {
      if (!mounted) return;
      final failure = AppFailure.from(e);
      final check = parent == null
          ? AddCheck.ok
          : ref.read(accessProvider(widget.familyId)).canAddChild(parent);
      if (failure.isPermission && !widget.isEdit &&
          (check == AddCheck.memberLimit || check == AddCheck.branchLimit)) {
        await showLimitSheet(context, familyId: widget.familyId, reason: check, parent: parent);
      } else {
        showError(context, failure);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.yearOnly, required this.onChanged});
  final DateTime? value;
  final bool yearOnly;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime(1970),
            firstDate: DateTime(1700),
            lastDate: now,
            initialDatePickerMode: yearOnly ? DatePickerMode.year : DatePickerMode.day,
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            suffixIcon: value == null
                ? const Icon(Icons.calendar_today_outlined, color: AppColors.ink3)
                : IconButton(icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onChanged(null)),
          ),
          child: Text(
            value == null ? context.t.formPickDate : formatDate(value, yearOnly: yearOnly),
            style: AppText.body(16,
                weight: value == null ? FontWeight.w400 : FontWeight.w600,
                color: value == null ? AppColors.ink3 : AppColors.ink),
          ),
        ),
      );
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.emptyLabel, required this.icon,
      required this.onTap});
  final GeoPlace? place;
  final String emptyLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: AppColors.goldSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place?.text ?? emptyLabel,
                  style: AppText.body(14, weight: FontWeight.w700,
                      color: place == null ? AppColors.ink2 : AppColors.ink)),
              Text(place == null ? context.t.formTapToOpenMap : context.t.formChangeOnMap,
                  style: AppText.body(12, weight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ]),
      );
}
