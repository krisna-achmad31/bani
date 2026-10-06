import 'dart:typed_data';

import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/services/photo_cache.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/data/models/album_photo.dart';
import 'package:bani/features/tree/data/models/app_config.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/limit_sheet.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Album kenangan — old photos per member (base64, quota per tree)
// ─────────────────────────────────────────────────────────────────────────────

final albumProvider = StreamProvider.family<List<AlbumPhoto>, MemberKey>(
    (ref, k) => ref.watch(treeRepositoryProvider).watchAlbum(k.familyId, k.memberId));

typedef AlbumPhotoKey = ({String familyId, String memberId, String photoId});

/// Album photos never change (a new photo gets a new id), so they are cached
/// on the device forever and downloaded only once.
final albumFullProvider = FutureProvider.family<Uint8List?, AlbumPhotoKey>((ref, k) =>
    PhotoCache.instance.get('album_${k.photoId}',
        () => ref.read(treeRepositoryProvider).getAlbumFull(k.familyId, k.memberId, k.photoId)));

class AlbumSection extends ConsumerStatefulWidget {
  const AlbumSection({super.key, required this.familyId, required this.member});
  final String familyId;
  final MemberModel member;

  @override
  ConsumerState<AlbumSection> createState() => _AlbumSectionState();
}

class _AlbumSectionState extends ConsumerState<AlbumSection> {
  String? _progress;

  /// Remaining album slots for this tree, or null when unknown/unlimited.
  int? _remaining() {
    final access = ref.read(accessProvider(widget.familyId));
    final p = access.ownerProfile;
    if (access.isSuperAdmin || p == null) return null;
    final config = ref.read(configProvider).value ?? const AppConfig();
    final limit = config.plan(p.effectivePlan).album + p.albumBonus;
    return (limit - (access.family?.albumCount ?? 0)).clamp(0, limit);
  }

  Future<void> _add() async {
    final t = context.t;
    final access = ref.read(accessProvider(widget.familyId));
    final config = ref.read(configProvider).value ?? const AppConfig();
    final me = ref.read(userProfileProvider).value;
    final isAdmin = ref.read(isSuperAdminProvider).value ?? false;

    // Free trees need a few members first (keeps throwaway accounts from
    // using the album as free photo storage).
    if (!(access.family?.ownerPaid ?? false) &&
        (access.family?.memberCount ?? 0) < config.minMembersForAlbum) {
      showMessage(context, t.albumNeedMembers(config.minMembersForAlbum));
      return;
    }
    final remaining = _remaining();
    if (remaining == 0) {
      await showLimitSheet(context, familyId: widget.familyId, reason: AddCheck.albumLimit);
      return;
    }
    // Per-day upload limit of the uploader's own plan.
    final perDay = me == null ? 10 : config.plan(me.effectivePlan).uploadsPerDay;
    final leftToday = isAdmin || me == null ? null : perDay - me.uploadsToday();
    if (leftToday != null && leftToday <= 0) {
      showMessage(context, t.albumDailyLimit(perDay));
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final max = [remaining ?? 10, leftToday ?? 10].reduce((a, b) => a < b ? a : b);
      final photos = await ref.read(storageRepositoryProvider).pickAlbumPhotos(max: max);
      if (photos.isEmpty) return;
      final repo = ref.read(treeRepositoryProvider);
      var done = 0;
      for (final p in photos) {
        setState(() => _progress = t.albumUploading(done + 1, photos.length));
        await repo.addAlbumPhoto(
            familyId: widget.familyId, memberId: widget.member.memberId, photo: p, user: user);
        done++;
      }
      if (mounted) showMessage(context, t.albumUploaded(done));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final key = (familyId: widget.familyId, memberId: widget.member.memberId);
    final photos = ref.watch(albumProvider(key)).value ?? const <AlbumPhoto>[];
    final access = ref.watch(accessProvider(widget.familyId));
    final canEdit = access.canEdit(widget.member);
    final remaining = canEdit ? _remaining() : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel(
        t.albumTitle(photos.length),
        trailing: canEdit
            ? TextButton.icon(
                onPressed: _progress == null ? _add : null,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(_progress ?? t.albumAdd),
              )
            : null,
      ),
      if (remaining != null) ...[
        Text(
          t.albumQuota(access.family?.albumCount ?? 0,
              (access.family?.albumCount ?? 0) + remaining),
          style: AppText.body(12, color: AppColors.ink3),
        ),
        const SizedBox(height: 4),
      ],
      const SizedBox(height: 8),
      if (photos.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.photo_library_outlined, color: AppColors.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t.albumEmpty,
                  style: AppText.body(13, color: AppColors.ink2, height: 1.4)),
            ),
          ]),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: photos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
          itemBuilder: (_, i) {
            final p = photos[i];
            final bytes = decodeBase64Image(p.thumb);
            return FadeSlideIn(
              index: i,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AlbumViewer(
                    familyId: widget.familyId,
                    member: widget.member,
                    photos: photos,
                    initialIndex: i,
                    canEdit: canEdit,
                  ),
                )),
                child: Hero(
                  tag: 'album-${p.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(fit: StackFit.expand, children: [
                      if (bytes != null)
                        Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true)
                      else
                        Container(color: AppColors.surface2),
                      if (p.year != null)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${p.year}',
                                style: AppText.body(10,
                                    weight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
    ]);
  }
}

