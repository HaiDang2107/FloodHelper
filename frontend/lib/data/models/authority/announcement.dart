import '../../../domain/models/announcement.dart';

class AuthorityAnnouncement {
  const AuthorityAnnouncement({
    required this.id,
    required this.title,
    required this.caption,
    required this.documentUrl,
    required this.type,
    required this.createdAt,
    required this.publishedBy,
  });

  final String id;
  final String title;
  final String? caption;
  final String? documentUrl;
  final AnnouncementType type;
  final DateTime createdAt;
  final String publishedBy;

  bool get hasDocument => documentUrl != null && documentUrl!.trim().isNotEmpty;

  String get documentName {
    final url = documentUrl;
    if (url == null || url.trim().isEmpty) {
      return 'Document';
    }

    final uri = Uri.tryParse(url);
    final fileName = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : 'Document';
    return fileName.isEmpty ? 'Document' : fileName;
  }
}

class AuthorityAnnouncementPage {
  const AuthorityAnnouncementPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AuthorityAnnouncement> items;
  final bool hasMore;
  final String? nextCursor;
}