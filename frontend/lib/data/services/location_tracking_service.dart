import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import 'mqtt_service.dart';

// ================================================================
//  Top-level functions — these run in the BACKGROUND isolate
// ================================================================

const String _kNotificationChannelId = 'floodhelper_location';

/// Entry point for the background isolate.
/// Must be a **top-level** function (not a class method).
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async { // service được hệ thống nhét từ ngoài
  DartPluginRegistrant.ensureInitialized();

  final mqttService = MqttService();
  String? userId;
  bool mqttConnected = false;
  List<String> allowedFriends = [];

  // Listen for userId sent from UI isolate (lắng nghe kênh setUserId)
  service.on('setUserId').listen((event) async {
    userId = event?['userId'] as String?;
    if (userId != null && !mqttConnected) {
      mqttConnected = await mqttService.connect(userId!);
      if (kDebugMode) {
        print('📡 [BG] MQTT connected for $userId: $mqttConnected');
      }
    }
  });

  // Listen for allowed friends list from UI isolate
  service.on('setAllowedFriends').listen((event) {
    if (event != null && event['friendIds'] != null) {
      allowedFriends = List<String>.from(event['friendIds']);
      if (kDebugMode) {
        print('📡 [BG] Allowed friends updated: $allowedFriends');
      }
    }
  });

  // Listen for stop command from UI isolate
  service.on('stopService').listen((_) {
    mqttService.disconnect();
    service.stopSelf();
  });

  // Periodic GPS poll + MQTT publish
  Timer.periodic(
    Duration(seconds: AppConfig.locationPublishIntervalSeconds),
    (_) async {
      if (userId == null) return;

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        // 1. Publish to MQTT with new topic convention
        if (mqttConnected) {
          final payload = jsonEncode({
            'lat': position.latitude,
            'lng': position.longitude,
            'allowed_friends': allowedFriends,
          });
          mqttService.publishRaw(
            topic: '$userId/${AppConfig.mqttCurrentLocationSuffix}',
            payload: payload,
          );
        }

        // 2. Send location back to UI isolate (for map marker)
        service.invoke('onLocationUpdate', {
          'latitude': position.latitude,
          'longitude': position.longitude,
        });

        // 3. Update sticky notification with coordinates
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: AppConfig.notificationTitle,
            content:
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
          );
        }

        if (kDebugMode) {
          print(
            '📍 [BG] (${position.latitude}, ${position.longitude})',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('📍 [BG] Poll error: $e');
        }
      }
    },
  );
}

/// iOS background fetch handler (required by flutter_background_service).
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}

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

  StreamSubscription? _bgSubscription; // dùng để quản lý listener

  // -------------------- Initialization --------------------

  /// Configure the background service.
  /// Must be called **once** before [start], typically in `main()`.
  Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (kDebugMode) {
        print('📍 Background service initialization skipped (non-Android runtime)');
      }
      return;
    }

    // Create Android notification channel (silent, low importance)
    const channel = AndroidNotificationChannel(
      _kNotificationChannelId,
      AppConfig.notificationChannelName,
      description: 'Foreground service notification for location tracking',
      importance: Importance.low,
    );

    final flnPlugin = FlutterLocalNotificationsPlugin();
    await flnPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // background service không tự động khởi động 
        isForegroundMode: true,
        foregroundServiceTypes: [AndroidForegroundType.location],
        notificationChannelId: _kNotificationChannelId,
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
  Future<LocationUpdate> start(String userId, {List<String> allowedFriendIds = const []}) async {
    // 1. Check permissions
    await _ensureLocationPermission();

    // 2. Get initial position on UI thread (fast, shows map immediately)
    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    final initialUpdate = LocationUpdate(
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
      timestamp: DateTime.now(),
    );
    _locationController.add(initialUpdate);

    // 3. Start the background isolate (đánh thức hàm onStart())
    await _service.startService();

    // 4. Send userId so background isolate can connect MQTT
    _service.invoke('setUserId', {'userId': userId}); 

    // 4b. Send initial allowed friends list
    _service.invoke('setAllowedFriends', {'friendIds': allowedFriendIds});

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
    _service.invoke('stopService');

    if (kDebugMode) {
      print('📍 Background service stopped');
    }
  }

  /// Full cleanup: stop service + close stream.
  void dispose() {
    stop();
    _locationController.close();
  }

  /// Update the allowed friends list in the background isolate.
  /// Called when user changes map mode settings.
  void updateAllowedFriends(List<String> friendIds) {
    _service.invoke('setAllowedFriends', {'friendIds': friendIds});
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
