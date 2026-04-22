import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/authority_theme.dart';
import '../../view_models/authority_session_view_model.dart';
import '../../widgets/authority_sidebar/authority_sidebar.dart';
import '../../../../routing/authority_router.dart';

class AuthorityShell extends ConsumerStatefulWidget {
  const AuthorityShell({super.key, required this.child});

  final Widget child; // Dùng để truyền màn con vào

  @override
  ConsumerState<AuthorityShell> createState() => _AuthorityShellState();
}

class _AuthorityShellState extends ConsumerState<AuthorityShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 1100;
    final sidebarWidth = _isCollapsed || isCompact ? 120.0 : 260.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4F6FB), Color(0xFFE8EEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            left: -120,
            top: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 32, 41, 67).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthorityTheme.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: sidebarWidth,
                curve: Curves.easeOut,
                child: AuthoritySidebar(
                  isCollapsed: _isCollapsed || isCompact,
                  onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
                  currentLocation: GoRouterState.of(context).uri.toString(),
                  onSignOut: () {
                    ref.read(authoritySessionProvider.notifier).signOut();
                    context.go(AuthorityRoutes.login);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.92),
                      child: widget.child, // router inject màn hình vào
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
