part of 'authority_sidebar.dart';

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