part of 'authority_sidebar.dart';

class _AnnouncementsMenu extends StatefulWidget {
  const _AnnouncementsMenu({
    required this.isCollapsed,
    required this.currentLocation,
  });

  final bool isCollapsed;
  final String currentLocation;

  @override
  State<_AnnouncementsMenu> createState() => _AnnouncementsMenuState();
}

class _AnnouncementsMenuState extends State<_AnnouncementsMenu> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _currentUri.path == AuthorityRoutes.announcements;
  }

  @override
  void didUpdateWidget(covariant _AnnouncementsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = Uri.parse(oldWidget.currentLocation).path;
    final newPath = _currentUri.path;
    if (newPath == AuthorityRoutes.announcements &&
        oldPath != AuthorityRoutes.announcements) {
      _expanded = true;
    }
  }

  Uri get _currentUri => Uri.parse(widget.currentLocation);

  @override
  Widget build(BuildContext context) {
    final currentPath = _currentUri.path;
    final section = _currentUri.queryParameters['section'];
    final parentActive = currentPath == AuthorityRoutes.announcements;

    return Column(
      children: [
        _SidebarItem(
          icon: Icons.announcement_outlined,
          label: 'Announcements',
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
            label: 'New Announcement',
            isActive: parentActive && section == 'new',
            onTap: () => context.go('${AuthorityRoutes.announcements}?section=new'),
          ),
          _SubSidebarItem(
            label: 'Published Announcements',
            isActive: parentActive && section == 'published',
            onTap: () {
              final reload = DateTime.now().millisecondsSinceEpoch;
              context.go(
                '${AuthorityRoutes.announcements}?section=published&reload=$reload',
              );
            },
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}