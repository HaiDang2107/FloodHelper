import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/admin_theme.dart';
import '../../view_models/admin_session_view_model.dart';
import '../../widgets/admin_sidebar/admin_sidebar.dart';
import '../../../../routing/admin_router.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 1100;
    final sidebarWidth = _isCollapsed || isCompact
        ? 120.0
        : _expandedSidebarWidth(context);

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
                color: AdminTheme.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: sidebarWidth,
                curve: Curves.easeOut,
                child: AdminSidebar(
                  isCollapsed: _isCollapsed || isCompact,
                  onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
                  currentLocation: GoRouterState.of(context).uri.toString(),
                  onSignOut: () {
                    ref.read(adminSessionProvider.notifier).signOut();
                    context.go(AdminRoutes.login);
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
                      child: widget.child,
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

  double _expandedSidebarWidth(BuildContext context) {
    const candidates = <String>[
      'Admin Dashboard',
      'FloodHelper',
      'Profile',
      'Dashboard',
      'User Management',
      'Sign out',
    ];

    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    double widestLabel = 0;
    for (final text in candidates) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (painter.width > widestLabel) {
        widestLabel = painter.width;
      }
    }

    final computedWidth = widestLabel + 128;
    return computedWidth.clamp(240.0, 360.0);
  }
}
