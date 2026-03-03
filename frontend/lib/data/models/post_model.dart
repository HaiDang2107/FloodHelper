import 'package:latlong2/latlong.dart';

/// Comment model for posts
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? json['commentId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Post model for data layer
class PostModel {
  final String id;
  final String createdBy;
  final String createdByUserId;
  final String createdByAvatar;
  final String caption;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final int likesCount;
  final bool isLikedByMe;
  final List<CommentModel> comments;

  const PostModel({
    required this.id,
    required this.createdBy,
    required this.createdByUserId,
    required this.createdByAvatar,
    required this.caption,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.deletedAt,
    this.likesCount = 0,
    this.isLikedByMe = false,
    this.comments = const [],
  });

  LatLng get location => LatLng(latitude, longitude);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? json['postId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdByUserId: json['createdByUserId'] ?? '',
      createdByAvatar: json['createdByAvatar'] ?? '',
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt']) 
          : null,
      likesCount: json['likesCount'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => CommentModel.fromJson(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'createdByUserId': createdByUserId,
      'createdByAvatar': createdByAvatar,
      'caption': caption,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'likesCount': likesCount,
      'isLikedByMe': isLikedByMe,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  PostModel copyWith({
    String? id,
    String? createdBy,
    String? createdByUserId,
    String? createdByAvatar,
    String? caption,
    String? imageUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? deletedAt,
    int? likesCount,
    bool? isLikedByMe,
    List<CommentModel>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByAvatar: createdByAvatar ?? this.createdByAvatar,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      comments: comments ?? this.comments,
    );
  }
}
