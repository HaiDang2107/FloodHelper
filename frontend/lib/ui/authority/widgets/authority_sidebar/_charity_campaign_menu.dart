part of 'authority_sidebar.dart';

class _CharityCampaignMenu extends StatefulWidget {
  const _CharityCampaignMenu({
    required this.isCollapsed,
    required this.currentLocation,
  });

  final bool isCollapsed;
  final String currentLocation;

  @override
  State<_CharityCampaignMenu> createState() => _CharityCampaignMenuState();
}

class _CharityCampaignMenuState extends State<_CharityCampaignMenu> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _currentUri.path == AuthorityRoutes.charity;
  }

  @override
  void didUpdateWidget(covariant _CharityCampaignMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = Uri.parse(oldWidget.currentLocation).path;
    final newPath = _currentUri.path;
    if (newPath == AuthorityRoutes.charity && oldPath != AuthorityRoutes.charity) {
      _expanded = true;
    }
  }

  Uri get _currentUri => Uri.parse(widget.currentLocation);

  @override
  Widget build(BuildContext context) {
    final currentPath = _currentUri.path;
    final status = _currentUri.queryParameters['status'];
    final parentActive = currentPath == AuthorityRoutes.charity;

    const submenuItems = [
      (status: 'pending', label: 'Pending'),
      (status: 'rejected', label: 'Rejected'),
      (status: 'approved', label: 'Approved'),
      (status: 'donating', label: 'Donating'),
      (status: 'distributing', label: 'Distributing'),
      (status: 'finished', label: 'Finished'),
      (status: 'suspended', label: 'Suspended'),
    ];

    return Column(
      children: [
        _SidebarItem(
          icon: Icons.volunteer_activism_outlined,
          label: 'Charity campaign',
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
          for (final item in submenuItems)
            _SubSidebarItem(
              label: item.label,
              isActive: parentActive && status == item.status,
              onTap: () => context.go('${AuthorityRoutes.charity}?status=${item.status}'),
            ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}