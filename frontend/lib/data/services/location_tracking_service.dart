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

  // Listen for userId sent from UI isolate
  service.on('setUserId').listen((event) async {
    userId = event?['userId'] as String?;
    if (userId != null && !mqttConnected) {
      mqttConnected = await mqttService.connect(userId!);
      if (kDebugMode) {
        print('📡 [BG] MQTT connected for $userId: $mqttConnected');
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

        // 1. Publish to MQTT
        if (mqttConnected) {
          final payload = jsonEncode({
            'userId': userId,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': DateTime.now().toIso8601String(),
          });
          mqttService.publishRaw(
            topic: '${AppConfig.mqttLocationTopicPrefix}/$userId',
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
/// **Singleton pattern** — ensures only one instance exists across the app.
class LocationTrackingService {
  static LocationTrackingService? _instance;
  final FlutterBackgroundService _service = FlutterBackgroundService();

  final _locationController = StreamController<LocationUpdate>.broadcast();
  Stream<LocationUpdate> get locationStream => _locationController.stream;

  StreamSubscription? _bgSubscription;

  // Private constructor for singleton
  LocationTrackingService._internal();

  // Factory constructor returns the same instance
  factory LocationTrackingService() {
    _instance ??= LocationTrackingService._internal();
    return _instance!;
  }

  // -------------------- Initialization --------------------

  /// Configure the background service.
  /// Must be called **once** before [start], typically in `main()`.
  Future<void> initialize() async {
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
        autoStart: false,
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
  Future<LocationUpdate> start(String userId) async {
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

    // 3. Start the background isolate
    await _service.startService();

    // 4. Send userId so background isolate can connect MQTT
    _service.invoke('setUserId', {'userId': userId});

    // 5. Listen for location updates coming back from background
    _bgSubscription = _service.on('onLocationUpdate').listen((event) {
      if (event != null) {
        final update = LocationUpdate(
          latitude: (event['latitude'] as num).toDouble(),
          longitude: (event['longitude'] as num).toDouble(),
          timestamp: DateTime.now(),
        );
        _locationController.add(update);
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
