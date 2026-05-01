/// Announcement model for data layer
class AnnouncementModel {
  final String id;
  final String title;
  final String hint;
  final String? content;
  final String? documentUrl;
  final String? publishedBy;
  final AnnouncementSource source;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.hint,
    this.content,
    this.documentUrl,
    this.publishedBy,
    required this.source,
    required this.createdAt,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? json['announcementId'] ?? '',
      title: json['title'] ?? '',
      hint: json['hint'] ?? json['caption'] ?? '',
      content: json['content'] ?? json['caption'],
      documentUrl: json['documentUrl']?.toString(),
      publishedBy: json['publishedBy']?.toString(),
      source: AnnouncementSource.fromString(
        json['source'] ?? json['type'] ?? 'app',
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
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
      'documentUrl': documentUrl,
      'publishedBy': publishedBy,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? hint,
    String? content,
    String? documentUrl,
    String? publishedBy,
    AnnouncementSource? source,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hint: hint ?? this.hint,
      content: content ?? this.content,
      documentUrl: documentUrl ?? this.documentUrl,
      publishedBy: publishedBy ?? this.publishedBy,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
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
