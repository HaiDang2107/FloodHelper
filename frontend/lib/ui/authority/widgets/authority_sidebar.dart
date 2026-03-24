import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/authority_router.dart';

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
                _SidebarItem(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Charity campaign',
                  isCollapsed: isCollapsed,
                  isActive: currentPath == AuthorityRoutes.charity,
                  onTap: () => _navigate(context, AuthorityRoutes.charity),
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

class _RoleRequestsMenu extends StatefulWidget {
  const _RoleRequestsMenu({
    required this.isCollapsed,
    required this.currentLocation,
  });

  final bool isCollapsed;
  final String currentLocation;

  @override
  State<_RoleRequestsMenu> createState() => _RoleRequestsMenuState();
}

class _RoleRequestsMenuState extends State<_RoleRequestsMenu> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _currentUri.path == AuthorityRoutes.requests;
  }

  @override
  void didUpdateWidget(covariant _RoleRequestsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = Uri.parse(oldWidget.currentLocation).path;
    final newPath = _currentUri.path;
    if (newPath == AuthorityRoutes.requests && oldPath != AuthorityRoutes.requests) {
      _expanded = true;
    }
  }

  Uri get _currentUri => Uri.parse(widget.currentLocation);

  @override
  Widget build(BuildContext context) {
    final currentPath = _currentUri.path;
    final status = _currentUri.queryParameters['status'];
    final parentActive = currentPath == AuthorityRoutes.requests;

    return Column(
      children: [
        _SidebarItem(
          icon: Icons.verified_user_outlined,
          label: 'Role requests',
          isCollapsed: widget.isCollapsed,
          isActive: parentActive,
          trailing: widget.isCollapsed
              ? null
              : Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                  size: 18,
                ),
          onTap: () {
            setState(() => _expanded = !_expanded);
            if (currentPath != AuthorityRoutes.requests) {
              context.go(AuthorityRoutes.requests);
            }
          },
        ),
        if (_expanded && !widget.isCollapsed) ...[
          _SubSidebarItem(
            label: 'Pending',
            isActive: parentActive && status == 'pending',
            onTap: () => context.go('${AuthorityRoutes.requests}?status=pending'),
          ),
          _SubSidebarItem(
            label: 'Rejected',
            isActive: parentActive && status == 'rejected',
            onTap: () => context.go('${AuthorityRoutes.requests}?status=rejected'),
          ),
          _SubSidebarItem(
            label: 'Approved',
            isActive: parentActive && status == 'approved',
            onTap: () => context.go('${AuthorityRoutes.requests}?status=approved'),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_moon_outlined, color: Colors.white),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Authority Desk',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'FloodHelper',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.isActive,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.white;
    final inactiveColor = Colors.white70;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isActive
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: isActive ? activeColor : inactiveColor),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: isActive ? activeColor : inactiveColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SubSidebarItem extends StatelessWidget {
  const _SubSidebarItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.white : Colors.white60,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
