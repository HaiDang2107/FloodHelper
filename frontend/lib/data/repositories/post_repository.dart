import '../models/post_model.dart';

/// Abstract repository for post operations
/// Implement this interface for mock or real data source
abstract class PostRepository {
  /// Get all posts (feed)
  Future<List<PostModel>> getPosts({int page = 1, int limit = 20});
  
  /// Get nearby posts on map
  Future<List<PostModel>> getNearbyPosts({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  
  /// Get post by ID
  Future<PostModel?> getPostById(String postId);
  
  /// Create new post
  Future<PostModel?> createPost({
    required String caption,
    String? imageUrl,
    double? latitude,
    double? longitude,
  });
  
  /// Delete post
  Future<bool> deletePost(String postId);
  
  /// Like post
  Future<bool> likePost(String postId);
  
  /// Unlike post
  Future<bool> unlikePost(String postId);
  
  /// Add comment to post
  Future<CommentModel?> addComment({
    required String postId,
    required String content,
  });
  
  /// Delete comment
  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  });
  
  /// Get comments for a post
  Future<List<CommentModel>> getComments(String postId);
}
