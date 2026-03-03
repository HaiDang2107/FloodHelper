import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;

import '../models/auth_dto.dart';
import '../repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../../domain/models/auth_session.dart';

part 'auth_provider.g.dart';

/// Provider for AuthRepository
// state là thuộc tính lớp cha
// AsyncValue: giúp hiển thị trạng thái lớp 
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

/// Provider for current auth session
@riverpod
class AuthSessionNotifier extends _$AuthSessionNotifier {
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
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut(logoutAll: logoutAll);
    } finally {
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
  final session = ref.watch(authSessionNotifierProvider);
  return session.valueOrNull != null;
}

/// Provider for current user
@riverpod
User? currentUser(Ref ref) {
  final session = ref.watch(authSessionNotifierProvider);
  return session.valueOrNull?.user;
}

/// Sign up a new user
@riverpod
Future<String> signUp(Ref ref, {
  required String fullName,
  required String phoneNumber,
  required String username,
  required String password,
  String? displayName,
  String? dob,
  String? village,
  String? district,
  String? country,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.signUp(
    name: fullName,
    phoneNumber: phoneNumber,
    username: username,
    password: password,
    displayName: displayName,
    dob: dob,
    village: village,
    district: district,
    country: country,
  );
}

/// Verify code
@riverpod
Future<VerifyCodeResponseDto> verifyCode(Ref ref, {
  required String username,
  required String code,
  required VerificationType type,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.verifyCode(
    username: username,
    code: code,
    type: type,
  );
}

/// Forgot password - send reset code
@riverpod
Future<void> forgotPassword(Ref ref, {
  required String username,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.forgotPassword(username: username);
}

/// Resend verification code
@riverpod
Future<void> resendCode(Ref ref, {
  required String username,
  required VerificationType type,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.resendCode(
    username: username,
    type: type,
  );
}
