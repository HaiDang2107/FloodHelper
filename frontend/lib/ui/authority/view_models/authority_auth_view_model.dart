import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/repository_providers.dart';
import 'authority_session_view_model.dart';

part 'authority_auth_view_model.g.dart';

class AuthorityAuthState {
  const AuthorityAuthState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  AuthorityAuthState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthorityAuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class AuthorityAuthViewModel extends _$AuthorityAuthViewModel {
  @override
  AuthorityAuthState build() {
    return const AuthorityAuthState();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<void> signIn() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter email and password.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final deviceId = await _getDeviceId();
      await authRepository.signInAuthority(
        username: state.email,
        password: state.password,
        deviceId: deviceId,
      );
      ref.read(authoritySessionProvider.notifier).signIn();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<String> _getDeviceId() async {
    if (kIsWeb) {
      return 'web_device';
    }

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }

    return 'unknown_device';
  }
}
