import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/features/auth/presentation/pages/claim_invite_page.dart';
import 'package:bani/features/auth/presentation/pages/login_page.dart';
import 'package:bani/features/events/presentation/pages/edit_event_page.dart';
import 'package:bani/features/events/presentation/pages/event_detail_page.dart';
import 'package:bani/features/events/presentation/pages/events_page.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/presentation/pages/add_edit_member_page.dart';
import 'package:bani/features/tree/presentation/pages/family_list_page.dart';
import 'package:bani/features/tree/presentation/pages/invite_page.dart';
import 'package:bani/features/tree/presentation/pages/location_picker_page.dart';
import 'package:bani/features/tree/presentation/pages/member_detail_page.dart';
import 'package:bani/features/tree/presentation/pages/profile_page.dart';
import 'package:bani/features/tree/presentation/pages/tree_page.dart';
import 'package:bani/features/tree/presentation/widgets/app_shell.dart';
import 'package:bani/features/tree/presentation/widgets/feedback_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Routes
// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const tree = '/tree';
  static const events = '/events';
  static const share = '/share';
  static const profile = '/profile';
  static String join(String token) => '/join/$token';
  static String member(String fid, String mid) => '/f/$fid/m/$mid';
  static String editMember(String fid, String mid) => '/f/$fid/m/$mid/edit';
  static String addChild(String fid, String parentId) => '/f/$fid/add/$parentId';
  static String event(String fid, String eid) => '/f/$fid/e/$eid';
  static String editEvent(String fid, String eid) => '/f/$fid/e/$eid/edit';
  static String newEvent(String fid) => '/f/$fid/events/new';
  static const location = '/location';
  static const feedbackInbox = '/feedback';
}

class LocationPickerArgs {
  const LocationPickerArgs({required this.title, this.initial});
  final String title;
  final GeoPlace? initial;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value != null;
      final path = state.matchedLocation;

      // App Link: https://<host>/invite?t=<token>
      if (path == '/invite') {
        final token = state.uri.queryParameters['t'];
        return token == null ? AppRoutes.home : AppRoutes.join(token);
      }
      if (!loggedIn) {
        if (path.startsWith('/join/')) {
          ref.read(pendingInviteProvider.notifier).set(state.pathParameters['token']);
        }
        return path == AppRoutes.login ? null : AppRoutes.login;
      }
      if (path == AppRoutes.login) {
        final pending = ref.read(pendingInviteProvider);
        return pending != null ? AppRoutes.join(pending) : AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: '/invite', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/join/:token',
        builder: (_, s) => ClaimInvitePage(token: s.pathParameters['token']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, _) => const FamilyListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.tree, builder: (_, _) => const TreePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.events, builder: (_, _) => const EventsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.share, builder: (_, _) => const InvitePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfilePage()),
          ]),
        ],
      ),
      GoRoute(
        path: '/f/:fid/m/:mid',
        builder: (_, s) => MemberDetailPage(
            familyId: s.pathParameters['fid']!, memberId: s.pathParameters['mid']!),
      ),
      GoRoute(
        path: '/f/:fid/m/:mid/edit',
        builder: (_, s) => AddEditMemberPage(
            familyId: s.pathParameters['fid']!, editMemberId: s.pathParameters['mid']),
      ),
      GoRoute(
        path: '/f/:fid/add/:parentId',
        builder: (_, s) => AddEditMemberPage(
            familyId: s.pathParameters['fid']!, parentId: s.pathParameters['parentId']),
      ),
      GoRoute(
        path: '/f/:fid/events/new',
        builder: (_, s) => EditEventPage(familyId: s.pathParameters['fid']!),
      ),
      GoRoute(
        path: '/f/:fid/e/:eid',
        builder: (_, s) => EventDetailPage(
            familyId: s.pathParameters['fid']!, eventId: s.pathParameters['eid']!),
      ),
      GoRoute(
        path: '/f/:fid/e/:eid/edit',
        builder: (_, s) => EditEventPage(
            familyId: s.pathParameters['fid']!, eventId: s.pathParameters['eid']),
      ),
      GoRoute(
        path: AppRoutes.feedbackInbox,
        builder: (_, _) => const FeedbackInboxPage(),
      ),
      GoRoute(
        path: AppRoutes.location,
        builder: (_, s) => LocationPickerPage(
            args: s.extra as LocationPickerArgs? ??
                LocationPickerArgs(title: tr.mapTitleDefault)),
      ),
    ],
    errorBuilder: (_, s) =>
        Scaffold(body: Center(child: Text('Halaman tidak ditemukan: ${s.uri}'))),
  );
});
