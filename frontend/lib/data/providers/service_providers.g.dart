// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiClientHash() => r'05eacc6dc3fa586c44e47dd0c1e5cf2b1ed1f36a';

/// ApiClient provider (keepAlive: true for shared HTTP client with persistent cookies)
/// Manages singleton Dio instance throughout app lifecycle.
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<ApiClient>;
String _$authServiceHash() => r'531c706e989c314a03bad7e03b6fd485bab3fdcb';

/// AuthService provider
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$userServiceHash() => r'dc646d1fcb12279c10badb1a04b81801f8ee33ee';

/// UserService provider
///
/// Copied from [userService].
@ProviderFor(userService)
final userServiceProvider = AutoDisposeProvider<UserService>.internal(
  userService,
  name: r'userServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserServiceRef = AutoDisposeProviderRef<UserService>;
String _$profileServiceHash() => r'c76cfd9164eb1ec241cdfc38de2c417b2c566d7c';

/// ProfileService provider
///
/// Copied from [profileService].
@ProviderFor(profileService)
final profileServiceProvider = AutoDisposeProvider<ProfileService>.internal(
  profileService,
  name: r'profileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileServiceRef = AutoDisposeProviderRef<ProfileService>;
String _$friendServiceHash() => r'b970d1e2eaa19be63175050bae094ed87b12356f';

/// FriendService provider
///
/// Copied from [friendService].
@ProviderFor(friendService)
final friendServiceProvider = AutoDisposeProvider<FriendService>.internal(
  friendService,
  name: r'friendServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendServiceRef = AutoDisposeProviderRef<FriendService>;
String _$authorityServiceHash() => r'0ecdb57cb3edac1adcde45e9c34d0f8ae8dee32e';

/// AuthorityService provider
///
/// Copied from [authorityService].
@ProviderFor(authorityService)
final authorityServiceProvider = AutoDisposeProvider<AuthorityService>.internal(
  authorityService,
  name: r'authorityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authorityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthorityServiceRef = AutoDisposeProviderRef<AuthorityService>;
String _$charityCampaignServiceHash() =>
    r'e45572f29f9ecd835fde58fcb6888662e526c44d';

/// CharityCampaignService provider
///
/// Copied from [charityCampaignService].
@ProviderFor(charityCampaignService)
final charityCampaignServiceProvider =
    AutoDisposeProvider<CharityCampaignService>.internal(
      charityCampaignService,
      name: r'charityCampaignServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$charityCampaignServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CharityCampaignServiceRef =
    AutoDisposeProviderRef<CharityCampaignService>;
String _$mqttServiceHash() => r'7515b490c05264ddb93f3ade8a50296583dea568';

/// MqttService provider (keepAlive: true for persistent MQTT connection)
/// Manages singleton instance and ensures proper cleanup on app shutdown.
///
/// Copied from [mqttService].
@ProviderFor(mqttService)
final mqttServiceProvider = Provider<MqttService>.internal(
  mqttService,
  name: r'mqttServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mqttServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MqttServiceRef = ProviderRef<MqttService>;
String _$firebaseMessagingServiceHash() =>
    r'578fbe0b5177a63a5213e033fd298262c2ac1fb1';

/// FirebaseMessagingService provider (keepAlive: true for FCM token management)
/// Manages singleton instance throughout app lifecycle.
///
/// Copied from [firebaseMessagingService].
@ProviderFor(firebaseMessagingService)
final firebaseMessagingServiceProvider =
    Provider<FirebaseMessagingService>.internal(
      firebaseMessagingService,
      name: r'firebaseMessagingServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firebaseMessagingServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseMessagingServiceRef = ProviderRef<FirebaseMessagingService>;
String _$locationTrackingServiceHash() =>
    r'f498097ff732a28df8fe9c741039edca89682724';

/// LocationTrackingService provider (keepAlive: true to persist background service)
/// Background GPS tracking and MQTT publishing must survive ViewModel dispose/rebuild.
///
/// Copied from [locationTrackingService].
@ProviderFor(locationTrackingService)
final locationTrackingServiceProvider =
    Provider<LocationTrackingService>.internal(
      locationTrackingService,
      name: r'locationTrackingServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationTrackingServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationTrackingServiceRef = ProviderRef<LocationTrackingService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
