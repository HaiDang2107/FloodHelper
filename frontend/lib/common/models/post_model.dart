import 'package:latlong2/latlong.dart';

class PostModel {
  final String postId;
  final String createdBy;
  final String caption;
  final String imageUrl;
  final double longitude;
  final double latitude;
  final DateTime createdAt;
  final DateTime? deletedAt;

  PostModel({
    required this.postId,
    required this.createdBy,
    required this.caption,
    required this.imageUrl,
    required this.longitude,
    required this.latitude,
    required this.createdAt,
    this.deletedAt,
  });

  LatLng get location => LatLng(latitude, longitude);
}

// Mock posts data
final List<PostModel> mockPosts = [
  PostModel(
    postId: 'post_1',
    createdBy: 'Nguyễn Văn An',
    caption: 'Flood situation on Main Street. Water level is rising rapidly!',
    imageUrl: 'https://picsum.photos/400/300?random=1',
    longitude: 105.8548,
    latitude: 21.0290,
    createdAt: DateTime(2023, 10, 15, 10, 30),
    deletedAt: null,
  ),
  PostModel(
    postId: 'post_2',
    createdBy: 'Trần Thị Bình',
    caption: 'Road blocked due to flooding. Please find alternative route.',
    imageUrl: 'https://picsum.photos/400/300?random=2',
    longitude: 105.8555,
    latitude: 21.0280,
    createdAt: DateTime(2023, 10, 15, 11, 15),
    deletedAt: null,
  ),
  PostModel(
    postId: 'post_3',
    createdBy: 'Lê Văn Cường',
    caption: 'Emergency supplies distribution point here. Food and water available.',
    imageUrl: 'https://picsum.photos/400/300?random=3',
    longitude: 105.8538,
    latitude: 21.0295,
    createdAt: DateTime(2023, 10, 15, 9, 45),
    deletedAt: null,
  ),
  PostModel(
    postId: 'post_4',
    createdBy: 'Phạm Thị Dung',
    caption: 'Rescue boat available in this area. Contact for help.',
    imageUrl: 'https://picsum.photos/400/300?random=4',
    longitude: 105.8565,
    latitude: 21.0300,
    createdAt: DateTime(2023, 10, 15, 8, 20),
    deletedAt: null,
  ),
  PostModel(
    postId: 'post_5',
    createdBy: 'Hoàng Văn Em',
    caption: 'Safe zone established. Evacuees welcome here.',
    imageUrl: 'https://picsum.photos/400/300?random=5',
    longitude: 105.8525,
    latitude: 21.0270,
    createdAt: DateTime(2023, 10, 15, 12, 00),
    deletedAt: null,
  ),
];
