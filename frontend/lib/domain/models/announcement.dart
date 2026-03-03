/// Domain entity for Announcement
/// Represents system/authority announcements displayed to users
/// Clean domain model - no JSON serialization logic

class Announcement {
  final String id;
  final String title;
  final String summary;
  final String? content;
  final AnnouncementType type;
  final DateTime createdAt;
  final bool isRead;

  const Announcement({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  /// Check if announcement has full content
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Get time ago string (for display)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Mark as read
  Announcement markAsRead() {
    return copyWith(isRead: true);
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    AnnouncementType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of announcements
enum AnnouncementType {
  /// Daily weather/flood updates
  daily,
  
  /// Authority/Government announcements
  authority,
  
  /// App system notifications
  system;

  String get displayName {
    switch (this) {
      case AnnouncementType.daily:
        return 'Cập nhật hàng ngày';
      case AnnouncementType.authority:
        return 'Thông báo chính quyền';
      case AnnouncementType.system:
        return 'Hệ thống';
    }
  }

  static AnnouncementType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return AnnouncementType.daily;
      case 'authority':
        return AnnouncementType.authority;
      case 'app':
      case 'system':
      default:
        return AnnouncementType.system;
    }
  }
}
