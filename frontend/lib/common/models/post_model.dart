import 'package:latlong2/latlong.dart';

class PostComment {
  final String userId;
  final String userName;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
  });
}

class PostModel {
  final String postId;
  final String createdBy;
  final String createdByAvatar;
  final String caption;
  final String imageUrl;
  final double longitude;
  final double latitude;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final int likesCount;
  final List<PostComment> comments;

  PostModel({
    required this.postId,
    required this.createdBy,
    required this.createdByAvatar,
    required this.caption,
    required this.imageUrl,
    required this.longitude,
    required this.latitude,
    required this.createdAt,
    this.deletedAt,
    this.likesCount = 0,
    this.comments = const [],
  });

  LatLng get location => LatLng(latitude, longitude);
}

// Mock posts data
final List<PostModel> mockPosts = [
  PostModel(
    postId: 'post_1',
    createdBy: 'Nguyễn Văn An',
    createdByAvatar: 'https://i.pravatar.cc/150?img=12',
    caption: 'Flood situation on Main Street. Water level is rising rapidly!',
    imageUrl: 'https://picsum.photos/400/300?random=1',
    longitude: 105.8548,
    latitude: 21.0290,
    createdAt: DateTime(2023, 10, 15, 10, 30),
    deletedAt: null,
    likesCount: 24,
    comments: [
      PostComment(
        userId: 'user_1',
        userName: 'Trần Văn B',
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        content: 'Stay safe everyone!',
        createdAt: DateTime(2023, 10, 15, 10, 35),
      ),
      PostComment(
        userId: 'user_2',
        userName: 'Lê Thị C',
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
        content: 'Thanks for the update',
        createdAt: DateTime(2023, 10, 15, 10, 40),
      ),
    ],
  ),
  PostModel(
    postId: 'post_2',
    createdBy: 'Trần Thị Bình',
    createdByAvatar: 'https://i.pravatar.cc/150?img=45',
    caption: 'Road blocked due to flooding. Please find alternative route.',
    imageUrl: 'https://picsum.photos/400/300?random=2',
    longitude: 105.8555,
    latitude: 21.0280,
    createdAt: DateTime(2023, 10, 15, 11, 15),
    deletedAt: null,
    likesCount: 18,
    comments: [
      PostComment(
        userId: 'user_3',
        userName: 'Phạm Văn D',
        avatarUrl: 'https://i.pravatar.cc/150?img=13',
        content: 'Which street exactly?',
        createdAt: DateTime(2023, 10, 15, 11, 20),
      ),
    ],
  ),
  PostModel(
    postId: 'post_3',
    createdBy: 'Lê Văn Cường',
    createdByAvatar: 'https://i.pravatar.cc/150?img=68',
    caption: 'Emergency supplies distribution point here. Food and water available.',
    imageUrl: 'https://picsum.photos/400/300?random=3',
    longitude: 105.8538,
    latitude: 21.0295,
    createdAt: DateTime(2023, 10, 15, 9, 45),
    deletedAt: null,
    likesCount: 56,
    comments: [
      PostComment(
        userId: 'user_4',
        userName: 'Hoàng Thị E',
        avatarUrl: 'https://i.pravatar.cc/150?img=47',
        content: 'Great work! Thank you so much',
        createdAt: DateTime(2023, 10, 15, 9, 50),
      ),
      PostComment(
        userId: 'user_5',
        userName: 'Võ Văn F',
        avatarUrl: 'https://i.pravatar.cc/150?img=51',
        content: 'Is this still available?',
        createdAt: DateTime(2023, 10, 15, 10, 00),
      ),
      PostComment(
        userId: 'user_6',
        userName: 'Đặng Thị G',
        avatarUrl: 'https://i.pravatar.cc/150?img=26',
        content: 'On my way!',
        createdAt: DateTime(2023, 10, 15, 10, 15),
      ),
    ],
  ),
  PostModel(
    postId: 'post_4',
    createdBy: 'Phạm Thị Dung',
    createdByAvatar: 'https://i.pravatar.cc/150?img=20',
    caption: 'Rescue boat available in this area. Contact for help.',
    imageUrl: 'https://picsum.photos/400/300?random=4',
    longitude: 105.8565,
    latitude: 21.0300,
    createdAt: DateTime(2023, 10, 15, 8, 20),
    deletedAt: null,
    likesCount: 42,
    comments: [
      PostComment(
        userId: 'user_7',
        userName: 'Ngô Văn H',
        avatarUrl: 'https://i.pravatar.cc/150?img=60',
        content: 'How can we reach you?',
        createdAt: DateTime(2023, 10, 15, 8, 25),
      ),
    ],
  ),
  PostModel(
    postId: 'post_5',
    createdBy: 'Hoàng Văn Em',
    createdByAvatar: 'https://i.pravatar.cc/150?img=11',
    caption: 'Safe zone established. Evacuees welcome here.',
    imageUrl: 'https://picsum.photos/400/300?random=5',
    longitude: 105.8525,
    latitude: 21.0270,
    createdAt: DateTime(2023, 10, 15, 12, 00),
    deletedAt: null,
    likesCount: 89,
    comments: [
      PostComment(
        userId: 'user_8',
        userName: 'Bùi Thị I',
        avatarUrl: 'https://i.pravatar.cc/150?img=32',
        content: 'Perfect! Heading there now',
        createdAt: DateTime(2023, 10, 15, 12, 05),
      ),
      PostComment(
        userId: 'user_9',
        userName: 'Dương Văn K',
        avatarUrl: 'https://i.pravatar.cc/150?img=56',
        content: 'Is there enough space?',
        createdAt: DateTime(2023, 10, 15, 12, 10),
      ),
    ],
  ),
];
