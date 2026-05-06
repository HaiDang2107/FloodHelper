part of 'authority_sidebar.dart';

class _ProfileUpdateRequestsMenu extends StatefulWidget {
  const _ProfileUpdateRequestsMenu({
    required this.isCollapsed,
    required this.currentLocation,
  });

  final bool isCollapsed;
  final String currentLocation;

  @override
  State<_ProfileUpdateRequestsMenu> createState() =>
      _ProfileUpdateRequestsMenuState();
}

class _ProfileUpdateRequestsMenuState
    extends State<_ProfileUpdateRequestsMenu> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _currentUri.path == AuthorityRoutes.profileUpdates;
  }

  @override
  void didUpdateWidget(covariant _ProfileUpdateRequestsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = Uri.parse(oldWidget.currentLocation).path;
    final newPath = _currentUri.path;
    if (newPath == AuthorityRoutes.profileUpdates &&
        oldPath != AuthorityRoutes.profileUpdates) {
      _expanded = true;
    }
  }

  Uri get _currentUri => Uri.parse(widget.currentLocation);

  @override
  Widget build(BuildContext context) {
    final currentPath = _currentUri.path;
    final status = _currentUri.queryParameters['status'];
    final parentActive = currentPath == AuthorityRoutes.profileUpdates;

    return Column(
      children: [
        _SidebarItem(
          icon: Icons.manage_accounts_outlined,
          label: 'Profile updates',
          isCollapsed: widget.isCollapsed,
          isActive: parentActive,
          trailing:
              widget.isCollapsed
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
            onTap:
                () => context.go(
                  '${AuthorityRoutes.profileUpdates}?status=pending',
                ),
          ),
          _SubSidebarItem(
            label: 'Rejected',
            isActive: parentActive && status == 'rejected',
            onTap:
                () => context.go(
                  '${AuthorityRoutes.profileUpdates}?status=rejected',
                ),
          ),
          _SubSidebarItem(
            label: 'Approved',
            isActive: parentActive && status == 'approved',
            onTap:
                () => context.go(
                  '${AuthorityRoutes.profileUpdates}?status=approved',
                ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}
