import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../../data/repositories/repositories.dart';

part 'home_view_model.g.dart';

enum MapType { transport, weather }

class HomeState {
  final LatLng? currentPosition;
  final bool isLoading;
  final MapType selectedMapType;
  final bool isSosBroadcasting;
  final Map<String, dynamic>? sosData;
  final bool showStrangerLocation;
  final bool showPostLocation;
  final String? errorMessage;

  // Data from repositories
  final List<UserModel> friends;
  final List<UserModel> nearbyUsers;
  final List<PostModel> posts;
  final List<AnnouncementModel> announcements;
  final int unreadAnnouncementsCount;

  const HomeState({
    this.currentPosition,
    this.isLoading = true,
    this.selectedMapType = MapType.transport,
    this.isSosBroadcasting = false,
    this.sosData,
    this.showStrangerLocation = true,
    this.showPostLocation = true,
    this.errorMessage,
    this.friends = const [],
    this.nearbyUsers = const [],
    this.posts = const [],
    this.announcements = const [],
    this.unreadAnnouncementsCount = 0,
  });

  HomeState copyWith({
    LatLng? currentPosition,
    bool? isLoading,
    MapType? selectedMapType,
    bool? isSosBroadcasting,
    Map<String, dynamic>? sosData,
    bool? showStrangerLocation,
    bool? showPostLocation,
    String? errorMessage,
    bool clearSosData = false,
    List<UserModel>? friends,
    List<UserModel>? nearbyUsers,
    List<PostModel>? posts,
    List<AnnouncementModel>? announcements,
    int? unreadAnnouncementsCount,
  }) {
    return HomeState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      selectedMapType: selectedMapType ?? this.selectedMapType,
      isSosBroadcasting: isSosBroadcasting ?? this.isSosBroadcasting,
      sosData: clearSosData ? null : (sosData ?? this.sosData),
      showStrangerLocation: showStrangerLocation ?? this.showStrangerLocation,
      showPostLocation: showPostLocation ?? this.showPostLocation,
      errorMessage: errorMessage,
      friends: friends ?? this.friends,
      nearbyUsers: nearbyUsers ?? this.nearbyUsers,
      posts: posts ?? this.posts,
      announcements: announcements ?? this.announcements,
      unreadAnnouncementsCount: unreadAnnouncementsCount ?? this.unreadAnnouncementsCount,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final MapController mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();

  // Repositories
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  late final AnnouncementRepository _announcementRepository;

  @override
  HomeState build() {
    // Initialize repositories
    _userRepository = ref.read(userRepositoryProvider);
    _postRepository = ref.read(postRepositoryProvider);
    _announcementRepository = ref.read(announcementRepositoryProvider);

    ref.onDispose(() {
      // MapController doesn't need dispose
    });
    
    // Auto-fetch location and data on build
    Future.microtask(() {
      getCurrentLocation();
      loadInitialData();
    });
    
    return const HomeState();
  }

  // ==================== Data Loading ====================

  Future<void> loadInitialData() async {
    await Future.wait([
      loadFriends(),
      loadPosts(),
      loadAnnouncements(),
    ]);
  }

  Future<void> loadFriends() async {
    try {
      final friends = await _userRepository.getFriends();
      state = state.copyWith(friends: friends);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load friends: $e');
    }
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

  // ==================== Location ====================

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      // if (permission == LocationPermission.deniedForever) {
      //   throw Exception(
      //       'Location permissions are permanently denied, we cannot request permissions.');
      // }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      
      state = state.copyWith(
        currentPosition: latLng,
        isLoading: false,
      );
      
      mapController.move(latLng, 15.0);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void moveCameraToLocation(LatLng location) {
    mapController.move(location, 17.0);
  }

  // ==================== Map Type ====================

  void setMapType(MapType mapType) {
    state = state.copyWith(selectedMapType: mapType);
  }

  // ==================== Display Settings ====================

  void setShowStrangerLocation(bool value) {
    state = state.copyWith(showStrangerLocation: value);
  }

  void setShowPostLocation(bool value) {
    state = state.copyWith(showPostLocation: value);
  }

  // ==================== SOS / Distress Signal ====================

  Future<void> broadcastSos(Map<String, dynamic> data) async {
    try {
      final success = await _userRepository.broadcastSos(
        trappedCounts: data['trappedCounts'] ?? 1,
        childrenNumbers: data['childrenNumbers'] ?? 0,
        elderlyNumbers: data['elderlyNumbers'] ?? 0,
        hasFood: data['hasFood'] ?? false,
        hasWater: data['hasWater'] ?? false,
        other: data['other'],
      );
      
      if (success) {
        state = state.copyWith(
          isSosBroadcasting: true,
          sosData: data,
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to broadcast SOS');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to broadcast SOS: $e');
    }
  }

  Future<void> revokeSos() async {
    try {
      final success = await _userRepository.revokeSos();
      
      if (success) {
        state = state.copyWith(
          isSosBroadcasting: false,
          clearSosData: true,
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to revoke SOS');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to revoke SOS: $e');
    }
  }

  // ==================== Friend Requests ====================

  Future<void> sendFriendRequest(String userId) async {
    try {
      final success = await _userRepository.sendFriendRequest(userId);
      if (success) {
        await loadNearbyUsers(); // Refresh nearby users
      } else {
        state = state.copyWith(errorMessage: 'Failed to send friend request');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String userId) async {
    try {
      final success = await _userRepository.acceptFriendRequest(userId);
      if (success) {
        await loadFriends(); // Refresh friends list
      } else {
        state = state.copyWith(errorMessage: 'Failed to accept friend request');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to accept friend request: $e');
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      final success = await _userRepository.removeFriend(userId);
      if (success) {
        await loadFriends(); // Refresh friends list
      } else {
        state = state.copyWith(errorMessage: 'Failed to remove friend');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove friend: $e');
    }
  }

  // ==================== Posts ====================

  Future<void> createPost({
    required String caption,
    String? imageUrl,
  }) async {
    try {
      final post = await _postRepository.createPost(
        caption: caption,
        imageUrl: imageUrl,
        latitude: state.currentPosition?.latitude,
        longitude: state.currentPosition?.longitude,
      );
      if (post != null) {
        await loadPosts(); // Refresh posts
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _postRepository.likePost(postId);
      await loadPosts(); // Refresh posts
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to like post: $e');
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await _postRepository.addComment(postId: postId, content: content);
      await loadPosts(); // Refresh posts
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add comment: $e');
    }
  }

  // ==================== Announcements ====================

  Future<void> markAnnouncementAsRead(String id) async {
    try {
      await _announcementRepository.markAsRead(id);
      final unreadCount = await _announcementRepository.getUnreadCount();
      state = state.copyWith(unreadAnnouncementsCount: unreadCount);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to mark as read: $e');
    }
  }

  // ==================== Camera ====================

  Future<XFile?> takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      return photo;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error taking picture: $e',
      );
      return null;
    }
  }

  // ==================== Error Handling ====================

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
