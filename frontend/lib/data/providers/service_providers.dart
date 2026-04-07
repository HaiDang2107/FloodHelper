import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;

import '../services/services.dart';

part 'service_providers.g.dart';

// =============================================================================
// CENTRALIZED SERVICE PROVIDERS
// =============================================================================
// All services are created here to ensure single instances across the app.
// Repositories and ViewModels should obtain services via these providers.
// =============================================================================

/// ApiClient provider (keepAlive: true for shared HTTP client with persistent cookies)
/// Manages singleton Dio instance throughout app lifecycle.
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

/// AuthService provider
@riverpod
AuthService authService(Ref ref) {
  return AuthService(apiClient: ref.watch(apiClientProvider));
}

/// UserService provider
@riverpod
UserService userService(Ref ref) {
  return UserService(apiClient: ref.watch(apiClientProvider));
}

/// ProfileService provider
@riverpod
ProfileService profileService(Ref ref) {
  return ProfileService(apiClient: ref.watch(apiClientProvider));
}

/// FriendService provider
@riverpod
FriendService friendService(Ref ref) {
  return FriendService(apiClient: ref.watch(apiClientProvider));
}

/// AuthorityService provider
@riverpod
AuthorityService authorityService(Ref ref) {
  return AuthorityService(apiClient: ref.watch(apiClientProvider));
}

/// CharityCampaignService provider
@riverpod
CharityCampaignService charityCampaignService(Ref ref) {
  return CharityCampaignService(apiClient: ref.watch(apiClientProvider));
}

/// MqttService provider (keepAlive: true for persistent MQTT connection)
/// Manages singleton instance and ensures proper cleanup on app shutdown.
@Riverpod(keepAlive: true)
MqttService mqttService(Ref ref) {
  final service = MqttService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// FirebaseMessagingService provider (keepAlive: true for FCM token management)
/// Manages singleton instance throughout app lifecycle.
@Riverpod(keepAlive: true)
FirebaseMessagingService firebaseMessagingService(Ref ref) {
  return FirebaseMessagingService(apiClient: ref.watch(apiClientProvider));
}

/// LocationTrackingService provider (keepAlive: true to persist background service)
/// Background GPS tracking and MQTT publishing must survive ViewModel dispose/rebuild.
@Riverpod(keepAlive: true)
LocationTrackingService locationTrackingService(Ref ref) {
  final service = LocationTrackingService();
  ref.onDispose(() => service.dispose());
  return service;
}
