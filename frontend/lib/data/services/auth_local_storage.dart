import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing authentication data
/// Uses SharedPreferences for simple, non-encrypted storage
/// Note: Access tokens have short lifespan, sensitive refresh_token is in HTTP-only cookie
class AuthLocalStorage {
  // Storage keys
  static const _accessTokenKey = 'access_token';
  // Note: refresh_token is stored in HTTP-only cookie by backend, not in local storage
  static const _sessionIdKey = 'session_id';
  static const _tokenExpiryKey = 'token_expiry';
  static const _userDataKey = 'user_data';

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ==================== Token Management ====================

  /// Save access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, token);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  /// Save token expiry time
  static Future<void> saveTokenExpiry(DateTime expiry) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await _prefs;
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      return DateTime.tryParse(expiryStr);
    }
    return null;
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  // ==================== Session Management ====================

  /// Save session ID
  static Future<void> saveSessionId(String sessionId) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionIdKey, sessionId);
  }

  /// Get session ID
  static Future<String?> getSessionId() async {
    final prefs = await _prefs;
    return prefs.getString(_sessionIdKey);
  }

  // ==================== User Data Management ====================

  /// Save user data as JSON
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs;
    final userStr = prefs.getString(_userDataKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  // ==================== Combined Operations ====================

  /// Save all auth data from sign in response
  /// Note: refresh_token is managed by backend via HTTP-only cookies
  static Future<void> saveAuthData({
    required String accessToken,
    required int expiresIn,
    required String sessionId,
    required Map<String, dynamic> userData,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveTokenExpiry(DateTime.now().add(Duration(seconds: expiresIn))),
      saveSessionId(sessionId),
      saveUserData(userData),
    ]);
  }

  /// Clear all auth data
  /// Note: refresh_token cookie will be cleared by backend on signout
  static Future<void> clearAuthData() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_sessionIdKey),
      prefs.remove(_tokenExpiryKey),
      prefs.remove(_userDataKey),
    ]);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    final isExpired = await isTokenExpired();
    return !isExpired;
  }
}
