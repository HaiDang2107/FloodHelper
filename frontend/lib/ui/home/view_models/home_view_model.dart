import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/services/firebase_messaging_service.dart';
import '../../../data/services/location_tracking_service.dart';
import '../../../data/services/mqtt_service.dart';
import 'friend_view_model.dart';

part 'home_view_model.g.dart';

enum MapType { transport, weather }

enum HomeUiEventType { info, success, error }

class HomeUiEvent {
  final HomeUiEventType type;
  final String message;

  const HomeUiEvent({
    required this.type,
    required this.message,
  });
}

class HomeState {
  final LatLng? currentPosition;
  final bool isLoading;
  final MapType selectedMapType;
  final bool isSosBroadcasting;
  final Map<String, dynamic>? sosData;
  final bool showStrangerLocation;
  final bool showPostLocation;
  final String? errorMessage;
  final HomeUiEvent? uiEvent;

  // Data from repositories
  final List<UserModel> nearbyUsers;
  final List<PostModel> posts;
  final List<AnnouncementModel> announcements;
  final int unreadAnnouncementsCount;

  // Friend locations received via MQTT
  final Map<String, LatLng> friendLocations;

  // Friends with map mode data (from backend)
  final List<FriendModel> friendsWithMapMode;

  // Current location visibility setting
  final String locationVisibility; // 'PUBLIC', 'JUST_FRIEND', 'NO_ONE'

