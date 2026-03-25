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
      final bool onLogin = state.uri.path == AuthorityRoutes.login; // Kiểm tra URL trên thanh địa chỉ có phải /authority/login không

      if (!loggedIn && !onLogin) {
        // Chưa đăng nhập (!loggedIn) VÀ Đang cố vào một trang không phải Login (!onLogin)
        // ==> ép quay lại trang login
        return AuthorityRoutes.login;
      }
      if (loggedIn && onLogin) {
        // Đã đăng nhập thành công (loggedIn) VÀ Vẫn đang ở trang Login (onLogin).
        // ==> Tự động đẩy vào trang 
        return AuthorityRoutes.profile;
      }
      return null;
    },
    routes: [
      GoRoute( // map một path với 1 màn hình đơn lẻ
        path: AuthorityRoutes.login,
        builder: (context, state) => const AuthorityLoginScreen(),
      ),
      ShellRoute( // lớp bọc cho các route con
        // Khi user đến một path nào đó trong danh sách routes này ==> render AuthorityShell
        builder: (context, state, child) {
          return AuthorityShell( // Một khung giao diện chung (shell), bên trong là các màn con
            child: child,
            // GoRouter tự động map path với màn hình, rồi tự truyền màn hình con vào biến child
          );
        },
        routes: [ // route cho ClipRRect
          GoRoute(
            path: AuthorityRoutes.requests,
            builder: (context, state) => RoleRequestsScreen(
              statusQuery: state.uri.queryParameters['status'],
            ),
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
