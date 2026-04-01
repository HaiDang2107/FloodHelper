import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;

import '../../domain/models/user.dart';
import '../../domain/models/auth_session.dart';
import 'repository_providers.dart';
import 'service_providers.dart';
import '../services/sos_local_storage.dart';

part 'global_session_provider.g.dart';

/// Provider for current auth session
/// Manages authentication state (login, logout, refresh)
@Riverpod(keepAlive: true)
class GlobalSessionManager extends _$GlobalSessionManager {
  @override
  FutureOr<AuthSession?> build() async {
    return await _init();
  }

  /// Initialize - check for existing session
  Future<AuthSession?> _init() async {
    final authRepository = ref.watch(authRepositoryProvider);
    return await authRepository.getCurrentSession(); // trả về session thông qua một hàm trong AuthRepository
  }

  /// Sign in
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final deviceId = await _getDeviceId();
      final session = await authRepository.signIn(
        username: username,
        password: password,
        deviceId: deviceId,
      );
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Set session directly (used for auto login)
  void setSession(AuthSession session) {
    state = AsyncValue.data(session);
  }

  /// Sign out
  Future<void> signOut({bool logoutAll = false}) async {
    final userId = state.valueOrNull?.user.id;

    try {
      // 1. Stop background location tracking & MQTT
      await ref.read(locationTrackingServiceProvider).stop();
      ref.read(mqttServiceProvider).disconnect();

      // 2. Call backend logout
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut(logoutAll: logoutAll);
    } finally {
      if (userId != null && userId.isNotEmpty) {
        await SosLocalStorage.clearBroadcastingState(userId);
      }
      state = const AsyncValue.data(null);
    }
  }

  /// Refresh session
  Future<void> refresh() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.refreshToken();
      final session = await authRepository.getCurrentSession();
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Get device ID for authentication
  Future<String> _getDeviceId() async {
    if (kIsWeb) {
      return 'web_device';
    }
    
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    } else {
      return 'unknown_device';
    }
  }
}

/// Provider for checking if user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  final session = ref.watch(globalSessionManagerProvider);
  return session.valueOrNull != null;
}

/// Provider for current user
@riverpod
User? currentUser(Ref ref) {
  final session = ref.watch(globalSessionManagerProvider);
  return session.valueOrNull?.user;
}
