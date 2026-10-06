import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/router/app_router.dart';
import 'package:bani/core/services/excel_export_service.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/widgets/chart_view.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/features/tree/presentation/widgets/family_picker.dart';
import 'package:bani/features/tree/presentation/widgets/focus_view.dart';
import 'package:bani/features/tree/presentation/widgets/limit_sheet.dart';
import 'package:bani/features/tree/presentation/widgets/move_member_sheet.dart';
import 'package:bani/features/tree/presentation/widgets/silsilah_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  04 Pohon — three views of the same tree (bani.pen 04a–04c):
//  "Bagan" (classic zoomable chart), "Silsilah" (indented list that grows
//  downward, made for portrait phones) and "Fokus" (one person at a time).
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the add-child form, or the limit sheet when the parent is out of quota.
Future<void> startAddChild(
    BuildContext context, WidgetRef ref, String familyId, MemberModel parent) async {
  final check = ref.read(accessProvider(familyId)).canAddChild(parent);
  switch (check) {
    case AddCheck.ok:
      context.push(AppRoutes.addChild(familyId, parent.memberId));
    case AddCheck.branchLimit ||
          AddCheck.memberLimit ||
          AddCheck.albumLimit ||
          AddCheck.treeLimit:
      await showLimitSheet(context, familyId: familyId, reason: check, parent: parent);
    case AddCheck.notAllowed:
      showMessage(context, context.t.treeOnlyOwnBranch);
  }
}

enum TreeMode { chart, silsilah, focus }

/// Last chosen view, kept while the app runs.
class TreeModeNotifier extends Notifier<TreeMode> {
  @override
  TreeMode build() => TreeMode.silsilah;
  void set(TreeMode mode) => state = mode;
}

final treeModeProvider = NotifierProvider<TreeModeNotifier, TreeMode>(TreeModeNotifier.new);

class TreePage extends ConsumerWidget {
  const TreePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fid = ref.watch(activeFamilyIdProvider);
    final families = ref.watch(userFamiliesProvider);
    if (fid == null) {
      return families.isLoading
          ? const LoadingView()
          : MessageView(
              icon: Icons.account_tree_outlined,
              title: context.t.treeEmptyTitle,
              message: context.t.treeEmptyBody,
            );
    }
    return _TreeView(key: ValueKey(fid), familyId: fid);
  }
}

class _TreeView extends ConsumerStatefulWidget {
  const _TreeView({super.key, required this.familyId});
  final String familyId;

