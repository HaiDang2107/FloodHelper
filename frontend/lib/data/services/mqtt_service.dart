import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/app_config.dart';

/// Service for MQTT communication with EMQX Cloud broker
class MqttService {
  static MqttService? _instance;
  MqttServerClient? _client;
  bool _isConnected = false;

  MqttService._internal();

  factory MqttService() {
    _instance ??= MqttService._internal();
    return _instance!;
  }

  bool get isConnected => _isConnected;

  /// Connect to the MQTT broker
  Future<bool> connect(String userId) async {
    if (_isConnected && _client != null) {
      return true;
    }

    final clientId = '${AppConfig.mqttClientIdPrefix}$userId';

    _client = MqttServerClient.withPort(
      AppConfig.mqttBrokerUrl,
      clientId,
      AppConfig.mqttPort,
    );

    _client!.secure = AppConfig.mqttUseSsl;
    _client!.securityContext = SecurityContext.defaultContext;
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    _client!.logging(on: kDebugMode);

    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(AppConfig.mqttUsername, AppConfig.mqttPassword)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();

      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        if (kDebugMode) {
          print('📡 MQTT connected to ${AppConfig.mqttBrokerUrl}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('📡 MQTT connection failed: ${_client!.connectionStatus}');
        }
        _client!.disconnect();
        _isConnected = false;
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('📡 MQTT connection error: $e');
      }
      _client?.disconnect();
      _isConnected = false;
      return false;
    }
  }

  /// Publish user location to MQTT topic: location/<userId>
  void publishLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) {
    if (!_isConnected || _client == null) {
      if (kDebugMode) {
        print('📡 MQTT not connected, cannot publish location');
      }
      return;
    }

    final topic = '${AppConfig.mqttLocationTopicPrefix}/$userId';
    final payload = jsonEncode({
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    if (kDebugMode) {
      print('📡 Published location → $topic: ($latitude, $longitude)');
    }
  }

  /// Publish a pre-encoded payload to a topic
  /// Used by LocationTrackingService which encodes JSON in an isolate
  void publishRaw({
    required String topic,
    required String payload,
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
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    if (kDebugMode) {
      print('📡 Published → $topic');
    }
  }

  /// Subscribe to a location topic (for receiving other users' locations)
  void subscribeToLocation(String userId) {
    if (!_isConnected || _client == null) return;

    final topic = '${AppConfig.mqttLocationTopicPrefix}/$userId';
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    if (kDebugMode) {
      print('📡 Subscribed to $topic');
    }
  }

  /// Get stream of received messages
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get messageStream {
    return _client?.updates;
  }

  /// Disconnect from broker
  void disconnect() {
    if (_client != null) {
      _client!.disconnect();
      _isConnected = false;
      if (kDebugMode) {
        print('📡 MQTT disconnected');
      }
    }
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
