import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
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
import '../../../domain/models/auth_session.dart';
import '../../../domain/models/charity_campaign.dart';
import '../../../domain/models/distress_signal_input.dart';
import '../../../domain/models/rescuer_distress_alert.dart';
import 'friend_view_model.dart';

part 'home_state.dart';
part 'home_runtime_mixin.dart';
part 'home_campaign_map_mixin.dart';
part 'home_content_mixin.dart';
part 'home_ui_feedback_mixin.dart';
part 'home_view_model.g.dart';

abstract class _HomeViewModelBase extends _$HomeViewModel { // Định nghĩa các state chung, các mixin đều có thể sử dụng.
  HomeState get state;
  set state(HomeState value);

  MapController get mapController;
  ImagePicker get _imagePicker;
  LocationTrackingService get _locationTrackingService;
  MqttService get _mqttService;
  SignalService get _signalService;

  UserRepository get _userRepository;
  PostRepository get _postRepository;
  AnnouncementRepository get _announcementRepository;
  FriendRepository get _friendRepository;
  CharityCampaignRepository get _charityCampaignRepository;

  set _locationSubscription(StreamSubscription<LocationUpdate>? value);
  set _friendLocationSubscription(StreamSubscription<FriendLocationUpdate>? value);
  StreamSubscription<VictimAlert>? get _victimLocationSubscription;
  set _victimLocationSubscription(StreamSubscription<VictimAlert>? value);
  StreamSubscription<VictimSignalEvent>? get _victimStoppedSubscription;
  set _victimStoppedSubscription(StreamSubscription<VictimSignalEvent>? value);
  StreamSubscription<VictimSignalEvent>? get _victimHandledSubscription;
  set _victimHandledSubscription(StreamSubscription<VictimSignalEvent>? value);
  StreamSubscription<RescuerReplyEvent>? get _rescuerReplySubscription;
  set _rescuerReplySubscription(StreamSubscription<RescuerReplyEvent>? value);

  Future<void> refreshFriends();
  Future<void> syncAfterAcceptFriendRequest(String friendUserId);
  Future<void> _loadFriendsWithMapMode();
  Future<void> loadDistributingCampaignLocations();
  void _clearSelectionIfHidden();
  void _emitUiEvent(String message, HomeUiEventType type);
}

@riverpod
class HomeViewModel extends _HomeViewModelBase
  with
    HomeRuntimeMixin,
    HomeCampaignMapMixin,
    HomeContentMixin,
    HomeUiFeedbackMixin {
  final MapController mapController = MapController();
  final ImagePicker _imagePicker = ImagePicker();
  late final LocationTrackingService _locationTrackingService = ref.read(
    locationTrackingServiceProvider,
  );

  // MQTT service (UI isolate — for subscribing to friend locations)
  late final MqttService _mqttService = ref.read(mqttServiceProvider);
  late final SignalService _signalService = ref.read(signalServiceProvider);

  // Repositories
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  late final AnnouncementRepository _announcementRepository;
  late final FriendRepository _friendRepository;
  late final CharityCampaignRepository _charityCampaignRepository;

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
    _charityCampaignRepository = ref.read(charityCampaignRepositoryProvider);

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
}