  @override
  ConsumerState<_TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends ConsumerState<_TreeView> {
  final _chart = GlobalKey<ChartViewState>();
  final _silsilah = GlobalKey<SilsilahViewState>();
  final _focus = GlobalKey<FocusViewState>();
  var _onlyMyBranch = false;
  var _refreshing = false;

  /// Re-reads the tree from the server (not the offline cache).
  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await ref.read(treeRepositoryProvider).refreshFamily(widget.familyId);
      ref.invalidate(myGrantProvider(widget.familyId));
      if (mounted) showMessage(context, context.t.treeRefreshed);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  String? _myMemberId(FamilyIndex index) {
    final uid = ref.read(currentUserProvider)?.uid;
    final grant = ref.read(myGrantProvider(widget.familyId)).value;
    return index.byId.values.where((m) => m.claimedByUid == uid).firstOrNull?.memberId ??
        grant?.anchorMemberId;
  }

  /// Shows [memberId] in whichever view is active.
  void _goTo(String memberId) {
    switch (ref.read(treeModeProvider)) {
      case TreeMode.chart:
        _chart.currentState?.reveal(memberId);
      case TreeMode.silsilah:
        _silsilah.currentState?.reveal(memberId);
      case TreeMode.focus:
        _focus.currentState?.focus(memberId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fid = widget.familyId;
    final family = ref.watch(familyProvider(fid)).value;
    final membersAsync = ref.watch(membersProvider(fid));
    final index = ref.watch(familyIndexProvider(fid));
    final access = ref.watch(accessProvider(fid));
    final mode = ref.watch(treeModeProvider);
    final anchor = access.grant?.anchorMemberId;
    final canFilter = anchor != null && !access.canManage;
    final t = context.t;

    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
          child: Row(children: [
            Expanded(
              child: InkWell(
                onTap: () => showFamilyPicker(context, ref, current: fid),
                borderRadius: BorderRadius.circular(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Text(family?.name ?? '...',
                          overflow: TextOverflow.ellipsis, style: AppText.display(26)),
                    ),
                    const Icon(Icons.expand_more_rounded, color: AppColors.ink2),
                  ]),
                  Text(
                    t.membersCount(family?.memberCount ?? 0) +
                        (index != null ? ', ${t.generationsCount(index.maxGeneration)}' : ''),
                    style: AppText.body(13, color: AppColors.ink2),
                  ),
                ]),
              ),
            ),
            if (canFilter) ...[
              _BranchFilterButton(
                selected: _onlyMyBranch,
                onTap: () => setState(() => _onlyMyBranch = !_onlyMyBranch),
              ),
              const SizedBox(width: 8),
            ],
            CircleIconButton(
              icon: Icons.search_rounded,
              tooltip: t.treeSearch,
              onPressed: index == null ? null : () => _search(context, index),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) => _menu(v, family, index),
              itemBuilder: (_) => [
                if (mode == TreeMode.silsilah) ...[
                  PopupMenuItem(value: 'expand', child: Text(t.silsilahExpandAll)),
                  PopupMenuItem(value: 'collapse', child: Text(t.silsilahCollapseAll)),
                ],
                PopupMenuItem(
                    value: 'refresh', enabled: !_refreshing, child: Text(t.treeRefresh)),
                PopupMenuItem(value: 'export', child: Text(t.treeExport)),
                if (access.canManage)
                  PopupMenuItem(value: 'rename', child: Text(t.treeRename)),
              ],
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _ModeToggle(
            mode: mode,
            onChanged: (m) => ref.read(treeModeProvider.notifier).set(m),
          ),
        ),
        Expanded(
          child: membersAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) =>
                MessageView(icon: Icons.cloud_off_rounded, title: t.loadFailed, message: '$e'),
            data: (_) {
              if (index == null || index.byId.isEmpty) return const LoadingView();
              final me = _myMemberId(index);
              final uid = ref.read(currentUserProvider)?.uid;
              final rootId = _onlyMyBranch ? anchor : null;
              // Only a node the user actually claimed is labelled as them;
              // [me] may fall back to the grant anchor for navigation.
              bool isMe(MemberModel m) => m.claimedByUid != null && m.claimedByUid == uid;
              bool atLimit(MemberModel m) =>
                  access.grant?.maxGeneration != null &&
                  !access.canManage &&
                  !(family?.ownerPaid ?? false) &&
                  access.inBranch(m) &&
                  m.generation >= access.grant!.maxGeneration!;
              void open(MemberModel m) => context.push(AppRoutes.member(fid, m.memberId));

              return Stack(children: [
                Positioned.fill(
                  child: switch (mode) {
                    TreeMode.chart => ChartView(
                        key: _chart,
                        index: index,
                        rootId: rootId,
                        isMe: isMe,
                        atLimit: atLimit,
                        onOpen: open,
                        onActions: (m) => _nodeActions(context, m),
                      ),
                    TreeMode.silsilah => SilsilahView(
                          key: _silsilah,
                          index: index,
                          rootId: rootId,
                          meId: me,
                          isMe: isMe,
                          atLimit: atLimit,
                          onOpen: open,
                          onActions: (m) => _nodeActions(context, m),
                        ),
                    TreeMode.focus => FocusView(
                          key: _focus,
                          index: index,
                          rootId: rootId,
                          initialId: me,
                          isMe: isMe,
                          canAddChild: (_) =>
                              access.role != null && access.role != FamilyRole.viewer,
                          onOpen: open,
                          onAddChild: (m) => startAddChild(context, ref, fid, m),
                        ),
                  },
                ),
                if (me != null)
                  Positioned(
                    left: 16,
                    bottom: 104,
                    child: FilledButton.icon(
                      onPressed: () => _goTo(me),
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: Text(t.treeGoToMe),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        minimumSize: const Size(0, 44),
                        shape: const StadiumBorder(),
                        textStyle: AppText.body(13, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (me != null && mode != TreeMode.focus && access.role != FamilyRole.viewer)
                  Positioned(
                    right: 16,
                    bottom: 96,
                    child: FloatingActionButton(
                      heroTag: 'add-child',
                      tooltip: t.treeAddChild,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      onPressed: () => startAddChild(context, ref, fid, index.byId[me]!),
                      child: const Icon(Icons.person_add_alt_1_rounded),
                    ),
                  ),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  Future<void> _menu(String v, FamilyModel? family, FamilyIndex? index) async {
    switch (v) {
      case 'expand':
        _silsilah.currentState?.expandAll();
      case 'collapse':
        _silsilah.currentState?.collapseAll();
      case 'refresh':
        await _refresh();
      case 'export' when index != null && family != null:
        try {
          await ExcelExportService.export(family.name, index);
        } catch (e) {
          if (mounted) showError(context, e);
        }
      case 'rename' when family != null:
        await _rename(context, family);
    }
  }

  Future<void> _nodeActions(BuildContext context, MemberModel m) async {
    final access = ref.read(accessProvider(widget.familyId));
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: MemberAvatar(name: m.fullName, photo: m.photoThumb, size: 40, ring: false),
            title: Text(m.fullName, style: AppText.body(16, weight: FontWeight.w700)),
            subtitle: Text(context.t.generation(m.generation)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.t.treeViewDetail),
            onTap: () {
              Navigator.pop(ctx);
              context.push(AppRoutes.member(widget.familyId, m.memberId));
            },
          ),
          ListTile(
            leading: const Icon(Icons.center_focus_strong_outlined),
            title: Text(context.t.treeShowInFocus),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(treeModeProvider.notifier).set(TreeMode.focus);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _focus.currentState?.focus(m.memberId));
            },
          ),
          if (access.role != FamilyRole.viewer || access.isSuperAdmin)
            ListTile(
              leading: const Icon(Icons.person_add_alt_outlined),
              title: Text(context.t.treeAddChild),
              onTap: () {
                Navigator.pop(ctx);
                startAddChild(context, ref, widget.familyId, m);
              },
            ),
          if (access.canEdit(m))
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.t.treeEditData),
              onTap: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.editMember(widget.familyId, m.memberId));
              },
            ),
          if (access.canManage && !m.isRoot)
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: Text(context.t.treeMove),
              onTap: () {
                Navigator.pop(ctx);
                startMoveMember(context, ref, widget.familyId, m);
              },
            ),
        ]),
      ),
    );
  }

  Future<void> _rename(BuildContext context, FamilyModel family) async {
    final ctrl = TextEditingController(text: family.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.treeRenameTitle),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.t.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(context.t.save)),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(treeRepositoryProvider).renameFamily(family.familyId, name);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _search(BuildContext context, FamilyIndex index) async {
    final picked = await showSearch<MemberModel?>(
        context: context, delegate: _MemberSearch(index, context.t.searchName));
    if (picked != null) _goTo(picked.memberId);
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final TreeMode mode;
  final ValueChanged<TreeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget seg(TreeMode m, IconData icon, String label) {
      final on = m == mode;
      return Expanded(
        child: Semantics(
          selected: on,
          button: true,
          child: GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: on ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: on
                    ? const [
                        BoxShadow(color: Color(0x14211B17), blurRadius: 3, offset: Offset(0, 1)),
                      ]
                    : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 16, color: on ? AppColors.primary : AppColors.ink2),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(13,
                          weight: on ? FontWeight.w700 : FontWeight.w500,
                          color: on ? AppColors.ink : AppColors.ink2)),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        seg(TreeMode.chart, Icons.account_tree_outlined, t.treeModeChart),
        seg(TreeMode.silsilah, Icons.format_list_bulleted_rounded, t.treeModeList),
        seg(TreeMode.focus, Icons.center_focus_strong_outlined, t.treeModeFocus),
      ]),
    );
  }
}

