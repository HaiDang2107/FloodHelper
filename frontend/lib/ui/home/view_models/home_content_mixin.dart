part of 'home_view_model.dart';

mixin HomeContentMixin on _HomeViewModelBase {
  Future<void> loadInitialData() async {
    await Future.wait([
      _loadFriendsWithMapMode(),
      loadPosts(),
      loadAnnouncements(),
    ]);
  }

  Future<void> loadNearbyUsers() async {
    if (state.currentPosition == null) return;

    try {
      final users = await _userRepository.getNearbyUsers(
        latitude: state.currentPosition!.latitude,
        longitude: state.currentPosition!.longitude,
      );
      state = state.copyWith(nearbyUsers: users);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load nearby users: $e');
    }
  }

  Future<void> loadPosts() async {
    try {
      final posts = await _postRepository.getPosts();
      state = state.copyWith(posts: posts);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load posts: $e');
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      final announcements = await _announcementRepository.getAnnouncements();
      final unreadCount = await _announcementRepository.getUnreadCount();
      state = state.copyWith(
        announcements: announcements,
        unreadAnnouncementsCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load announcements: $e');
    }
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    await loadInitialData();
    state = state.copyWith(isLoading: false);
  }

  Future<void> createPost({required String caption, String? imageUrl}) async {
    try {
      final post = await _postRepository.createPost(
        caption: caption,
        imageUrl: imageUrl,
        latitude: state.currentPosition?.latitude,
        longitude: state.currentPosition?.longitude,
      );
      if (post != null) {
        await loadPosts();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _postRepository.likePost(postId);
      await loadPosts();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to like post: $e');
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await _postRepository.addComment(postId: postId, content: content);
      await loadPosts();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add comment: $e');
    }
  }

  Future<void> markAnnouncementAsRead(String id) async {
    try {
      await _announcementRepository.markAsRead(id);
      final unreadCount = await _announcementRepository.getUnreadCount();
      state = state.copyWith(unreadAnnouncementsCount: unreadCount);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to mark as read: $e');
    }
  }

  Future<void> takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (photo != null) {
        _emitUiEvent('Picture taken: ${photo.path}', HomeUiEventType.success);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error taking picture: $e');
    }
  }
}
