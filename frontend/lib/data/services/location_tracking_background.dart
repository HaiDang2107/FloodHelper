import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../config/app_config.dart';
import 'mqtt_service.dart';

const String kLocationNotificationChannelId = 'floodhelper_location';
const String kDistressAlertChannelId = 'floodhelper_distress_alert';

/// Entry point for the background isolate.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final mqttService = MqttService();
  String? userId;
  String? fullname;
  bool mqttConnected = false;
  bool isSos = false;
  bool isRescuer = false;
  bool isUiActive = false;
  List<String> allowedFriends = [];
  StreamSubscription? rescuerSubscription;
  StreamSubscription? rescuerReplySubscription;

  void teardownRescuerSubscription() {
    rescuerSubscription?.cancel();
    rescuerSubscription = null;
    mqttService.unsubscribeTopic(AppConfig.mqttRescuerCommonTopic);
  }

  void teardownRescuerReplySubscription() {
    if (userId != null) {
      mqttService.unsubscribeTopic(
        '${userId!}/${AppConfig.mqttRescuerReplySuffix}',
      );
    }
    rescuerReplySubscription?.cancel();
    rescuerReplySubscription = null;
  }

  void setupRescuerSubscription() {
    if (!mqttConnected || !isRescuer) {
      return;
    }

    teardownRescuerSubscription();
    mqttService.subscribeTopic(
      AppConfig.mqttRescuerCommonTopic,
      qos: MqttQos.atLeastOnce,
    );

    rescuerSubscription = mqttService.messageStream?.listen((messages) async {
      for (final msg in messages) {
        try {
          if (msg.topic != AppConfig.mqttRescuerCommonTopic) {
            continue;
          }

          final recMsg = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMsg.payload.message,
          );
          final data = jsonDecode(payload) as Map<String, dynamic>;

          final type = (data['type'] ?? '').toString().toUpperCase();
          if (type == 'STOPPED') {
            service.invoke('onVictimStopped', {
              // Báo cho UI isolate rằng user X stopped
              'userId': (data['userId'] ?? '').toString(),
              'fullname': (data['fullname'] ?? '').toString(),
            });
            continue;
          }

          if (type == 'HANDLED') {
            // Báo cho UI isolate rằng X đã được handled.
            final handledBy = (data['handled_by'] ?? '').toString();
            service.invoke('onVictimHandled', {
              'userId': (data['userId'] ?? '').toString(),
              'handledBy': handledBy,
              'rescuerFullname': (data['rescuer_fullname'] ?? '').toString(),
            });
            continue;
          }

          final alertData = {
            'userId': (data['userId'] ?? '').toString(),
            'fullname': (data['fullname'] ?? '').toString(),
            'lat': (data['lat'] as num?)?.toDouble(),
            'long': (data['long'] as num?)?.toDouble(),
          };

          if (alertData['userId'] == '' ||
              alertData['lat'] == null ||
              alertData['long'] == null) {
            continue;
          }

          if (isUiActive) {
            service.invoke('onRescuerDistress', alertData);
          } else {
            await flutterLocalNotificationsPlugin.show(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: 'Distress Alert',
              body: 'A user needs rescue support right now.',
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  kDistressAlertChannelId,
                  AppConfig.distressAlertChannelName,
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  enableVibration: true,
                ),
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('📡 [BG] Failed to process rescuer/common payload: $e');
          }
        }
      }
    });
  }

  void setupRescuerReplySubscription() {
    // topic <userId>/rescuer-reply
    if (!mqttConnected || userId == null) {
      return;
    }

    teardownRescuerReplySubscription();
    final replyTopic = '${userId!}/${AppConfig.mqttRescuerReplySuffix}';
    mqttService.subscribeTopic(replyTopic, qos: MqttQos.atLeastOnce);

    rescuerReplySubscription = mqttService.messageStream?.listen((messages) {
      for (final msg in messages) {
        if (msg.topic != replyTopic) {
          continue;
        }

        try {
          final recMsg = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMsg.payload.message,
          );
          final data = jsonDecode(payload) as Map<String, dynamic>;

          service.invoke('onRescuerReply', {
            'rescuerFullname': (data['rescuer_fullname'] ?? '').toString(),
            'handledBy': (data['handled_by'] ?? '').toString(),
          });
        } catch (e) {
          if (kDebugMode) {
            print('📡 [BG] Failed to process rescuer reply payload: $e');
          }
        }
      }
    });
  }

  service.on('setUserId').listen((event) async {
    userId = event?['userId'] as String?;
    fullname = (event?['fullname'] ?? '').toString();
    if (userId != null && !mqttConnected) {
      mqttConnected = await mqttService.connect('${userId!}_bg');
      if (kDebugMode) {
        print('📡 [BG] MQTT connected for $userId: $mqttConnected');
      }
      setupRescuerSubscription();
      setupRescuerReplySubscription();
    }

    if (userId != null) {
      service.invoke('onUserIdBound', {'userId': userId});
    }
  });

  service.on('setSoSStatus').listen((event) {
    isSos = event?['isSoS'] == true;
  });

  service.on('setRescuerMode').listen((event) {
    isRescuer = event?['isRescuer'] == true;
    setupRescuerSubscription();
  });

  service.on('setUiIsActive').listen((event) {
    isUiActive = event?['isUiActive'] == true;
  });

  service.on('publishSignalCommand').listen((event) {
    if (!mqttConnected || event == null) {
      return;
    }

    final payload = jsonEncode(event);
    mqttService.publishRaw(
      topic: AppConfig.mqttSignalTopic,
      payload: payload,
      qos: MqttQos.atLeastOnce,
    );
  });

  service.on('publishRescuerHandleCommand').listen((event) {
    // Rescuer handles signal nào đó
    if (!mqttConnected || event == null) {
      return;
    }

    final payload = jsonEncode(event);
    mqttService.publishRaw(
      topic: AppConfig.mqttRescuerHandleTopic,
      payload: payload,
      qos: MqttQos.atLeastOnce,
    );
  });

  service.on('setAllowedFriends').listen((event) {
    if (event != null && event['friendIds'] != null) {
      allowedFriends = List<String>.from(event['friendIds']);
      if (kDebugMode) {
        print('📡 [BG] Allowed friends updated: $allowedFriends');
      }
    }
  });

  service.on('stopService').listen((_) {
    teardownRescuerSubscription();
    teardownRescuerReplySubscription();
    mqttService.disconnect();
    service.stopSelf();
  });

  Timer.periodic(Duration(seconds: AppConfig.locationPublishIntervalSeconds), (
    _,
  ) async {
    if (userId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mqttConnected) {
        final payload = jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
          'user': userId,
          'fullname': fullname,
          'allowed_friends': allowedFriends,
          'isSoS': isSos,
        });
        if (kDebugMode) {
          print(payload);
          print(AppConfig.mqttCurrentLocationSuffix);
        }
        mqttService.publishRaw(
          topic: AppConfig.mqttCurrentLocationSuffix,
          payload: payload,
          qos: MqttQos.atMostOnce,
        );
      }

      service.invoke('onLocationUpdate', {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: AppConfig.notificationTitle,
          content:
              '${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}',
        );
      }

      if (kDebugMode) {
        print('📍 [BG] (${position.latitude}, ${position.longitude})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📍 [BG] Poll error: $e');
      }
    }
  });
}

/// iOS background fetch handler (required by flutter_background_service).
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}
