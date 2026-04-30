import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/authority_theme.dart';
import '../../view_models/announcements_view_model.dart';

class PublishedAnnouncementDetail extends StatelessWidget {
  const PublishedAnnouncementDetail({
    super.key,
    required this.state,
    required this.onDelete,
    required this.onOpenDocument,
  });

  final AuthorityAnnouncementsState state;
  final Future<void> Function() onDelete;
  final Future<void> Function(String url) onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final announcement = state.selectedAnnouncement;

    if (announcement == null) {
      return _emptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E6F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AuthorityTheme.textDark,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(announcement.createdAt),
            style: const TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 16),
          Text(
            announcement.caption ?? '-',
            style: const TextStyle(
              color: Color(0xFF344054),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (announcement.hasDocument)
            InkWell(
              onTap: () => onOpenDocument(announcement.documentUrl!),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E6F4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        announcement.documentName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new),
                  ],
                ),
              ),
            )
          else
            Text(
              'No document attached.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isDeleting ? null : onDelete,
              icon: state.isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              label: const Text('Delete Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E6F4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 46,
              color: AuthorityTheme.brandBlue.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              'Select an announcement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'The detail panel will show title, caption, and the attached document.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
