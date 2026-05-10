part of 'admin_sidebar.dart';

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCollapsed)
            Text(
              'Admin Desk',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            )
          else
            const Icon(Icons.admin_panel_settings, color: Colors.white),
          if (!isCollapsed) ...[
            const SizedBox(height: 4),
            Text(
              'FloodHelper',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
