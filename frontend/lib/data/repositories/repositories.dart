/// Barrel file for data/repositories
export 'auth_repository.dart';

// Abstract repositories
export 'user_repository.dart';
export 'post_repository.dart';
export 'announcement_repository.dart';
export 'profile_repository.dart';
export 'friend_repository.dart';

// Mock implementations
export 'mock/mock_user_repository.dart';
export 'mock/mock_post_repository.dart';
export 'mock/mock_announcement_repository.dart';
export 'mock/mock_profile_repository.dart';

// Real implementations
export 'real/real_profile_repository.dart';
export 'real/real_friend_repository.dart';
