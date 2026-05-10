import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/admin/view_models/admin_session_view_model.dart';
import '../ui/admin/views/login/admin_login_screen.dart';
import '../ui/admin/views/shell/admin_shell.dart';
import '../ui/admin/views/profile/admin_profile_screen.dart';
import '../ui/admin/views/user_management/user_management_screen.dart';
import '../ui/admin/views/dashboard/dashboard_screen.dart';

class AdminRoutes {
  static const String login = '/admin/login';
  static const String profile = '/admin/profile';
  static const String dashboard = '/admin/dashboard';
  static const String userManagement = '/admin/user-management';
}

final adminRouterProvider = Provider<GoRouter>((ref) {
  final isSignedIn = ref.watch(adminSessionProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AdminRoutes.login,
    redirect: (context, state) {
      final bool loggedIn = isSignedIn;
      final bool onLogin = state.uri.path == AdminRoutes.login;

      if (!loggedIn && !onLogin) {
        return AdminRoutes.login;
      }
      if (loggedIn && onLogin) {
        return AdminRoutes.profile;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AdminRoutes.profile,
            builder: (context, state) => const AdminProfileScreen(),
          ),
          GoRoute(
            path: AdminRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AdminRoutes.userManagement,
            builder: (context, state) => const UserManagementScreen(),
          ),
        ],
      ),
    ],
  );
});
