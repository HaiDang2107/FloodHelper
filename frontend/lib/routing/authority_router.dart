import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/authority/view_models/authority_session_view_model.dart';
import '../ui/authority/views/login/authority_login_screen.dart';
import '../ui/authority/views/shell/authority_shell.dart';
import '../ui/authority/views/role_requests/role_requests_screen.dart';
import '../ui/authority/views/profile/authority_profile_screen.dart';
import '../ui/authority/views/charity/charity_campaign_screen.dart';
import '../ui/authority/views/announcements/announcements_screen.dart';

class AuthorityRoutes {
  static const String login = '/authority/login';
  static const String requests = '/authority/requests';
  static const String profile = '/authority/profile';
  static const String charity = '/authority/charity';
  static const String announcements = '/authority/announcements';
}

final authorityRouterProvider = Provider<GoRouter>((ref) {
  final isSignedIn = ref.watch(authoritySessionProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AuthorityRoutes.login,
    redirect: (context, state) {
      final bool loggedIn = isSignedIn;
      final bool onLogin = state.uri.path == AuthorityRoutes.login;

      if (!loggedIn && !onLogin) {
        return AuthorityRoutes.login;
      }
      if (loggedIn && onLogin) {
        return AuthorityRoutes.requests;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AuthorityRoutes.login,
        builder: (context, state) => const AuthorityLoginScreen(),
      ),
      ShellRoute( // Route của shell
        builder: (context, state, child) {
          return AuthorityShell(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AuthorityRoutes.requests,
            builder: (context, state) => RoleRequestsScreen(
              statusQuery: state.uri.queryParameters['status'],
            ), // match ==> là đầu vào ứng với child.
          ),
          GoRoute(
            path: AuthorityRoutes.profile,
            builder: (context, state) => const AuthorityProfileScreen(),
          ),
          GoRoute(
            path: AuthorityRoutes.charity,
            builder: (context, state) => const CharityCampaignScreen(),
          ),
          GoRoute(
            path: AuthorityRoutes.announcements,
            builder: (context, state) => const AnnouncementsScreen(),
          ),
        ],
      ),
    ],
  );
});
