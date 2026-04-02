import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../../domain/models/rescuer_distress_alert.dart';
import 'location_tracking_background.dart';

// ================================================================
//  LocationUpdate — data class for UI layer
// ================================================================

class LocationUpdate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class VictimSignalEvent {
  final String userId;
  final String? fullname;
  final String? handledBy;
  final String? rescuerFullname;

  const VictimSignalEvent({
    required this.userId,
    this.fullname,
    this.handledBy,
    this.rescuerFullname,
  });
}

class RescuerReplyEvent {
  final String rescuerFullname;
  final String? handledBy;

  const RescuerReplyEvent({required this.rescuerFullname, this.handledBy});
}

// ================================================================
//  LocationTrackingService — called from the UI isolate
// ================================================================

/// Manages the background location tracking service.
///
/// From the UI side this class:
///   1. Configures & starts [FlutterBackgroundService]
///   2. Sends the userId so the background isolate can connect MQTT
///   3. Exposes a [locationStream] for the ViewModel to update the map
///
/// The actual GPS polling + MQTT publishing runs in a **separate isolate**
/// via [onStart], surviving screen-off and app backgrounding.
///
/// **Provider:** Use `locationTrackingServiceProvider` from `service_providers.dart`
class LocationTrackingService {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  final _locationController = StreamController<LocationUpdate>.broadcast();
  Stream<LocationUpdate> get locationStream => _locationController.stream;

  final _victimLocationController = StreamController<VictimAlert>.broadcast();
  Stream<VictimAlert> get victimLocationStream =>
      _victimLocationController.stream;

  final _victimStoppedController =
      StreamController<VictimSignalEvent>.broadcast();
  Stream<VictimSignalEvent> get victimStoppedStream =>
      _victimStoppedController.stream;

  final _victimHandledController =
      StreamController<VictimSignalEvent>.broadcast();
  Stream<VictimSignalEvent> get victimHandledStream =>
      _victimHandledController.stream;

  final _rescuerReplyController =
      StreamController<RescuerReplyEvent>.broadcast();
  Stream<RescuerReplyEvent> get rescuerReplyStream =>
      _rescuerReplyController.stream;

  StreamSubscription? _bgSubscription; // dùng để quản lý listener
  StreamSubscription? _rescuerSubscription;
  StreamSubscription? _victimStoppedSubscription;
  StreamSubscription? _victimHandledSubscription;
  StreamSubscription? _rescuerReplySubscription;

  Future<void> _bindUserIdWithRetry(String userId, {String? fullname}) async {
    final completer = Completer<void>();
    StreamSubscription? ackSub;

    ackSub = _service.on('onUserIdBound').listen((event) {
      final boundUserId = (event?['userId'] ?? '').toString();
      if (!completer.isCompleted && boundUserId == userId) {
        completer.complete();
      }
    });

    try {
      for (var i = 0; i < 6; i++) {
        _service.invoke('setUserId', {'userId': userId, 'fullname': fullname});

        if (i == 0) {
          // First send can race with isolate boot on some devices.
          await Future.delayed(const Duration(milliseconds: 250));
        } else {
          await Future.delayed(const Duration(milliseconds: 400));
        }

        if (completer.isCompleted) {
          break;
        }
      }

      if (!completer.isCompleted) {
        if (kDebugMode) {
          print('📍 [UI] setUserId ACK timeout, continue with best effort');
        }
        return;
      }

      await completer.future;
    } finally {
      await ackSub.cancel();
    }
  }

  // -------------------- Initialization --------------------

