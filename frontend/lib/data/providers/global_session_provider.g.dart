// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAuthenticatedHash() => r'3a1d49fce33af69800545afe053e3971c5f14440';

/// Provider for checking if user is authenticated
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentUserHash() => r'6440f442a5c7777588cf73593a1cbe99690a7103';

/// Provider for current user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$globalSessionManagerHash() =>
    r'52e79dd807937f28334a743a82d6ce563eca9dad';

/// Provider for current auth session
/// Manages authentication state (login, logout, refresh)
///
/// Copied from [GlobalSessionManager].
@ProviderFor(GlobalSessionManager)
final globalSessionManagerProvider =
    AsyncNotifierProvider<GlobalSessionManager, AuthSession?>.internal(
      GlobalSessionManager.new,
      name: r'globalSessionManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$globalSessionManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GlobalSessionManager = AsyncNotifier<AuthSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