/// "Cabang saya" for contributors: shows only their own branch.
class _BranchFilterButton extends StatelessWidget {
  const _BranchFilterButton({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        child: Material(
          color: selected ? AppColors.ink : AppColors.surface,
          shape: CircleBorder(
              side: BorderSide(color: selected ? AppColors.ink : AppColors.line)),
          child: IconButton(
            tooltip: selected ? context.t.treeFilterMine : context.t.treeFilterAllBranches,
            onPressed: onTap,
            icon: Icon(Icons.filter_alt_outlined,
                size: 20, color: selected ? Colors.white : AppColors.ink),
          ),
        ),
      );
}

class _MemberSearch extends SearchDelegate<MemberModel?> {
  _MemberSearch(this.index, String label) : super(searchFieldLabel: label);
  final FamilyIndex index;

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase().trim();
    final results = index.dfs().where((m) =>
        q.isEmpty ||
        m.fullName.toLowerCase().contains(q) ||
        (m.nickname?.toLowerCase().contains(q) ?? false)).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final m = results[i];
        final parent = index.parentOf(m);
        return ListTile(
          leading: MemberAvatar(name: m.fullName, photo: m.photoThumb, size: 40, ring: false),
          title: Text(m.fullName),
          subtitle: Text(context.t.generation(m.generation) +
              (parent != null ? ' · ${context.t.childOf(parent.fullName)}' : '')),
          onTap: () => close(context, m),
        );
      },
    );
  }
}