  /// Configure the background service.
  /// Must be called **once** before [start], typically in `main()`.
  Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (kDebugMode) {
        print(
          '📍 Background service initialization skipped (non-Android runtime)',
        );
      }
      return;
    }

    // Create Android notification channel (silent, low importance)
    const channel = AndroidNotificationChannel(
      kLocationNotificationChannelId,
      AppConfig.notificationChannelName,
      description: 'Foreground service notification for location tracking',
      importance: Importance.low,
    );

    const distressAlertChannel = AndroidNotificationChannel(
      kDistressAlertChannelId,
      AppConfig.distressAlertChannelName,
      description: 'Critical rescue alerts for rescuers',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final flnPlugin = FlutterLocalNotificationsPlugin();
    await flnPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await flnPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(distressAlertChannel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // background service không tự động khởi động
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        notificationChannelId: kLocationNotificationChannelId,
        initialNotificationTitle: AppConfig.notificationTitle,
        initialNotificationContent: AppConfig.notificationContent,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // -------------------- Start / Stop --------------------

  /// Start the background service, get initial position, begin tracking.
  Future<LocationUpdate> start(
    String userId, {
    String? fullname,
    List<String> allowedFriendIds = const [],
    bool isRescuer = false,
  }) async {
    // 1. Check permissions
    await _ensureLocationPermission();

    // 2. Get initial position on UI thread (fast, shows map immediately)
    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final initialUpdate = LocationUpdate(
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
      timestamp: DateTime.now(),
    );
    _locationController.add(initialUpdate);

    // 3. Start the background isolate (đánh thức hàm onStart()) only if needed.
    final serviceRunning = await _service.isRunning();
    if (!serviceRunning) {
      await _service.startService();
      if (kDebugMode) {
        print('📍 Background service started from UI');
      }
    } else if (kDebugMode) {
      print('📍 Background service already running, skip startService()');
    }

    // 4. Send userId so background isolate can connect MQTT (with retry handshake)
    await _bindUserIdWithRetry(userId, fullname: fullname);

    // 4b. Send initial allowed friends list
    _service.invoke('setAllowedFriends', {'friendIds': allowedFriendIds});

    // 4c. Send rescuer role flag to background isolate
    _service.invoke('setRescuerMode', {'isRescuer': isRescuer});

    // 5. Listen for location updates coming back from background
    // Khi gọi hàm .listen(...), ta đang ra lệnh cho hệ thống: "Hãy mở một luồng liên tục chạy ngầm trong RAM để nghe ngóng tin tức từ kênh onLocationUpdate
    // lưu vào _bgSubscription để dễ quản lý (có thể hủy bất cứ lúc nào)
    _bgSubscription = _service.on('onLocationUpdate').listen((event) {
      if (event != null) {
        final update = LocationUpdate(
          latitude: (event['latitude'] as num).toDouble(),
          longitude: (event['longitude'] as num).toDouble(),
          timestamp: DateTime.now(),
        );
        _locationController.add(update); // Ném dữ liệu vào stream
      }
    });

    _rescuerSubscription = _service.on('onRescuerDistress').listen((event) {
      if (event == null) return;

      final userId = (event['userId'] ?? '').toString();
      final lat = (event['lat'] as num?)?.toDouble();
      final lng = (event['long'] as num?)?.toDouble();
      if (userId.isEmpty || lat == null || lng == null) return;

      _victimLocationController.add(
        VictimAlert(
          userId: userId,
          fullname: (event['fullname'] ?? '').toString(),
          latitude: lat,
          longitude: lng,
        ),
      );
    });

    _victimStoppedSubscription = _service.on('onVictimStopped').listen((event) {
      if (event == null) return;
      final victimUserId = (event['userId'] ?? '').toString();
      if (victimUserId.isEmpty) return;

      _victimStoppedController.add(
        VictimSignalEvent(
          userId: victimUserId,
          fullname: (event['fullname'] ?? '').toString(),
        ),
      );
    });

    _victimHandledSubscription = _service.on('onVictimHandled').listen((event) {
      if (event == null) return;
      final victimUserId = (event['userId'] ?? '').toString();
      if (victimUserId.isEmpty) return;

      _victimHandledController.add(
        VictimSignalEvent(
          userId: victimUserId,
          handledBy: (event['handledBy'] ?? '').toString(),
          rescuerFullname: (event['rescuerFullname'] ?? '').toString(),
        ),
      );
    });

    _rescuerReplySubscription = _service.on('onRescuerReply').listen((event) {
      if (event == null) return;

      final rescuerFullname =
          (event['rescuerFullname'] ?? event['rescuer_fullname'] ?? '')
              .toString();
      if (rescuerFullname.isEmpty) return;

      _rescuerReplyController.add(
        RescuerReplyEvent(
          rescuerFullname: rescuerFullname,
          handledBy: (event['handledBy'] ?? event['handled_by'])?.toString(),
        ),
      );
    });

    if (kDebugMode) {
      print(
        '📍 Background service started '
        '(every ${AppConfig.locationPublishIntervalSeconds}s)',
      );
    }

    return initialUpdate;
  }

  /// Stop the background service.
  Future<void> stop() async {
    _bgSubscription?.cancel();
    _bgSubscription = null;
    _rescuerSubscription?.cancel();
    _rescuerSubscription = null;
    _victimStoppedSubscription?.cancel();
    _victimStoppedSubscription = null;
    _victimHandledSubscription?.cancel();
    _victimHandledSubscription = null;
    _rescuerReplySubscription?.cancel();
    _rescuerReplySubscription = null;
    _service.invoke('stopService');

    if (kDebugMode) {
      print('📍 Background service stopped');
    }
  }

  /// Full cleanup: stop service + close stream.
  void dispose() {
    stop();
    _locationController.close();
    _victimLocationController.close();
    _victimStoppedController.close();
    _victimHandledController.close();
    _rescuerReplyController.close();
  }

  /// Update the allowed friends list in the background isolate.
  /// Called when user changes map mode settings.
  void updateAllowedFriends(List<String> friendIds) {
    _service.invoke('setAllowedFriends', {'friendIds': friendIds});
  }

  /// Update SOS state in background isolate so current-location payload can include isSoS.
  void setSosStatus(bool isSoS) {
    _service.invoke('setSoSStatus', {'isSoS': isSoS});
  }

  /// Publish distress signal command through background isolate to MQTT topic `signal`.
  void publishSignalCommand(Map<String, dynamic> commandPayload) {
    _service.invoke('publishSignalCommand', commandPayload);
  }

  /// Publish rescuer handle action through background isolate to MQTT `rescuer/handle`.
  void publishRescuerHandleCommand(Map<String, dynamic> commandPayload) {
    _service.invoke('publishRescuerHandleCommand', commandPayload);
  }

  /// Tell background isolate whether UI isolate is currently active.
  void setUiIsActive(bool isUiActive) {
    _service.invoke('setUiIsActive', {'isUiActive': isUiActive});
  }

  // -------------------- Private --------------------

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. '
        'Please enable them in Settings.',
      );
    }
  }
}