/// Swipe through a member's album; loads each ~1280px photo on demand.
class AlbumViewer extends ConsumerStatefulWidget {
  const AlbumViewer({
    super.key,
    required this.familyId,
    required this.member,
    required this.photos,
    required this.initialIndex,
    required this.canEdit,
  });

  final String familyId;
  final MemberModel member;
  final List<AlbumPhoto> photos;
  final int initialIndex;
  final bool canEdit;

  @override
  ConsumerState<AlbumViewer> createState() => _AlbumViewerState();
}

class _AlbumViewerState extends ConsumerState<AlbumViewer> {
  late final _pager = PageController(initialPage: widget.initialIndex);
  late var _index = widget.initialIndex;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  AlbumPhoto get _current => widget.photos[_index];

  Future<void> _editCaption() async {
    final t = context.t;
    final caption = TextEditingController(text: _current.caption);
    final year = TextEditingController(text: _current.year?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.albumCaptionTitle),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: caption, decoration: InputDecoration(hintText: t.albumCaptionHint)),
          const SizedBox(height: 12),
          TextField(
              controller: year,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: t.albumYearHint)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.save)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(treeRepositoryProvider).updateAlbumCaption(widget.familyId,
          widget.member.memberId, _current.id, caption.text, int.tryParse(year.text.trim()));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete() async {
    final t = context.t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.albumDelete),
        content: Text(t.albumDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(treeRepositoryProvider)
          .deleteAlbumPhoto(widget.familyId, widget.member.memberId, _current.id);
      await PhotoCache.instance.evict('album_${_current.id}');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = _current;
    final meta = [
      if (p.year != null) '${p.year}',
      if ((p.uploadedByName ?? '').isNotEmpty) t.albumBy(p.uploadedByName!),
    ].join(' · ');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.member.fullName} · ${_index + 1}/${widget.photos.length}',
            style: AppText.body(15, weight: FontWeight.w600, color: Colors.white)),
        actions: [
          if (widget.canEdit) ...[
            IconButton(
                tooltip: t.albumEditCaption,
                icon: const Icon(Icons.edit_outlined),
                onPressed: _editCaption),
            IconButton(
                tooltip: t.albumDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete),
          ],
        ],
      ),
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pager,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final photo = widget.photos[i];
              final full = ref.watch(albumFullProvider((
                familyId: widget.familyId,
                memberId: widget.member.memberId,
                photoId: photo.id,
              )));
              final bytes = full.value ?? decodeBase64Image(photo.thumb);
              return InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: 'album-${photo.id}',
                    child: Stack(alignment: Alignment.center, children: [
                      if (bytes != null)
                        Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true),
                      if (full.isLoading)
                        const CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if ((p.caption ?? '').isNotEmpty)
                  Text(p.caption!,
                      style: AppText.body(16, weight: FontWeight.w600, color: Colors.white)),
                if (meta.isNotEmpty)
                  Text(meta, style: AppText.body(12, color: Colors.white70)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
