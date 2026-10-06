import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppShell — floating capsule tab bar (Beranda · Pohon · Acara · Undang · Profil)
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static List<(IconData, IconData, String)> _tabs(L10n t) => [
        (Icons.home_outlined, Icons.home_rounded, t.tabHome),
        (Icons.account_tree_outlined, Icons.account_tree_rounded, t.tabTree),
        (Icons.event_outlined, Icons.event_rounded, t.tabEvents),
        (Icons.person_add_alt_outlined, Icons.person_add_alt_1_rounded, t.tabInvite),
        (Icons.account_circle_outlined, Icons.account_circle_rounded, t.tabProfile),
      ];

  /// Back on another tab returns to Beranda; back on Beranda asks to exit.
  Future<void> _onBack(BuildContext context) async {
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return;
    }
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.exitTitle, style: AppText.display(22)),
        content: Text(context.t.exitBody,
            style: AppText.body(14, color: AppColors.ink2, height: 1.45)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink2),
            child: Text(context.t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(context.t.exitConfirm),
          ),
        ],
      ),
    );
    if (exit == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    final tabs = _tabs(context.t);
    return Scaffold(
      body: shell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(color: Color(0x1F1F2A24), blurRadius: 20, offset: Offset(0, 6)),
            ],
          ),
          child: Row(children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(child: _TabItem(
                icon: shell.currentIndex == i ? tabs[i].$2 : tabs[i].$1,
                label: tabs[i].$3,
                selected: shell.currentIndex == i,
                onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              )),
          ]),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.selected,
      required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.ink3;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.clip, style: AppText.body(10,
                weight: selected ? FontWeight.w700 : FontWeight.w500, color: color)),
          ]),
        ),
      ),
    );
  }
}
