part of 'home_view_model.dart';

mixin HomeRuntimeMixin on _HomeViewModelBase {
  /// Start location tracking via the background service
  Future<void> _startTracking() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      state = state.copyWith(
        showCharityCampaignLocations: currentUser!.showCharityCampaignLocations,
      );

      await _loadFriendsWithMapMode();
      await _loadVisibility();

      final allowedFriendIds = _computeAllowedFriends();

      final initialUpdate = await _locationTrackingService.start(
        currentUser.id,
        fullname: currentUser.effectiveDisplayName,
        allowedFriendIds: allowedFriendIds,
        isRescuer: currentUser.isRescuer,
      );

      _locationTrackingService.setUiIsActive(true);
      _locationTrackingService.setSosStatus(state.isSosBroadcasting);

      final initialLatLng = LatLng(
        initialUpdate.latitude,
        initialUpdate.longitude,
      );
      state = state.copyWith(currentPosition: initialLatLng, isLoading: false);
      mapController.move(initialLatLng, 15.0);

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

      if (state.showCharityCampaignLocations) {
        await loadDistributingCampaignLocations();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

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

  Future<void> _setupFriendSubscriptions(String myUserId) async {
    final connected = await _mqttService.connect('${myUserId}_ui');
    if (!connected) {
      if (kDebugMode) {
        print('📡 [UI] MQTT connect failed for friend subscriptions');
      }
      return;
    }

    final allowedFriends = _computeAllowedFriendModels();

    for (final friend in allowedFriends) {
      _mqttService.subscribeFriendLocation(friend.userId, myUserId);
    }

    _mqttService.startListeningFriendLocations(myUserId);

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

  Future<void> refreshFriends() async {
    await _loadFriendsWithMapMode();
    _syncAllowedFriends();

    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      await _setupFriendSubscriptions(currentUser.id);
    }
  }

  Future<void> updateLocationVisibility(String visibility) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateVisibility(visibility);

      state = state.copyWith(locationVisibility: visibility);

      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        for (final friend in state.friendsWithMapMode) {
          _mqttService.unsubscribeFriendLocation(friend.userId, currentUser.id);
        }

        if (visibility == 'NO_ONE') {
          _locationTrackingService.updateAllowedFriends([]);
          state = state.copyWith(friendLocations: {});
        } else {
          final allowedIds = _computeAllowedFriends();
          _locationTrackingService.updateAllowedFriends(allowedIds);

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

  Future<void> updateFriendMapModes({
    required List<String> seeMeIds,
    required List<String> freezeIds,
  }) async {
    try {
      if (seeMeIds.isNotEmpty) {
        await _friendRepository.updateFriendMapModes(
          friendIds: seeMeIds,
          mapMode: true,
        );
      }
      if (freezeIds.isNotEmpty) {
        await _friendRepository.updateFriendMapModes(
          friendIds: freezeIds,
          mapMode: false,
        );
      }

      await _loadFriendsWithMapMode();
      _syncAllowedFriends();

      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        for (final friend in state.friendsWithMapMode) {
          _mqttService.unsubscribeFriendLocation(friend.userId, currentUser.id);
        }
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

  void _syncAllowedFriends() {
    final allowedIds = _computeAllowedFriends();
    _locationTrackingService.updateAllowedFriends(allowedIds);
  }

  List<String> _computeAllowedFriends() {
    final visibility = state.locationVisibility;
    if (visibility == 'NO_ONE') return [];
    if (visibility == 'PUBLIC') {
      return state.friendsWithMapMode.map((f) => f.userId).toList();
    }
    return state.friendsWithMapMode
        .where((f) => f.friendMapMode)
        .map((f) => f.userId)
        .toList();
  }

  List<FriendModel> _computeAllowedFriendModels() {
    final visibility = state.locationVisibility;
    if (visibility == 'NO_ONE') return [];
    if (visibility == 'PUBLIC') return state.friendsWithMapMode;
    return state.friendsWithMapMode.where((f) => f.friendMapMode).toList();
  }

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
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || !currentUser.isRescuer) {
      return;
    }
    _locationTrackingService.publishRescuerHandleCommand({
      'userId': victimUserId,
      'handled_by': currentUser.id,
    });
  }

  Future<void> _restoreSosState(String userId) async {
    try {
      final latest = await _signalService.getMyLatestSignal();
      if (latest != null && latest.isBroadcasting && latest.signal != null) {
        state = state.copyWith(
          isSosBroadcasting: true,
          sosData: latest.signal,
        );
        _locationTrackingService.setSosStatus(true);
        await SosLocalStorage.saveBroadcastingState(
          userId,
          latest.signal!,
        );
        return;
      }

      await SosLocalStorage.clearBroadcastingState(userId);
    } catch (_) {
      // Fallback to local snapshot when API is unreachable.
    }

    final local = await SosLocalStorage.getBroadcastingState(userId);
    if (local != null) {
      state = state.copyWith(isSosBroadcasting: true, sosData: local);
      _locationTrackingService.setSosStatus(true);
      return;
    }

    state = state.copyWith(isSosBroadcasting: false, clearSosData: true);
    _locationTrackingService.setSosStatus(false);
  }

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
        await _loadFriendsWithMapMode();
      } else {
        state = state.copyWith(errorMessage: 'Failed to remove friend');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove friend: $e');
    }
  }
}
