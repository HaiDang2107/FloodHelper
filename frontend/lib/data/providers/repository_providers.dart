import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;

import '../repositories/repositories.dart';
import 'service_providers.dart';

part 'repository_providers.g.dart';

/// Configuration for switching between mock and real data
/// Set to false when connecting to real backend
const bool useMockData = false;

// =============================================================================
// REPOSITORY PROVIDERS
// =============================================================================

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(authService: ref.read(authServiceProvider));
}

/// Provider for UserRepository
/// Automatically switches between mock and real implementation
@riverpod
UserRepository userRepository(Ref ref) {
  if (useMockData) {
    return MockUserRepository();
  }
  return RealUserRepository(
    userService: ref.read(userServiceProvider),
    friendService: ref.read(friendServiceProvider),
  );
}

/// Provider for PostRepository
/// Automatically switches between mock and real implementation
@riverpod
PostRepository postRepository(Ref ref) {
  if (useMockData) {
    return MockPostRepository();
  }
  // TODO: Return real implementation when backend is ready
  // return RealPostRepository(ref.read(dioProvider));
  return MockPostRepository();
}

/// Provider for AnnouncementRepository
/// Automatically switches between mock and real implementation
@riverpod
AnnouncementRepository announcementRepository(Ref ref) {
  if (useMockData) {
    return MockAnnouncementRepository();
  }
  // TODO: Return real implementation when backend is ready
  // return RealAnnouncementRepository(ref.read(dioProvider));
  return MockAnnouncementRepository();
}

/// Provider for ProfileRepository
/// Automatically switches between mock and real implementation
@riverpod
ProfileRepository profileRepository(Ref ref) {
  if (useMockData) {
    return MockProfileRepository();
  }
  return RealProfileRepository(
    profileService: ref.read(profileServiceProvider),
  );
}

/// Provider for FriendRepository
@riverpod
FriendRepository friendRepository(Ref ref) {
  return RealFriendRepository(
    friendService: ref.read(friendServiceProvider),
  );
}

/// Provider for CharityCampaignRepository
@riverpod
CharityCampaignRepository charityCampaignRepository(Ref ref) {
  if (useMockData) {
    return MockCharityCampaignRepository();
  }

  // TODO: Replace with real repository implementation when backend endpoints are ready.
  return MockCharityCampaignRepository();
}
