import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import '../../firebase_options.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // xử lý các thông báo (hoặc dữ liệu ngầm) được gửi từ Firebase khi ứng dụng của bạn đang KHÔNG mở trên màn hình
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo an toàn (tránh lỗi duplicate app)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (kDebugMode) {
    debugPrint('🔔 [BG] Message received: ${message.messageId}');
  }
}

/// Service for handling Firebase Cloud Messaging
/// Singleton managed by Riverpod (firebaseMessagingServiceProvider with keepAlive: true)
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  // Khởi tạo thư viện Local Notifications
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Khai báo key để lưu local
  static const String _tokenCacheKey = 'fcm_device_token';

  FirebaseMessagingService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Initialize Firebase Messaging and request permissions
  Future<String?> initialize() async {
    try {
      // 0. Tạo các Channel cho Android TRƯỚC KHI xin quyền FCM
      await _setupAndroidNotificationChannels();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
            
        // 1. Lấy token mới nhất
        final token = await _messaging.getToken();
        if (token != null) {
          await _sendTokenToServerIfNeeded(token);
        }

        // 2. Lắng nghe nếu token bị thay đổi ngầm
        _messaging.onTokenRefresh.listen((newToken) {
          if (kDebugMode) debugPrint('🔔 FCM Token refreshed: $newToken');
          // Nếu bị đổi ngầm, ép buộc (force) gửi lên server
          _sendTokenToServerIfNeeded(newToken, force: true);
        });

        return token;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 Lỗi khởi tạo FCM: $e');
    }
    return null;
  }

  /// Hàm tạo cấu hình Channel cho Android
  Future<void> _setupAndroidNotificationChannels() async {
    // Không cần chạy trên Web hoặc iOS
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    // Kênh 1: Lời mời kết bạn (Bình thường)
    const AndroidNotificationChannel friendRequestChannel = AndroidNotificationChannel(
      'friend_requests', // ID phải KHỚP 100% với chuỗi gửi từ NestJS
      'Lời mời kết bạn',  // Tên hiển thị trong mục Cài đặt của Android
      description: 'Thông báo khi có người muốn kết bạn với bạn',
      importance: Importance.high,
    );

    // Đăng ký các kênh này với hệ điều hành
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(friendRequestChannel);
  }

  /// Gửi Token lên Backend có cơ chế Cache
  Future<void> _sendTokenToServerIfNeeded(String token, {bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedToken = prefs.getString(_tokenCacheKey);

      // CHỈ GỌI API NẾU: bị ép buộc (force) HOẶC token đã bị đổi
      if (force || cachedToken != token) {
        await _apiClient.patch(
          '/friend/fcm-token',
          data: {'fcmToken': token},
        );
        
        // Lưu lại để lần sau mở app không gửi trùng nữa
        await prefs.setString(_tokenCacheKey, token);
        if (kDebugMode) debugPrint('🔔 Đã đồng bộ Token mới lên Backend');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 Lỗi gửi FCM token lên server: $e');
    }
  }

  /// Gọi khi User đăng nhập thành công
  Future<void> registerToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      // Force = true vì đăng nhập tk mới cần ghi đè DB ngay lập tức
      await _sendTokenToServerIfNeeded(token, force: true); 
    }
  }

  /// THÊM MỚI: Gọi khi User bấm Đăng xuất
  Future<void> deleteToken() async {
    try {
      // Xóa token trên Firebase (buộc Firebase sinh token mới cho thiết bị)
      await _messaging.deleteToken();
      
      // Xóa cache local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenCacheKey);
      
      if (kDebugMode) debugPrint('🔔 Đã xóa sạch Token cũ khi đăng xuất');
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 Lỗi xóa FCM token: $e');
    }
  }

  /// Set up foreground message handler (xử lý khi còn đang online)
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Set up message opened handler (when user taps notification) (xứ lý khi app ở nền)
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Check if app was opened from a notification
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }
}