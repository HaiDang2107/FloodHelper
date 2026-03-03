import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 [BG] Message received: ${message.messageId}');
    print('🔔 [BG] Data: ${message.data}');
  }
}

/// Service for handling Firebase Cloud Messaging
class FirebaseMessagingService {
  static FirebaseMessagingService? _instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    _instance ??= FirebaseMessagingService._internal();
    return _instance!;
  }

  /// Initialize Firebase Messaging and request permissions
  Future<String?> initialize() async {
    // Request permission (required for iOS, optional for Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('🔔 FCM permission status: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('🔔 FCM Token: $token');
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('🔔 FCM Token refreshed: $newToken');
        }
        _sendTokenToServer(newToken);
      });

      return token;
    }

    return null;
  }

  /// Send FCM token to the backend
  Future<void> _sendTokenToServer(String token) async {
    try {
      await ApiClient().patch(
        '/friend/fcm-token',
        data: {'fcmToken': token},
      );
    } catch (e) {
      if (kDebugMode) {
        print('🔔 Failed to send FCM token to server: $e');
      }
    }
  }

  /// Register FCM token with the backend (call after login)
  Future<void> registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
  }

  /// Set up foreground message handler
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Set up message opened handler (when user taps notification)
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Check if app was opened from a notification
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }
}
