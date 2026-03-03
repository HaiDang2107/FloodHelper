/// Announcement model for data layer
class AnnouncementModel {
  final String id;
  final String title;
  final String hint;
  final String? content;
  final AnnouncementSource source;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.hint,
    this.content,
    required this.source,
    required this.createdAt,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      hint: json['hint'] ?? '',
      content: json['content'],
      source: AnnouncementSource.fromString(json['source'] ?? 'app'),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hint': hint,
      'content': content,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}

enum AnnouncementSource {
  daily,
  authority,
  app;

  static AnnouncementSource fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return AnnouncementSource.daily;
      case 'authority':
        return AnnouncementSource.authority;
      case 'app':
      default:
        return AnnouncementSource.app;
    }
  }
}
