import 'package:flutter/foundation.dart';
import '../models/auth_dto.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../services/auth_local_storage.dart';
import '../services/api_client.dart';
import '../../domain/models/user.dart';
import '../../domain/models/auth_session.dart';

/// Repository for authentication operations
/// Acts as a single source of truth for auth data
class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
      : _authService = authService;

  // ==================== Authentication ====================

  /// Sign in with username and password
  /// Returns AuthSession on success
  Future<AuthSession> signIn({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final request = SigninRequestDto(
      username: username,
      password: password,
      deviceId: deviceId,
    );

    final response = await _authService.signIn(request);

    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }

    final data = response.data!;

    await _persistSigninData(data, username: username);

    // Convert to domain model
    return _createAuthSession(data);
  }

  /// Sign in authority account with role validation on backend
  Future<AuthSession> signInAuthority({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final request = SigninRequestDto(
      username: username,
      password: password,
      deviceId: deviceId,
    );

    final response = await _authService.signInAuthority(request);

    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }

    final data = response.data!;
    await _persistSigninData(data, username: username);

    return _createAuthSession(data);
  }

  /// Sign up with user information
  /// Returns message on success (user needs to verify code)
  Future<String> signUp({
    required String fullname,
    required String phoneNumber,
    required String username,
    required String password,
    String? nickname,
    String? dob,
    String? dateOfIssue,
    String? dateOfExpire,
  }) async {
    final request = SignupRequestDto(
      fullname: fullname,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      nickname: nickname,
      dob: dob,
      dateOfIssue: dateOfIssue,
      dateOfExpire: dateOfExpire,
    );

    final response = await _authService.signUp(request);

    // Always return the message (no data payload from backend)
    return response.message;
  }

  /// Verify code (for signup or password reset)
  Future<VerifyCodeResponseDto> verifyCode({
    required String username,
    required String code,
    required VerificationType type,
  }) async {
    final request = VerifyCodeRequestDto(
      username: username,
      code: code,
      type: type.value,
    );

    return await _authService.verifyCode(request);
  }

  /// Resend verification code
  Future<void> resendCode({
    required String username,
    required VerificationType type,
  }) async {
    final request = ResendCodeRequestDto(
      username: username,
      type: type.value,
    );

    final response = await _authService.resendCode(request);

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  /// Sign out
  Future<void> signOut({bool logoutAll = false}) async {
    try {
      await _authService.signOut(logoutAll: logoutAll);
    } finally {
      // Always clear local data
      await AuthLocalStorage.clearAuthData();
      _authService.clearAuthToken();
    }
  }

  // ==================== Password Reset ====================

  /// Forgot password - request reset code
  Future<void> forgotPassword({required String username}) async {
    final request = ForgotPasswordRequestDto(username: username);
    final response = await _authService.forgotPassword(request);

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  /// Reset password with new password
  Future<void> resetPassword({
    required String newPassword,
    required String resetToken,
  }) async {
    final request = ResetPasswordRequestDto(newPassword: newPassword);
    final response = await _authService.resetPassword(request, resetToken);

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  // ==================== Token Management ====================

  /// Refresh access token
  /// Note: refresh_token is automatically sent via HTTP-only cookie by Dio CookieManager
  Future<void> refreshToken() async {
    final response = await _authService.refreshToken();

    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }

    final data = response.data!;

    // Update stored access token and expiry
    await AuthLocalStorage.saveAccessToken(data.tokens.accessToken);
    await AuthLocalStorage.saveTokenExpiry(
      DateTime.now().add(Duration(seconds: data.tokens.expiresIn)),
    );

    // Update API client
    _authService.setAuthToken(data.tokens.accessToken);
  }

  /// Try auto login using stored refresh token (in cookie)
  /// Returns AuthSession if successful, null otherwise
  Future<AuthSession?> tryAutoLogin() async {
    try {
      // Debug: Print cookies before calling refresh
      await ApiClient().debugPrintCookies(Uri.parse('http://192.168.88.106:3000/'));

      // Reuse repository refresh flow to persist new access token + expiry.
      await refreshToken();

      if (kDebugMode) {
        print('🔄 [tryAutoLogin] Token refreshed and persisted successfully');
      }

      // Refresh endpoint only returns token data; user/session are restored from local storage.
      return await getCurrentSession();
    } catch (e) {
      // Auto login failed - user needs to sign in manually
      return null;
    }
  }

  // ==================== Session Management ====================

  /// Get current session from local storage
  Future<AuthSession?> getCurrentSession() async {
    final isLoggedIn = await AuthLocalStorage.isLoggedIn();
    if (!isLoggedIn) return null;

    final accessToken = await AuthLocalStorage.getAccessToken();
    final sessionId = await AuthLocalStorage.getSessionId();
    final expiry = await AuthLocalStorage.getTokenExpiry();
    final userData = await AuthLocalStorage.getUserData();

    if (accessToken == null || sessionId == null || expiry == null || userData == null) {
      return null;
    }

    // Restore auth token in API client
    _authService.setAuthToken(accessToken);

    return AuthSession(
      user: _userFromMap(userData),
      accessToken: accessToken,
      sessionId: sessionId,
      expiresAt: expiry,
    );
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await AuthLocalStorage.isLoggedIn();
  }

  /// Syncs user data stored in local auth session after profile updates.
  Future<void> syncSessionUserFromProfile(ProfileModel profile) async {
    final existingUserData = await AuthLocalStorage.getUserData() ?? <String, dynamic>{};

    final updatedUserData = <String, dynamic>{
      ...existingUserData,
      'userId': profile.userId,
      'fullname': profile.fullname,
      'nickname': profile.nickname,
      'phoneNumber': profile.phoneNumber,
      'role': profile.roles,
      'avatarUrl': profile.avatarUrl,
      'originProvinceCode': profile.originProvinceCode,
      'originProvinceName': profile.originProvinceName,
      'originWardCode': profile.originWardCode,
      'originWardName': profile.originWardName,
      'residenceProvinceCode': profile.residenceProvinceCode,
      'residenceProvinceName': profile.residenceProvinceName,
      'residenceWardCode': profile.residenceWardCode,
      'residenceWardName': profile.residenceWardName,
      'showCharityCampaignLocations': profile.showCharityCampaignLocations,
    };

    await AuthLocalStorage.saveUserData(updatedUserData);
  }

  /// Sync a single display preference to locally persisted auth session user data.
  Future<void> syncSessionShowCharityCampaignLocations(bool value) async {
    final existingUserData = await AuthLocalStorage.getUserData();
    if (existingUserData == null) {
      return;
    }

    await AuthLocalStorage.saveUserData({
      ...existingUserData,
      'showCharityCampaignLocations': value,
    });
  }

  // ==================== Private Helpers ====================

  Future<void> _persistSigninData(
    SigninDataDto data, {
    required String username,
  }) async {
    // refresh_token is managed by backend via HTTP-only cookies
    await AuthLocalStorage.saveAuthData(
      accessToken: data.tokens.accessToken,
      expiresIn: data.tokens.expiresIn,
      sessionId: data.session.sessionId,
      userData: {
        'userId': data.user.userId,
        'fullname': data.user.name,
        'nickname': data.user.displayName,
        'phoneNumber': data.user.phoneNumber,
        'role': data.user.role,
        'avatarUrl': data.user.avatarUrl,
        'username': username,
        'gender': data.user.gender,
        'dob': data.user.dob,
        'originProvinceCode': data.user.originProvinceCode,
        'originProvinceName': data.user.originProvinceName,
        'originWardCode': data.user.originWardCode,
        'originWardName': data.user.originWardName,
        'residenceProvinceCode': data.user.residenceProvinceCode,
        'residenceProvinceName': data.user.residenceProvinceName,
        'residenceWardCode': data.user.residenceWardCode,
        'residenceWardName': data.user.residenceWardName,
        'dateOfIssue': data.user.dateOfIssue,
        'dateOfExpire': data.user.dateOfExpire,
        'citizenId': data.user.citizenId,
        'citizenIdCardImg': data.user.citizenIdCardImg,
        'jobPosition': data.user.jobPosition,
        'visibilityMode': data.user.visibilityMode,
        'showCharityCampaignLocations':
            data.user.showCharityCampaignLocations ?? false,
      },
    );

    _authService.setAuthToken(data.tokens.accessToken);
  }

  AuthSession _createAuthSession(SigninDataDto data) {
    return AuthSession(
      user: User(
        id: data.user.userId,
        name: data.user.name,
        displayName: data.user.displayName,
        phoneNumber: data.user.phoneNumber,
        roles: data.user.role.map((r) => UserRole.fromString(r)).toList(),
        avatarUrl: data.user.avatarUrl,
        showCharityCampaignLocations:
            data.user.showCharityCampaignLocations ?? false,
      ),
      accessToken: data.tokens.accessToken,
      sessionId: data.session.sessionId,
      expiresAt: data.session.expireAt,
    );
  }

  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['userId'] ?? '',
      name: map['fullname'] ?? map['name'] ?? '',
      displayName: map['nickname'] ?? map['displayName'],
      phoneNumber: map['phoneNumber'],
      roles: (map['role'] as List<dynamic>?)
              ?.map((r) => UserRole.fromString(r.toString()))
              .toList() ??
          [UserRole.normalUser],
      avatarUrl: map['avatarUrl'],
      showCharityCampaignLocations:
          map['showCharityCampaignLocations'] as bool? ?? false,
    );
  }
}

/// Verification type enum
enum VerificationType {
  signup('CREATE_ACCOUNT'),
  forgotPassword('RESET_PASSWORD');

  final String value;
  const VerificationType(this.value);
}
