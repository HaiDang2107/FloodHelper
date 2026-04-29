import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/providers/service_providers.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Đảm bảo Core của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Khởi tạo Firebase (Nên bọc try-catch để an toàn đa nền tảng)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // BẮT BUỘC: firebaseMessagingBackgroundHandler phải có @pragma('vm:entry-point')
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('🔥 Khởi tạo Firebase thất bại: $e');
  }
  
  // 3. Khởi tạo Riverpod Container
  final container = ProviderContainer();
  
  // 4. Khởi tạo ApiClient an toàn (Không làm chết app nếu lỗi)
  try {
    await container.read(apiClientProvider).init();
  } catch (e) {
    debugPrint('⚠️ Khởi tạo ApiClient thất bại: $e');
    // Vẫn tiếp tục chạy app, xử lý lỗi văng màn hình đăng nhập ở bên trong UI sau
  }
  
  // 5. Chạy ứng dụng
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // 6. Khởi tạo Location Service ngầm "SAU KHI UI ĐÃ MOUNT" thực sự
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Logic bên trong này chắc chắn chạy sau khi Frame đầu tiên của MyApp đã được vẽ
      unawaited(
        container.read(locationTrackingServiceProvider).initialize().catchError((e) {
          debugPrint('📍 Background service initialize failed: $e');
        }),
      );
    });
  }
}