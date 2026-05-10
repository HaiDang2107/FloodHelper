import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/admin_router.dart';

part '_sidebar_header.dart';
part '_sidebar_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.currentLocation,
    required this.onSignOut,
  });

  final bool isCollapsed;
  final VoidCallback onToggle;
  final String currentLocation;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final currentPath = Uri.parse(currentLocation).path;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1F45), Color(0xFF1B4EE4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SidebarHeader(isCollapsed: isCollapsed),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(
                  icon: Icons.person_pin_circle_outlined,
                  label: 'Profile',
                  isCollapsed: isCollapsed,
                  isActive: currentPath == AdminRoutes.profile,
                  onTap: () => _navigate(context, AdminRoutes.profile),
                ),
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isCollapsed: isCollapsed,
                  isActive: currentPath == AdminRoutes.dashboard,
                  onTap: () => _navigate(context, AdminRoutes.dashboard),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  label: 'User Management',
                  isCollapsed: isCollapsed,
                  isActive: currentPath == AdminRoutes.userManagement,
                  onTap: () => _navigate(context, AdminRoutes.userManagement),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Divider(color: Colors.white.withValues(alpha: 0.2)),
                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Sign out',
                  isCollapsed: isCollapsed,
                  isActive: false,
                  onTap: onSignOut,
                ),
                const SizedBox(height: 8),
                IconButton(
                  tooltip: 'Collapse sidebar',
                  onPressed: onToggle,
                  icon: Icon(
                    isCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (currentLocation != route) {
      context.go(route);
    }
  }
}