  const HomeState({
    this.currentPosition,
    this.isLoading = true,
    this.selectedMapType = MapType.transport,
    this.isSosBroadcasting = false,
    this.sosData,
    this.showStrangerLocation = true,
    this.showPostLocation = true,
    this.errorMessage,
    this.uiEvent,
    this.nearbyUsers = const [],
    this.posts = const [],
    this.announcements = const [],
    this.unreadAnnouncementsCount = 0,
    this.friendLocations = const {},
    this.friendsWithMapMode = const [],
    this.locationVisibility = 'JUST_FRIEND',
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
    HomeUiEvent? uiEvent,
    bool clearSosData = false,
    bool clearUiEvent = false,
    List<UserModel>? nearbyUsers,
    List<PostModel>? posts,
    List<AnnouncementModel>? announcements,
    int? unreadAnnouncementsCount,
    Map<String, LatLng>? friendLocations, // Danh sách bạn bè cùng vị trí, phục vụ duy trì trạng thái UI.
    List<FriendModel>? friendsWithMapMode, // Lưu danh sách bạn bè cũng map mode, chịu trách nhiệm duy trì danh sách bạn bè
    String? locationVisibility,
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
      uiEvent: clearUiEvent ? null : (uiEvent ?? this.uiEvent),
      nearbyUsers: nearbyUsers ?? this.nearbyUsers,
      posts: posts ?? this.posts,
      announcements: announcements ?? this.announcements,
      unreadAnnouncementsCount: unreadAnnouncementsCount ?? this.unreadAnnouncementsCount,
      friendLocations: friendLocations ?? this.friendLocations,
      friendsWithMapMode: friendsWithMapMode ?? this.friendsWithMapMode,
      locationVisibility: locationVisibility ?? this.locationVisibility,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final MapController mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();
  late final LocationTrackingService _locationTrackingService = ref.read(locationTrackingServiceProvider);

  // MQTT service (UI isolate — for subscribing to friend locations)
  late final MqttService _mqttService = ref.read(mqttServiceProvider);

  // Repositories
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  late final AnnouncementRepository _announcementRepository;
  late final FriendRepository _friendRepository;

  // Location stream subscription
  StreamSubscription<LocationUpdate>? _locationSubscription;

  // Friend location stream subscription
  StreamSubscription<FriendLocationUpdate>? _friendLocationSubscription;
  bool _isMessagingSetup = false;

  @override
  HomeState build() {
    // Initialize repositories
    _userRepository = ref.read(userRepositoryProvider);
    _postRepository = ref.read(postRepositoryProvider);
    _announcementRepository = ref.read(announcementRepositoryProvider);
    _friendRepository = ref.read(friendRepositoryProvider);

    ref.onDispose(() {
      _locationSubscription?.cancel();
      _friendLocationSubscription?.cancel();
      _mqttService.stopListeningFriendLocations();

    });

    ref.listen(friendViewModelProvider, (previous, next) {
      final acceptedFriendId = next.acceptedFriendUserId;
      if (acceptedFriendId == null ||
          acceptedFriendId == previous?.acceptedFriendUserId) {
        return;
      }

      unawaited(syncAfterAcceptFriendRequest(acceptedFriendId));
      ref
          .read(friendViewModelProvider.notifier)
          .clearAcceptedFriendSyncEvent();
    });

    // Auto-start location tracking
    Future.microtask(() => _startTracking());

    return const HomeState();
  }

  void setupFirebaseMessaging(FirebaseMessagingService messagingService) {
    if (_isMessagingSetup) {
      return;
    }

    _isMessagingSetup = true;
    messagingService.onForegroundMessage(_handleForegroundMessage);
    messagingService.onMessageOpenedApp(_handleMessageOpenedApp);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    switch (data['type']) {
      case 'FRIEND_REQUEST':
        unawaited(ref.read(friendViewModelProvider.notifier).loadRequests());
        final senderName = (data['senderName'] ?? 'Someone').toString();
        _emitUiEvent(
          '$senderName sent you a friend request',
          HomeUiEventType.info,
        );
        break;
      case 'FRIEND_REQUEST_ACCEPTED':
        unawaited(refreshFriends());
        unawaited(ref.read(friendViewModelProvider.notifier).loadRequests());
        _emitUiEvent(
          'Your friend request was accepted',
          HomeUiEventType.success,
        );
        break;
      default:
        break;
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {}

  /// Start location tracking via the background service
  Future<void> _startTracking() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Load friends with map mode from backend
      await _loadFriendsWithMapMode();

      // 1b. Load current visibility from backend
      await _loadVisibility();

      // 2. Compute allowed friends based on visibilityMode + friendMapMode
      final allowedFriendIds = _computeAllowedFriends();

      // 3. Start background service (GPS + MQTT publish) with allowed friends
      final initialUpdate = await _locationTrackingService.start(
        currentUser!.id,
        allowedFriendIds: allowedFriendIds,
      );

      // 4. Update UI with initial position
      final initialLatLng = LatLng(
        initialUpdate.latitude,
        initialUpdate.longitude,
      );
      state = state.copyWith(
        currentPosition: initialLatLng,
        isLoading: false,
      );
      mapController.move(initialLatLng, 15.0);

      // 5. Listen to subsequent location updates from the service
      _locationSubscription = _locationTrackingService.locationStream.listen(
        (update) {
          state = state.copyWith(
            currentPosition: LatLng(update.latitude, update.longitude),
          );
        },
        onError: (error) {
          if (kDebugMode) {
            print('📍 Location stream error: $error');
          }
          state = state.copyWith(
            errorMessage: 'Location tracking error: $error',
          );
        },
      );

      // 6. Setup MQTT subscriptions for friend locations (UI isolate)
      await _setupFriendSubscriptions(currentUser.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Load friends list with map mode from backend
  Future<void> _loadFriendsWithMapMode() async {
    try {
      final friends = await _friendRepository.getFriends();
      state = state.copyWith(friendsWithMapMode: friends);
    } catch (e) {
      if (kDebugMode) {
        print('📍 Failed to load friends with map mode: $e');
      }
    }
  }

  /// Connect MQTT (UI isolate), subscribe to allowed friends' last-location topics,
  /// and listen for incoming friend location updates.
  Future<void> _setupFriendSubscriptions(String myUserId) async {
    // Connect MQTT on UI isolate (separate connection from background isolate)
    final connected = await _mqttService.connect('${myUserId}_ui'); // mỗi thiết bị kết nối đến Broker phải có một cái tên (ID) duy nhất
    if (!connected) {
      if (kDebugMode) {
        print('📡 [UI] MQTT connect failed for friend subscriptions');
      }
      return;
    }

    // Subscribe to each friend based on visibilityMode + friendMapMode
    final allowedFriends = _computeAllowedFriendModels();

    for (final friend in allowedFriends) {
      _mqttService.subscribeFriendLocation(friend.userId, myUserId);
    }

    // Start listening and parsing incoming messages
    _mqttService.startListeningFriendLocations(myUserId);

    // Update state when friend location arrives
    _friendLocationSubscription = _mqttService.friendLocationStream.listen(
      (update) {
        if (kDebugMode) {
          print('✅ [UI] NHẬN ĐƯỢC VỊ TRÍ BẠN BÈ: ${update.friendId} -> ${update.latitude}, ${update.longitude}');
        }
        final updatedLocations = Map<String, LatLng>.from(state.friendLocations);
        updatedLocations[update.friendId] = LatLng(update.latitude, update.longitude);
        state = state.copyWith(friendLocations: updatedLocations);
      },
    );

    if (kDebugMode) {
      print('📡 [UI] Subscribed to ${allowedFriends.length} friend location topics');
    }
  }

  // ==================== Data Loading ====================

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

  Future<void> refreshFriends() async {
    await _loadFriendsWithMapMode();
    _syncAllowedFriends(); // Update allowed friends to background service
    
    // Re-setup MQTT subscriptions
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      await _setupFriendSubscriptions(currentUser.id);
    }
  }


  // ==================== Location ====================

  /// Re-center map to current position (called from UI button)
  void recenterMap() {
    if (state.currentPosition != null) {
      mapController.move(state.currentPosition!, 15.0);
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

  // ==================== Location Visibility ====================

  /// Update location visibility setting and sync to backend.
  Future<void> updateLocationVisibility(String visibility) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateVisibility(visibility);

      state = state.copyWith(locationVisibility: visibility);

      // Recompute allowed friends based on new visibility
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // Unsubscribe all first
        for (final friend in state.friendsWithMapMode) {
          _mqttService.unsubscribeFriendLocation(friend.userId, currentUser.id);
        }

        if (visibility == 'NO_ONE') {
          // NO_ONE: clear all
          _locationTrackingService.updateAllowedFriends([]);
          state = state.copyWith(friendLocations: {});
        } else {
          // PUBLIC or JUST_FRIEND: recompute and re-subscribe
          final allowedIds = _computeAllowedFriends();
          _locationTrackingService.updateAllowedFriends(allowedIds);

          // Re-subscribe allowed friends
          for (final friend in _computeAllowedFriendModels()) {
            _mqttService.subscribeFriendLocation(friend.userId, currentUser.id);
          }
        }
      }

      if (kDebugMode) {
        print('📍 Visibility updated to: $visibility');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update visibility: $e');
    }
  }

  /// Update friend map modes after See Me / Freeze changes.
  /// [seeMeIds] = friends who can see, [freezeIds] = friends who cannot see.
  Future<void> updateFriendMapModes({
    required List<String> seeMeIds,
    required List<String> freezeIds,
  }) async {
    try {
      // Batch update: See Me → true
      if (seeMeIds.isNotEmpty) {
        await _friendRepository.updateFriendMapModes(
          friendIds: seeMeIds,
          mapMode: true,
        );
      }
      // Batch update: Freeze → false
      if (freezeIds.isNotEmpty) {
        await _friendRepository.updateFriendMapModes(
          friendIds: freezeIds,
          mapMode: false,
        );
      }

      // Reload from backend and sync
      await _loadFriendsWithMapMode();
      _syncAllowedFriends();

      // Re-subscribe MQTT topics
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // Unsubscribe all first
        for (final friend in state.friendsWithMapMode) {
          _mqttService.unsubscribeFriendLocation(friend.userId, currentUser.id);
        }
        // Re-subscribe allowed only
        for (final friend in state.friendsWithMapMode.where((f) => f.friendMapMode)) {
          _mqttService.subscribeFriendLocation(friend.userId, currentUser.id);
        }
      }

      if (kDebugMode) {
        print('📍 Friend map modes updated: seeMe=${seeMeIds.length}, freeze=${freezeIds.length}');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update friend map modes: $e');
    }
  }

  /// Sync allowed friends list to the background isolate (visibilityMode-aware).
  void _syncAllowedFriends() {
    final allowedIds = _computeAllowedFriends();
    _locationTrackingService.updateAllowedFriends(allowedIds);
  }

  /// Compute allowed friend IDs based on visibilityMode:
  /// - NO_ONE → empty list
  /// - PUBLIC → all friends
  /// - JUST_FRIEND → only friends with friendMapMode == true
  List<String> _computeAllowedFriends() {
    final visibility = state.locationVisibility;
    if (visibility == 'NO_ONE') return [];
    if (visibility == 'PUBLIC') {
      return state.friendsWithMapMode.map((f) => f.userId).toList();
    }
    // JUST_FRIEND
    return state.friendsWithMapMode
        .where((f) => f.friendMapMode)
        .map((f) => f.userId)
        .toList();
  }

  /// Compute allowed friend models (for MQTT subscription)
  List<FriendModel> _computeAllowedFriendModels() {
    final visibility = state.locationVisibility;
    if (visibility == 'NO_ONE') return [];
    if (visibility == 'PUBLIC') return state.friendsWithMapMode;
    // JUST_FRIEND
    return state.friendsWithMapMode.where((f) => f.friendMapMode).toList();
  }

  /// Load current visibility from backend
  Future<void> _loadVisibility() async {
    try {
      final userService = ref.read(userServiceProvider);
      final visibility = await userService.getVisibility();
      state = state.copyWith(locationVisibility: visibility);
    } catch (e) {
      if (kDebugMode) {
        print('📍 Failed to load visibility: $e');
      }
    }
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
        _emitUiEvent(
          'Distress signal is now broadcasting',
          HomeUiEventType.success,
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
        _emitUiEvent(
          'Distress signal has been revoked',
          HomeUiEventType.info,
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to revoke SOS');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to revoke SOS: $e');
    }
  }

  // ==================== Friend Sync ====================

  /// Sync map-related friend state after friend request is accepted.
  Future<void> syncAfterAcceptFriendRequest(String friendUserId) async {
    final updatedLocations = Map<String, LatLng>.from(state.friendLocations);
    updatedLocations.remove(friendUserId);
    state = state.copyWith(friendLocations: updatedLocations);

    await refreshFriends();
  }

  Future<void> removeFriend(String userId) async {
    try {
      final success = await _userRepository.removeFriend(userId);
      if (success) {
        await _loadFriendsWithMapMode(); // Refresh friends with map mode
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

  Future<void> takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _emitUiEvent('Picture taken: ${photo.path}', HomeUiEventType.success);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error taking picture: $e',
      );
    }
  }

  void showInfoMessage(String message) {
    _emitUiEvent(message, HomeUiEventType.info);
  }

  void clearUiEvent() {
    state = state.copyWith(clearUiEvent: true);
  }

  void _emitUiEvent(String message, HomeUiEventType type) {
    state = state.copyWith(
      uiEvent: HomeUiEvent(
        type: type,
        message: message,
      ),
    );
  }

  // ==================== Error Handling ====================

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
