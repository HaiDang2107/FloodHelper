import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:antiflood/features/auth/services/auth_api_service.dart';
import 'package:antiflood/features/auth/models/auth_dtos.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static AuthApiService? _authApiService;

  // Initialize with AuthApiService for token refresh
  static void initialize(AuthApiService authApiService) {
    _authApiService = authApiService;
  }

  // Keys for storage
  static const _accessTokenKey = 'access_token';
  static const _userDataKey = 'user_data';
  static const _sessionIdKey = 'session_id';
  static const _tokenExpiryKey = 'token_expiry';

  // Save authentication data after successful sign in
  static Future<void> saveAuthData(Map<String, dynamic> response) async {
    try {
      final data = response['data'];
      if (data == null) return;

      final tokens = data['tokens'];
      final user = data['user'];
      final session = data['session'];

      if (tokens != null) {
        // Save access token
        final accessToken = tokens['accessToken'];
        if (accessToken != null) {
          await _storage.write(key: _accessTokenKey, value: accessToken.toString());
        }

        // Save token expiry (current time + expiresIn seconds)
        final expiresIn = tokens['expiresIn'];
        if (expiresIn != null) {
          final expiryTime = DateTime.now().add(Duration(seconds: expiresIn as int));
          await _storage.write(key: _tokenExpiryKey, value: expiryTime.toIso8601String());
        }
      }

      // Save user data
      if (user != null) {
        await _storage.write(key: _userDataKey, value: user.toString());
      }

      // Save session ID
      if (session != null) {
        final sessionId = session['sessionId'];
        if (sessionId != null) {
          await _storage.write(key: _sessionIdKey, value: sessionId.toString());
        }
      }
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  // Refresh access token using refresh token from cookie
  static Future<bool> refreshAccessToken() async {
    try {
      if (_authApiService == null) return false;

      // Create refresh token DTO (empty since refresh token is in cookie)
      final refreshDto = RefreshTokenDto(refreshToken: '');

      final response = await _authApiService!.refreshToken(refreshDto);
      await saveAuthData(response);

      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Get stored access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Get stored user data
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  // Get stored session ID
  static Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString == null) return true;

    final expiryTime = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiryTime);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;

    return !(await isTokenExpired());
  }

  // Clear all authentication data (logout)
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _sessionIdKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  // Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    return expiryString != null ? DateTime.parse(expiryString) : null;
  }
}