import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'api_client.dart';
import '../../firebase_options.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!DefaultFirebaseOptions.isSupportedPlatform) return;

  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (kDebugMode) {
    print('🔔 [BG] Message received: ${message.messageId}');
    print('🔔 [BG] Data: ${message.data}');
  }
}

/// Service for handling Firebase Cloud Messaging
/// Singleton managed by Riverpod (firebaseMessagingServiceProvider with keepAlive: true)
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  FirebaseMessagingService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Initialize Firebase Messaging and request permissions
  Future<String?> initialize() async {
    if (!DefaultFirebaseOptions.isSupportedPlatform) {
      return null;
    }

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
      await _apiClient.patch(
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
    if (!DefaultFirebaseOptions.isSupportedPlatform) return;

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
