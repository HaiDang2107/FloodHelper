// Domain model for Authentication Session
// Represents the current user's authentication state

import 'user.dart';

class AuthSession {
  final User user;
  final String accessToken;
  final String sessionId;
  final DateTime expiresAt;

  AuthSession({
    required this.user,
    required this.accessToken,
    required this.sessionId,
    required this.expiresAt,
  });

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is valid
  bool get isValid => !isExpired && accessToken.isNotEmpty;

  /// Time until expiration
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  /// Check if session should be refreshed (e.g., 5 minutes before expiry)
  bool get shouldRefresh {
    const refreshThreshold = Duration(minutes: 5);
    return timeUntilExpiry < refreshThreshold;
  }

  AuthSession copyWith({
    User? user,
    String? accessToken,
    String? sessionId,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      sessionId: sessionId ?? this.sessionId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'AuthSession(user: ${user.name}, sessionId: $sessionId, expiresAt: $expiresAt)';
  }
}

/// Authentication state for the app
enum AuthState {
  /// Initial state, checking stored credentials
  initial,
  
  /// User is authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// Authentication is in progress
  loading,
}
