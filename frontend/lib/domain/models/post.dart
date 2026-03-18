// Domain entity for Post
// Represents a flood-related post displayed on the map and feed
// Clean domain model - no JSON serialization logic

import 'user_profile.dart';

class Post {
  final String id;
  final PostAuthor author;
  final String caption;
  final String? imageUrl;
  final Location location;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final int likesCount;
  final bool isLikedByCurrentUser;
  final List<Comment> comments;

  const Post({
    required this.id,
    required this.author,
    required this.caption,
    this.imageUrl,
    required this.location,
    required this.createdAt,
    this.deletedAt,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
    this.comments = const [],
  });

  /// Check if post has been deleted
  bool get isDeleted => deletedAt != null;

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

  /// Get comments count
  int get commentsCount => comments.length;

  Post copyWith({
    String? id,
    PostAuthor? author,
    String? caption,
    String? imageUrl,
    Location? location,
    DateTime? createdAt,
    DateTime? deletedAt,
    int? likesCount,
    bool? isLikedByCurrentUser,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      comments: comments ?? this.comments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Value object for post author information
class PostAuthor {
  final String userId;
  final String name;
  final String? avatarUrl;

  const PostAuthor({
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  /// Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  PostAuthor copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
  }) {
    return PostAuthor(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// Domain entity for Comment
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  /// Get time ago string (for display)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? avatarUrl,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
