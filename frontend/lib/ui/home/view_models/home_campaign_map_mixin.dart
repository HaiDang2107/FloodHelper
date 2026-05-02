part of 'home_view_model.dart';

mixin HomeCampaignMapMixin on _HomeViewModelBase {
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

  void setMapType(MapType mapType) {
    state = state.copyWith(selectedMapType: mapType);
  }

  void setShowStrangerLocation(bool value) {
    state = state.copyWith(showStrangerLocation: value);
  }

  void setShowPostLocation(bool value) {
    state = state.copyWith(showPostLocation: value);
  }

  Future<void> setShowCharityCampaignLocations(bool value) async {
    state = state.copyWith(showCharityCampaignLocations: value);

    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateShowCharityCampaignLocations(value);

      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.syncSessionShowCharityCampaignLocations(value);

      final sessionState = ref.read(globalSessionManagerProvider);
      final AuthSession? currentSession =
          sessionState is AsyncData<AuthSession?> ? sessionState.value : null;
      if (currentSession != null) {
        ref.read(globalSessionManagerProvider.notifier).setSession(
              currentSession.copyWith(
                user: currentSession.user.copyWith(
                  showCharityCampaignLocations: value,
                ),
              ),
            );
      }

      if (value) {
        await loadDistributingCampaignLocations();
      } else {
        state = state.copyWith(campaignLocations: const []);
      }
    } catch (e) {
      state = state.copyWith(
        showCharityCampaignLocations: !value,
        errorMessage: 'Failed to update campaign location display setting: $e',
      );
    }
  }

  Future<bool> focusOnCampaignLocation(
    String campaignId, {
    required double latitude,
    required double longitude,
  }) async {
    if (state.showCharityCampaignLocations && state.campaignLocations.isEmpty) {
      await loadDistributingCampaignLocations();
    }

    final campaignPin = mapPins.where((p) => p.userId == campaignId).firstOrNull;
    if (campaignPin != null) {
      selectPin(campaignPin.userId);
      moveCameraToLocation(campaignPin.position);
      return true;
    }

    moveCameraToLocation(LatLng(latitude, longitude));
    return false;
  }

  Future<void> loadDistributingCampaignLocations() async {
    if (!state.showCharityCampaignLocations) {
      state = state.copyWith(campaignLocations: const []);
      return;
    }

    try {
      final locations =
          await _charityCampaignRepository.getDistributingCampaignLocations();
      state = state.copyWith(
        campaignLocations: locations
            .map(
              (item) => HomeCampaignLocationPin(
                campaignId: item.campaignId,
                campaignName: item.campaignName,
                destination: item.destination,
                position: LatLng(item.latitude, item.longitude),
              ),
            )
            .toList(growable: false),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load campaign locations: $e',
      );
    }
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
      final friendInfo = state.friendsWithMapMode
          .where((f) => f.userId == entry.key)
          .firstOrNull;

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
      final friendInfo = state.friendsWithMapMode
          .where((f) => f.userId == entry.key)
          .firstOrNull;
      final victimName = state.victimFullnames[entry.key];

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

    if (state.showCharityCampaignLocations) {
      for (final campaign in state.campaignLocations) {
        pinsById[campaign.campaignId] = HomeMapPin(
          userId: campaign.campaignId,
          fullname: campaign.campaignName,
          avatarUrl: '',
          position: campaign.position,
          pinType: HomePinType.campaign,
          isSos: false,
          campaignId: campaign.campaignId,
          campaignDestination: campaign.destination,
        );
      }
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
      HomePinType.campaign => 'Charity Campaign',
    };

    return HomePinBubbleData(
      title: title,
      userId: pin.userId,
      fullname: pin.fullname,
      pinType: pin.pinType,
      canHandle: currentUser.isRescuer && pin.pinType == HomePinType.victim,
    );
  }

  HomeCampaignLocationPin? getCampaignLocationById(String campaignId) {
    return state.campaignLocations
        .where((item) => item.campaignId == campaignId)
        .firstOrNull;
  }

  Future<CharityCampaign> loadCampaignDetailFromMapPin(String campaignId) async {
    try {
      return await _charityCampaignRepository.getCampaignDetail(campaignId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load campaign detail: $e',
      );
      rethrow;
    }
  }

  Future<List<Donation>> loadSuccessCampaignTransactions(String campaignId) async {
    try {
      return await _charityCampaignRepository.getCampaignTransactions(
        campaignId: campaignId,
        state: 'SUCCESS',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load transactions: $e',
      );
      rethrow;
    }
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
}
