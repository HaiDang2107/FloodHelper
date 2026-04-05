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
import '../../../data/services/signal_service.dart';
import '../../../data/services/sos_local_storage.dart';
import '../../../domain/models/distress_signal_input.dart';
import '../../../domain/models/rescuer_distress_alert.dart';
import 'friend_view_model.dart';

part 'home_state.dart';
part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  final MapController mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();
  late final LocationTrackingService _locationTrackingService = ref.read(
    locationTrackingServiceProvider,
  );

  // MQTT service (UI isolate — for subscribing to friend locations)
  late final MqttService _mqttService = ref.read(mqttServiceProvider);
  late final SignalService _signalService = SignalService(
    apiClient: ref.read(apiClientProvider),
  );

  // Repositories
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  late final AnnouncementRepository _announcementRepository;
  late final FriendRepository _friendRepository;

  // Location stream subscription
  StreamSubscription<LocationUpdate>? _locationSubscription;

  // Friend location stream subscription
  StreamSubscription<FriendLocationUpdate>? _friendLocationSubscription;
  StreamSubscription<VictimAlert>? _victimLocationSubscription;
  StreamSubscription<VictimSignalEvent>? _victimStoppedSubscription;
  StreamSubscription<VictimSignalEvent>? _victimHandledSubscription;
  StreamSubscription<RescuerReplyEvent>? _rescuerReplySubscription;
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
      _victimLocationSubscription?.cancel();
      _victimStoppedSubscription?.cancel();
      _victimHandledSubscription?.cancel();
      _rescuerReplySubscription?.cancel();
      _mqttService.stopListeningFriendLocations();
    });

    ref.listen(friendViewModelProvider, (previous, next) {
      final acceptedFriendId = next.acceptedFriendUserId;
      if (acceptedFriendId == null ||
          acceptedFriendId == previous?.acceptedFriendUserId) {
        return;
      }

      unawaited(syncAfterAcceptFriendRequest(acceptedFriendId));
      ref.read(friendViewModelProvider.notifier).clearAcceptedFriendSyncEvent();
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
        fullname: currentUser.effectiveDisplayName,
        allowedFriendIds: allowedFriendIds,
        isRescuer: currentUser.isRescuer,
      );

      _locationTrackingService.setUiIsActive(true);
      _locationTrackingService.setSosStatus(state.isSosBroadcasting);

      // 4. Update UI with initial position
      final initialLatLng = LatLng(
        initialUpdate.latitude,
        initialUpdate.longitude,
      );
      state = state.copyWith(currentPosition: initialLatLng, isLoading: false);
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

      _victimLocationSubscription?.cancel();
      _victimLocationSubscription = _locationTrackingService
          .victimLocationStream
          .listen((alert) {
            final updated = Map<String, LatLng>.from(state.victimLocations);
            final names = Map<String, String>.from(state.victimFullnames);
            updated[alert.userId] = LatLng(alert.latitude, alert.longitude);
            final fullname = (alert.fullname ?? '').trim();
            if (fullname.isNotEmpty) {
              names[alert.userId] = fullname;
            }
            state = state.copyWith(
              victimLocations: updated,
              victimFullnames: names,
            );
          });

      _victimStoppedSubscription?.cancel();
      _victimStoppedSubscription = _locationTrackingService.victimStoppedStream
          .listen((event) {
            final updated = Map<String, LatLng>.from(state.victimLocations);
            final names = Map<String, String>.from(state.victimFullnames);
            updated.remove(event.userId);
            names.remove(event.userId);
            state = state.copyWith(
              victimLocations: updated,
              victimFullnames: names,
            );
            _clearSelectionIfHidden();
          });

      _victimHandledSubscription?.cancel();
      _victimHandledSubscription = _locationTrackingService.victimHandledStream
          .listen((event) {
            final updated = Map<String, LatLng>.from(state.victimLocations);
            final names = Map<String, String>.from(state.victimFullnames);
            updated.remove(event.userId);
            names.remove(event.userId);
            state = state.copyWith(
              victimLocations: updated,
              victimFullnames: names,
            );
            _clearSelectionIfHidden();
          });

      _rescuerReplySubscription?.cancel();
      _rescuerReplySubscription = _locationTrackingService.rescuerReplyStream
          .listen((event) async {
            state = state.copyWith(
              isSosBroadcasting: false,
              clearSosData: true,
            );
            _locationTrackingService.setSosStatus(false);
            await SosLocalStorage.clearBroadcastingState(currentUser.id);
            _emitUiEvent(
              'Your distress signal is now handled by ${event.rescuerFullname}',
              HomeUiEventType.success,
            );
          });

      await _restoreSosState(currentUser.id);
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
    final connected = await _mqttService.connect(
      '${myUserId}_ui',
    ); // mỗi thiết bị kết nối đến Broker phải có một cái tên (ID) duy nhất
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
    _friendLocationSubscription = _mqttService.friendLocationStream.listen((
      update,
    ) {
      if (kDebugMode) {
        print(
          '✅ [UI] NHẬN ĐƯỢC VỊ TRÍ BẠN BÈ: ${update.friendId} -> ${update.latitude}, ${update.longitude}',
        );
      }
      final updatedLocations = Map<String, LatLng>.from(state.friendLocations);
      updatedLocations[update.friendId] = LatLng(
        update.latitude,
        update.longitude,
      );
      state = state.copyWith(friendLocations: updatedLocations);
    });

    if (kDebugMode) {
      print(
        '📡 [UI] Subscribed to ${allowedFriends.length} friend location topics',
      );
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

  bool focusOnVictim(String victimUserId) {
    final pin = mapPins.where((p) => p.userId == victimUserId).firstOrNull;
    if (pin == null) {
      return false;
    }
    selectPin(victimUserId);
    moveCameraToLocation(pin.position);
    return true;
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
        for (final friend in state.friendsWithMapMode.where(
          (f) => f.friendMapMode,
        )) {
          _mqttService.subscribeFriendLocation(friend.userId, currentUser.id);
        }
      }

      if (kDebugMode) {
        print(
          '📍 Friend map modes updated: seeMe=${seeMeIds.length}, freeze=${freezeIds.length}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update friend map modes: $e',
      );
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

  Future<void> broadcastSos(DistressSignalInput data) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        state = state.copyWith(errorMessage: 'User session not found');
        return;
      }

      final wasBroadcasting = state.isSosBroadcasting;

      if (!wasBroadcasting) {
        _locationTrackingService.publishSignalCommand({
          'command': 'CREATE',
          'created_by': currentUser.id,
          'data': _toDistressCommandData(data),
        });
        _emitUiEvent(
          'Distress signal is now broadcasting',
          HomeUiEventType.success,
        );
      } else {
        _locationTrackingService.publishSignalCommand({
          'command': 'UPDATE-INFO',
          'updated_by': currentUser.id,
          'data': _toDistressCommandData(data),
        });
        _emitUiEvent(
          'Distress signal information updated',
          HomeUiEventType.info,
        );
      }

      _locationTrackingService.setSosStatus(true);
      state = state.copyWith(isSosBroadcasting: true, sosData: data);
      await SosLocalStorage.saveBroadcastingState(currentUser.id, data);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to broadcast SOS: $e');
    }
  }

  Future<void> revokeSos() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        state = state.copyWith(errorMessage: 'User session not found');
        return;
      }

      _locationTrackingService.publishSignalCommand({
        'command': 'STOPPED',
        'stopped_by': currentUser.id,
        'data': <String, dynamic>{},
      });
      _locationTrackingService.setSosStatus(false);

      state = state.copyWith(isSosBroadcasting: false, clearSosData: true);
      await SosLocalStorage.clearBroadcastingState(currentUser.id);
      _emitUiEvent('Distress signal has been revoked', HomeUiEventType.info);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to revoke SOS: $e');
    }
  }

  Map<String, dynamic> _toDistressCommandData(DistressSignalInput data) {
    return {
      'trappedCounts': data.trappedCounts,
      'childrenNumbers': data.childrenNumbers,
      'elderlyNumbers': data.elderlyNumbers,
      'hasFood': data.hasFood,
      'hasWater': data.hasWater,
      'other': data.other,
    };
  }

  void setUiIsActive(bool isUiActive) {
    _locationTrackingService.setUiIsActive(isUiActive);
  }

  Future<void> handleVictimDistress(String victimUserId) async {
    // handle signal
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || !currentUser.isRescuer) {
      return;
    }
    _locationTrackingService.publishRescuerHandleCommand({
      'userId': victimUserId,
      'handled_by': currentUser.id,
    });
  }

  void selectPin(String? userId) {
    state = state.copyWith(
      selectedPinId: userId,
      clearSelectedPin: userId == null,
    );
  }

  List<HomeMapPin> get mapPins {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return const [];
    }

    final pinsById = <String, HomeMapPin>{};

    for (final entry in state.friendLocations.entries) {
      // .extries là danh sách các phần tử của map
      final friendInfo = state.friendsWithMapMode
          .where((f) => f.userId == entry.key)
          .firstOrNull;

      // entry.key là id
      // convert từ FriendLocation sang HomeMapPin
      pinsById[entry.key] = HomeMapPin(
        userId: entry.key,
        fullname: friendInfo?.name ?? '[Fail to load]',
        avatarUrl: friendInfo?.avatarUrl ?? '',
        position: entry.value,
        pinType: HomePinType.friend,
        isSos: false,
      );
    }

    for (final entry in state.victimLocations.entries) {
      // Đảo qua danh sách bạn bè (friendsWithMapMode chứa danh sách bạn bè) để lọc những friend có trong danh sách victim
      // Điều kiện lọc: f.userId == entry.key
      final friendInfo = state.friendsWithMapMode
          .where((f) => f.userId == entry.key)
          .firstOrNull; // chỉ lấy người đầu tiên với 1 id cụ thể
      final victimName = state.victimFullnames[entry.key];

      // Convert từ VictimLocation sang HomeMapPin
      pinsById[entry.key] = HomeMapPin(
        userId: entry.key,
        fullname: (victimName != null && victimName.trim().isNotEmpty)
            ? victimName
            : (friendInfo?.name ?? '[Fail to load]'),
        avatarUrl: friendInfo?.avatarUrl ?? '',
        position: entry.value,
        pinType: HomePinType.victim,
        isSos: true,
      );
    }

    if (state.currentPosition != null) {
      pinsById[currentUser.id] = HomeMapPin(
        userId: currentUser.id,
        fullname: currentUser.name,
        avatarUrl: currentUser.avatarUrl ?? '',
        position: state.currentPosition!,
        pinType: HomePinType.me,
        isSos: state.isSosBroadcasting,
      );
    }

    return pinsById.values.toList(growable: false);
  }

  HomePinBubbleData? get selectedBubbleData {
    final currentUser = ref.read(currentUserProvider);
    final selectedId = state.selectedPinId;
    if (selectedId == null || currentUser == null) {
      return null;
    }

    final pin = mapPins.where((p) => p.userId == selectedId).firstOrNull;
    if (pin == null) {
      return null;
    }

    final title = switch (pin.pinType) {
      HomePinType.me => 'Me',
      HomePinType.friend => 'Friend',
      HomePinType.victim => 'Victim',
    };

    return HomePinBubbleData(
      title: title,
      userId: pin.userId,
      fullname: pin.fullname,
      pinType: pin.pinType,
      canHandle: currentUser.isRescuer && pin.pinType == HomePinType.victim,
    );
  }

  void _clearSelectionIfHidden() {
    final selectedId = state.selectedPinId;
    if (selectedId == null) {
      return;
    }

    final stillVisible = mapPins.any((pin) => pin.userId == selectedId);
    if (!stillVisible) {
      state = state.copyWith(clearSelectedPin: true);
    }
  }

  Future<void> _restoreSosState(String userId) async {
    // khôi phục trạng thái SOS khi màn hình Home khởi động lại hoặc ViewModel được dựng lại.
    try {
      final latest = await _signalService
          .getMyLatestSignal(); // Lấy signal mới nhất của user từ backend
      if (latest != null && latest.isBroadcasting && latest.signal != null) {
        //
        state = state.copyWith(
          // cập nhật state theo dữ liệu mới
          isSosBroadcasting: true,
          sosData: latest.signal,
        );
        _locationTrackingService.setSosStatus(true); // Báo cho isolate
        await SosLocalStorage.saveBroadcastingState(
          userId,
          latest.signal!,
        ); // Lưu vào local storage
        return;
      }

      await SosLocalStorage.clearBroadcastingState(
        userId,
      ); // Nếu signal mới nhất không phải BROADCASTING ==> Xóa ở local storage
    } catch (_) {
      // Fallback to local snapshot when API is unreachable.
    }

    final local = await SosLocalStorage.getBroadcastingState(userId);
    // Nếu có dữ liệu signal ở trạng thái broadcasting thì mới lấy
    if (local != null) {
      state = state.copyWith(isSosBroadcasting: true, sosData: local);
      _locationTrackingService.setSosStatus(true);
      return;
    }

    state = state.copyWith(isSosBroadcasting: false, clearSosData: true);
    _locationTrackingService.setSosStatus(false);
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

  Future<void> createPost({required String caption, String? imageUrl}) async {
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

  void showInfoMessage(String message) {
    _emitUiEvent(message, HomeUiEventType.info);
  }

  void clearUiEvent() {
    state = state.copyWith(clearUiEvent: true);
  }

  void _emitUiEvent(String message, HomeUiEventType type) {
    state = state.copyWith(
      uiEvent: HomeUiEvent(type: type, message: message),
    );
  }

  // ==================== Error Handling ====================

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
