import '../models/auth_dto.dart';
import '../services/auth_service.dart';
import '../services/auth_local_storage.dart';
import '../services/api_client.dart';
import '../../domain/models/user.dart';
import '../../domain/models/auth_session.dart';

/// Repository for authentication operations
/// Acts as a single source of truth for auth data
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

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

    // Save auth data to local storage
    // Note: refresh_token is managed by backend via HTTP-only cookies
    await AuthLocalStorage.saveAuthData(
      accessToken: data.tokens.accessToken,
      expiresIn: data.tokens.expiresIn,
      sessionId: data.session.sessionId,
      userData: {
        'userId': data.user.userId,
        'name': data.user.name,
        'displayName': data.user.displayName,
        'phoneNumber': data.user.phoneNumber,
        'role': data.user.role,
        'avatarUrl': data.user.avatarUrl,
      },
    );

    // Set auth token for API client
    _authService.setAuthToken(data.tokens.accessToken);

    // Convert to domain model
    return _createAuthSession(data);
  }

  /// Sign up with user information
  /// Returns message on success (user needs to verify code)
  Future<String> signUp({
    required String name,
    required String phoneNumber,
    required String username,
    required String password,
    String? displayName,
    String? dob,
    String? village,
    String? district,
    String? country,
  }) async {
    final request = SignupRequestDto(
      name: name,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      displayName: displayName,
      dob: dob,
      village: village,
      district: district,
      country: country,
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
      
      // Call refresh token endpoint - Dio CookieManager will automatically send refresh_token cookie
      final response = await _authService.refreshToken();

      print('🔄 [tryAutoLogin] Response: success=${response.success}, message=${response.message}');

      if (!response.success || response.data == null) {
        return null;
      }

      final data = response.data!;
      
      // Check if we have user data (required for auto login)
      if (data.user == null || data.session == null) {
        return null;
      }

      // Save auth data to local storage
      await AuthLocalStorage.saveAuthData(
        accessToken: data.tokens.accessToken,
        expiresIn: data.tokens.expiresIn,
        sessionId: data.session!.sessionId,
        userData: {
          'userId': data.user!.userId,
          'name': data.user!.name,
          'displayName': data.user!.displayName,
          'phoneNumber': data.user!.phoneNumber,
          'role': data.user!.role,
          'avatarUrl': data.user!.avatarUrl,
        },
      );

      // Set auth token for API client
      _authService.setAuthToken(data.tokens.accessToken);

      // Create and return auth session
      return AuthSession(
        user: User(
          id: data.user!.userId,
          name: data.user!.name,
          displayName: data.user!.displayName,
          phoneNumber: data.user!.phoneNumber,
          roles: [UserRole.fromString(data.user!.role)],
          avatarUrl: data.user!.avatarUrl,
        ),
        accessToken: data.tokens.accessToken,
        sessionId: data.session!.sessionId,
        expiresAt: DateTime.now().add(Duration(seconds: data.tokens.expiresIn)),
      );
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

  // ==================== Private Helpers ====================

  AuthSession _createAuthSession(SigninDataDto data) {
    return AuthSession(
      user: User(
        id: data.user.userId,
        name: data.user.name,
        displayName: data.user.displayName,
        phoneNumber: data.user.phoneNumber,
        roles: data.user.role.map((r) => UserRole.fromString(r)).toList(),
        avatarUrl: data.user.avatarUrl,
      ),
      accessToken: data.tokens.accessToken,
      sessionId: data.session.sessionId,
      expiresAt: data.session.expireAt,
    );
  }

  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['userId'] ?? '',
      name: map['name'] ?? '',
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      roles: (map['role'] as List<dynamic>?)
              ?.map((r) => UserRole.fromString(r.toString()))
              .toList() ??
          [UserRole.normalUser],
      avatarUrl: map['avatarUrl'],
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
