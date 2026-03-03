import '../../models/post_model.dart';
import '../post_repository.dart';

/// Mock implementation of PostRepository for development/testing
class MockPostRepository implements PostRepository {
  final List<PostModel> _mockPosts = [
    PostModel(
      id: '1',
      createdBy: 'Nguyễn Văn An',
      createdByUserId: '1',
      createdByAvatar: 'https://i.pravatar.cc/150?img=1',
      caption:
          'Tình hình mưa lũ ở khu vực Quận Hoàn Kiếm đang được kiểm soát. Mọi người yên tâm!',
      imageUrl: 'https://picsum.photos/seed/flood1/400/300',
      latitude: 21.0285,
      longitude: 105.8542,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 24,
      comments: [
        CommentModel(
          id: 'c1',
          userId: '2',
          userName: 'Trần Thị Bình',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
          content: 'Cảm ơn thông tin!',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    PostModel(
      id: '2',
      createdBy: 'Phạm Thị Dung',
      createdByUserId: '4',
      createdByAvatar: 'https://i.pravatar.cc/150?img=4',
      caption:
          'Nhóm thiện nguyện đang phát nước sạch và thực phẩm tại phường Cầu Giấy. Ai cần hỗ trợ liên hệ nhé!',
      imageUrl: 'https://picsum.photos/seed/volunteer1/400/300',
      latitude: 21.0305,
      longitude: 105.8562,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likesCount: 56,
      comments: [
        CommentModel(
          id: 'c2',
          userId: '3',
          userName: 'Lê Văn Cường',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          content: 'Tuyệt vời quá! Địa chỉ cụ thể là ở đâu vậy ạ?',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        CommentModel(
          id: 'c3',
          userId: '4',
          userName: 'Phạm Thị Dung',
          avatarUrl: 'https://i.pravatar.cc/150?img=4',
          content: 'Tại UBND phường Cầu Giấy ạ, từ 8h-17h hàng ngày',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    PostModel(
      id: '3',
      createdBy: 'Võ Thị Phương',
      createdByUserId: '6',
      createdByAvatar: 'https://i.pravatar.cc/150?img=6',
      caption:
          'Cảnh báo: Mực nước sông Hồng đang dâng cao. Bà con ở khu vực ven sông cần di dời đến nơi an toàn.',
      imageUrl: 'https://picsum.photos/seed/warning1/400/300',
      latitude: 21.0310,
      longitude: 105.8545,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likesCount: 102,
      comments: [],
    ),
    PostModel(
      id: '4',
      createdBy: 'Hoàng Văn Em',
      createdByUserId: '5',
      createdByAvatar: 'https://i.pravatar.cc/150?img=5',
      caption:
          'Đội cứu hộ địa phương đã giải cứu thành công 15 người dân bị mắc kẹt tại khu vực ngập nước.',
      imageUrl: '',
      latitude: 21.0265,
      longitude: 105.8522,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 89,
      comments: [
        CommentModel(
          id: 'c4',
          userId: '1',
          userName: 'Nguyễn Văn An',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          content: 'Cảm ơn đội cứu hộ!',
          createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        ),
      ],
    ),
  ];

  @override
  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    await _simulateDelay();
    final start = (page - 1) * limit;
    final end = start + limit;
    if (start >= _mockPosts.length) return [];
    return _mockPosts.sublist(
      start,
      end > _mockPosts.length ? _mockPosts.length : end,
    );
  }

  @override
  Future<List<PostModel>> getNearbyPosts({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int page = 1,
    int limit = 10,
  }) async {
    await _simulateDelay();
    // In real implementation, filter by distance
    return getPosts(page: page, limit: limit);
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    await _simulateDelay();
    try {
      return _mockPosts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PostModel?> createPost({
    required String caption,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    await _simulateDelay();
    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdBy: 'Current User',
      createdByUserId: 'current_user',
      createdByAvatar: 'https://i.pravatar.cc/300',
      caption: caption,
      imageUrl: imageUrl ?? '',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      createdAt: DateTime.now(),
      likesCount: 0,
      comments: [],
    );
    _mockPosts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<bool> deletePost(String postId) async {
    await _simulateDelay();
    _mockPosts.removeWhere((p) => p.id == postId);
    return true;
  }

  @override
  Future<bool> likePost(String postId) async {
    await _simulateDelay();
    final index = _mockPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      _mockPosts[index] = post.copyWith(likesCount: post.likesCount + 1);
      return true;
    }
    return false;
  }

  @override
  Future<bool> unlikePost(String postId) async {
    await _simulateDelay();
    final index = _mockPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      _mockPosts[index] = post.copyWith(
        likesCount: post.likesCount > 0 ? post.likesCount - 1 : 0,
      );
      return true;
    }
    return false;
  }

  @override
  Future<CommentModel?> addComment({
    required String postId,
    required String content,
  }) async {
    await _simulateDelay();
    final index = _mockPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        userName: 'Current User',
        avatarUrl: 'https://i.pravatar.cc/300',
        content: content,
        createdAt: DateTime.now(),
      );
      final post = _mockPosts[index];
      _mockPosts[index] = post.copyWith(
        comments: [...post.comments, comment],
      );
      return comment;
    }
    return null;
  }

  @override
  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _simulateDelay();
    final postIndex = _mockPosts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _mockPosts[postIndex];
      _mockPosts[postIndex] = post.copyWith(
        comments: post.comments.where((c) => c.id != commentId).toList(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<List<CommentModel>> getComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateDelay();
    final post = await getPostById(postId);
    return post?.comments ?? [];
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
