import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/app_config.dart';

/// Data class for friend location updates received via MQTT
class FriendLocationUpdate {
  final String friendId;
  final double latitude;
  final double longitude;

  const FriendLocationUpdate({
    required this.friendId,
    required this.latitude,
    required this.longitude,
  });
}

/// Service for MQTT communication with EMQX Cloud broker
/// Singleton managed by Riverpod (mqttServiceProvider with keepAlive: true)
class MqttService {
  MqttServerClient? _client;
  bool _isConnected = false;
  bool _isConnecting = false;

  MqttService();

  bool get isConnected => _isConnected;

  /// Connect to the MQTT broker
  Future<bool> connect(String userId) async {
    if (_isConnected && _client != null) {
      return true; // Trả về true luốn nếu đã kết nối rồi
    }

    if (_isConnecting) {
      if (kDebugMode) {
        print('📡 MQTT is connecting, skip duplicate connect request');
      }
      return false;
    }

    _isConnecting = true;

    final clientId = '${AppConfig.mqttClientIdPrefix}$userId';

    _client = MqttServerClient.withPort(
      AppConfig.mqttBrokerUrl,
      clientId,
      AppConfig.mqttPort,
    );

    _client!.setProtocolV311();

  // Cấu hình bảo mật và chứng chỉ SSL
    _client!.secure = AppConfig.mqttUseSsl;
    if (AppConfig.mqttUseSsl) {
      try {
        final caData = await rootBundle.load('assets/certs/emqxsl-ca.crt');
        final caBytes = caData.buffer.asUint8List();
        final securityContext = SecurityContext(withTrustedRoots: true);
        securityContext.setTrustedCertificatesBytes(caBytes);
        _client!.securityContext = securityContext;
      } catch (e) {
        if (kDebugMode) print('📡 Lỗi load CA: $e');
        _client!.securityContext = SecurityContext(withTrustedRoots: false);
        _client!.onBadCertificate = (X509Certificate cert) => true;
      }
    } else {
      _client!.securityContext = SecurityContext.defaultContext;
    }

    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    _client!.logging(on: kDebugMode);

    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;

    // Cấu hình gói tin connect

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(AppConfig.mqttUsername, AppConfig.mqttPassword)
        .startClean();

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();

      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        _isConnecting = false;
        if (kDebugMode) {
          print('📡 MQTT connected to ${AppConfig.mqttBrokerUrl}');
        }
        return true;
      } else {
        _isConnecting = false;
        if (kDebugMode) {
          print('📡 MQTT connection failed: ${_client!.connectionStatus}');
        }
        _client!.disconnect();
        _isConnected = false;
        return false;
      }
    } catch (e) {
      _isConnecting = false;
      if (kDebugMode) {
        print('📡 MQTT connection error: $e');
      }
      _client?.disconnect();
      _isConnected = false;
      return false;
    }
  }

  /// Publish a pre-encoded payload to a topic
  /// Used by LocationTrackingService which encodes JSON in an isolate
  void publishRaw({
    required String topic,
    required String payload,
    MqttQos qos = MqttQos.atLeastOnce,
  }) {
    if (!_isConnected || _client == null) {
      if (kDebugMode) {
        print('📡 MQTT not connected, cannot publish');
      }
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client!.publishMessage(
      topic,
      qos,
      builder.payload!,
    );

    if (kDebugMode) {
      print('📡 Published → $topic');
    }
  }

  // ==================== Friend Location Subscription ====================

  final _friendLocationController = StreamController<FriendLocationUpdate>.broadcast();

  /// Stream of friend location updates parsed from MQTT messages.
  Stream<FriendLocationUpdate> get friendLocationStream => _friendLocationController.stream;

  StreamSubscription? _mqttSubscription;

  // Topic: '{friendId}/to_{myUserId}/last-location'
  void subscribeFriendLocation(String friendId, String myUserId) {
    final topic = '$friendId/to_$myUserId/${AppConfig.mqttLastLocationSuffix}';
    subscribeTopic(topic, qos: MqttQos.atLeastOnce);

    if (kDebugMode) {
      print('📡 Subscribed to friend location: $topic');
    }
  }

  /// Unsubscribe from a friend's last-location topic.
  void unsubscribeFriendLocation(String friendId, String myUserId) {
    final topic = '$friendId/to_$myUserId/${AppConfig.mqttLastLocationSuffix}';
    unsubscribeTopic(topic);

    if (kDebugMode) {
      print('📡 Unsubscribed from friend location: $topic');
    }
  }

  /// Start listening MQTT messages and parsing friend location updates.
  /// Call once after connect. Parses topic to extract friendId.
  void startListeningFriendLocations(String myUserId) {
    _mqttSubscription?.cancel();
    _mqttSubscription = _client?.updates?.listen((messages) {
      for (final msg in messages) {
        try {
          final topic = msg.topic; // e.g. "<friendId>/to_<myId>/last-location"
          final recMsg = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMsg.payload.message,
          );

          // Parse friendId from topic: "<friendId>/to_<myId>/last-location"
          final suffix = '/to_$myUserId/${AppConfig.mqttLastLocationSuffix}';
          if (!topic.endsWith(suffix)) continue;

          final friendId = topic.substring(0, topic.length - suffix.length);
          final data = jsonDecode(payload) as Map<String, dynamic>;

          final update = FriendLocationUpdate(
            friendId: friendId,
            latitude: (data['lat'] as num).toDouble(),
            longitude: (data['lng'] as num).toDouble(),
          );

          _friendLocationController.add(update);

          if (kDebugMode) {
            print('📡 Friend location received: $friendId → (${update.latitude}, ${update.longitude})');
          }
        } catch (e) {
          if (kDebugMode) {
            print('📡 Error parsing MQTT message: $e');
          }
        }
      }
    });
  }

  /// Stop listening and close the friend location stream.
  void stopListeningFriendLocations() {
    _mqttSubscription?.cancel();
    _mqttSubscription = null;
  }

  /// Dispose MQTT friend location stream (call on service cleanup).
  void disposeFriendLocationStream() {
    stopListeningFriendLocations();
    _friendLocationController.close();
  }

  /// Get stream of received messages
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get messageStream {
    return _client?.updates;
  }

  /// Subscribe to any topic with configurable QoS.
  void subscribeTopic(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (!_isConnected || _client == null) return;
    _client!.subscribe(topic, qos);
  }

  /// Unsubscribe from any topic.
  void unsubscribeTopic(String topic) {
    if (!_isConnected || _client == null) return;
    _client!.unsubscribe(topic);
  }

  /// Disconnect from broker
  void disconnect() {
    if (_client != null) {
      _client!.disconnect();
      _isConnected = false;
      _isConnecting = false;
      if (kDebugMode) {
        print('📡 MQTT disconnected');
      }
    }
  }

  /// Dispose MQTT service (cleanup all resources)
  void dispose() {
    stopListeningFriendLocations();
    disconnect();
    _friendLocationController.close();
  }

  // ==================== Callbacks ====================

  void _onConnected() {
    _isConnected = true;
    if (kDebugMode) {
      print('📡 MQTT: onConnected');
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    if (kDebugMode) {
      print('📡 MQTT: onDisconnected');
    }
  }

  void _onAutoReconnect() {
    if (kDebugMode) {
      print('📡 MQTT: auto-reconnecting...');
    }
  }

  void _onAutoReconnected() {
    _isConnected = true;
    if (kDebugMode) {
      print('📡 MQTT: auto-reconnected');
    }
  }
}
