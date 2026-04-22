import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../routing/authority_router.dart';

part '_role_requests_menu.dart';
part '_charity_campaign_menu.dart';
part '_sidebar_header.dart';
part '_sidebar_item.dart';
part '_subsidebar_item.dart';

class AuthoritySidebar extends StatelessWidget {
  const AuthoritySidebar({
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
                  isActive: currentPath == AuthorityRoutes.profile,
                  onTap: () => _navigate(context, AuthorityRoutes.profile),
                ),
                _RoleRequestsMenu(
                  isCollapsed: isCollapsed,
                  currentLocation: currentLocation,
                ),
                _CharityCampaignMenu(
                  isCollapsed: isCollapsed,
                  currentLocation: currentLocation,
                ),
                _SidebarItem(
                  icon: Icons.announcement_outlined,
                  label: 'Announcements',
                  isCollapsed: isCollapsed,
                  isActive: currentPath == AuthorityRoutes.announcements,
                  onTap: () => _navigate(context, AuthorityRoutes.announcements),
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
