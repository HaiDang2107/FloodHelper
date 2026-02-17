// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'19a3485653561ac2f781b997131430c5659286d1';

/// Provider for AuthRepository
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$isAuthenticatedHash() => r'7b26a69711eb9b83c31ef341a336bef69fb2d73c';

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
String _$currentUserHash() => r'75188080430641c351370418db77acc86b6c324b';

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
String _$signUpHash() => r'efda05972126a8d820df53084eafacf556644cdc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Sign up a new user
///
/// Copied from [signUp].
@ProviderFor(signUp)
const signUpProvider = SignUpFamily();

/// Sign up a new user
///
/// Copied from [signUp].
class SignUpFamily extends Family<AsyncValue<String>> {
  /// Sign up a new user
  ///
  /// Copied from [signUp].
  const SignUpFamily();

  /// Sign up a new user
  ///
  /// Copied from [signUp].
  SignUpProvider call({
    required String fullName,
    required String phoneNumber,
    required String username,
    required String password,
    String? displayName,
    String? dob,
    String? village,
    String? district,
    String? country,
  }) {
    return SignUpProvider(
      fullName: fullName,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      displayName: displayName,
      dob: dob,
      village: village,
      district: district,
      country: country,
    );
  }

  @override
  SignUpProvider getProviderOverride(covariant SignUpProvider provider) {
    return call(
      fullName: provider.fullName,
      phoneNumber: provider.phoneNumber,
      username: provider.username,
      password: provider.password,
      displayName: provider.displayName,
      dob: provider.dob,
      village: provider.village,
      district: provider.district,
      country: provider.country,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'signUpProvider';
}

/// Sign up a new user
///
/// Copied from [signUp].
class SignUpProvider extends AutoDisposeFutureProvider<String> {
  /// Sign up a new user
  ///
  /// Copied from [signUp].
  SignUpProvider({
    required String fullName,
    required String phoneNumber,
    required String username,
    required String password,
    String? displayName,
    String? dob,
    String? village,
    String? district,
    String? country,
  }) : this._internal(
         (ref) => signUp(
           ref as SignUpRef,
           fullName: fullName,
           phoneNumber: phoneNumber,
           username: username,
           password: password,
           displayName: displayName,
           dob: dob,
           village: village,
           district: district,
           country: country,
         ),
         from: signUpProvider,
         name: r'signUpProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$signUpHash,
         dependencies: SignUpFamily._dependencies,
         allTransitiveDependencies: SignUpFamily._allTransitiveDependencies,
         fullName: fullName,
         phoneNumber: phoneNumber,
         username: username,
         password: password,
         displayName: displayName,
         dob: dob,
         village: village,
         district: district,
         country: country,
       );

  SignUpProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fullName,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.displayName,
    required this.dob,
    required this.village,
    required this.district,
    required this.country,
  }) : super.internal();

  final String fullName;
  final String phoneNumber;
  final String username;
  final String password;
  final String? displayName;
  final String? dob;
  final String? village;
  final String? district;
  final String? country;

  @override
  Override overrideWith(FutureOr<String> Function(SignUpRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: SignUpProvider._internal(
        (ref) => create(ref as SignUpRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fullName: fullName,
        phoneNumber: phoneNumber,
        username: username,
        password: password,
        displayName: displayName,
        dob: dob,
        village: village,
        district: district,
        country: country,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _SignUpProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignUpProvider &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.username == username &&
        other.password == password &&
        other.displayName == displayName &&
        other.dob == dob &&
        other.village == village &&
        other.district == district &&
        other.country == country;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fullName.hashCode);
    hash = _SystemHash.combine(hash, phoneNumber.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);
    hash = _SystemHash.combine(hash, password.hashCode);
    hash = _SystemHash.combine(hash, displayName.hashCode);
    hash = _SystemHash.combine(hash, dob.hashCode);
    hash = _SystemHash.combine(hash, village.hashCode);
    hash = _SystemHash.combine(hash, district.hashCode);
    hash = _SystemHash.combine(hash, country.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SignUpRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `fullName` of this provider.
  String get fullName;

  /// The parameter `phoneNumber` of this provider.
  String get phoneNumber;

  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `password` of this provider.
  String get password;

  /// The parameter `displayName` of this provider.
  String? get displayName;

  /// The parameter `dob` of this provider.
  String? get dob;

  /// The parameter `village` of this provider.
  String? get village;

  /// The parameter `district` of this provider.
  String? get district;

  /// The parameter `country` of this provider.
  String? get country;
}

class _SignUpProviderElement extends AutoDisposeFutureProviderElement<String>
    with SignUpRef {
  _SignUpProviderElement(super.provider);

  @override
  String get fullName => (origin as SignUpProvider).fullName;
  @override
  String get phoneNumber => (origin as SignUpProvider).phoneNumber;
  @override
  String get username => (origin as SignUpProvider).username;
  @override
  String get password => (origin as SignUpProvider).password;
  @override
  String? get displayName => (origin as SignUpProvider).displayName;
  @override
  String? get dob => (origin as SignUpProvider).dob;
  @override
  String? get village => (origin as SignUpProvider).village;
  @override
  String? get district => (origin as SignUpProvider).district;
  @override
  String? get country => (origin as SignUpProvider).country;
}

String _$verifyCodeHash() => r'd48365f78cfd7c36afe594b49048cdbf5003ede9';

/// Verify code
///
/// Copied from [verifyCode].
@ProviderFor(verifyCode)
const verifyCodeProvider = VerifyCodeFamily();

/// Verify code
///
/// Copied from [verifyCode].
class VerifyCodeFamily extends Family<AsyncValue<VerifyCodeResponseDto>> {
  /// Verify code
  ///
  /// Copied from [verifyCode].
  const VerifyCodeFamily();

  /// Verify code
  ///
  /// Copied from [verifyCode].
  VerifyCodeProvider call({
    required String username,
    required String code,
    required VerificationType type,
  }) {
    return VerifyCodeProvider(username: username, code: code, type: type);
  }

  @override
  VerifyCodeProvider getProviderOverride(
    covariant VerifyCodeProvider provider,
  ) {
    return call(
      username: provider.username,
      code: provider.code,
      type: provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'verifyCodeProvider';
}

/// Verify code
///
/// Copied from [verifyCode].
class VerifyCodeProvider
    extends AutoDisposeFutureProvider<VerifyCodeResponseDto> {
  /// Verify code
  ///
  /// Copied from [verifyCode].
  VerifyCodeProvider({
    required String username,
    required String code,
    required VerificationType type,
  }) : this._internal(
         (ref) => verifyCode(
           ref as VerifyCodeRef,
           username: username,
           code: code,
           type: type,
         ),
         from: verifyCodeProvider,
         name: r'verifyCodeProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$verifyCodeHash,
         dependencies: VerifyCodeFamily._dependencies,
         allTransitiveDependencies: VerifyCodeFamily._allTransitiveDependencies,
         username: username,
         code: code,
         type: type,
       );

  VerifyCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
    required this.code,
    required this.type,
  }) : super.internal();

  final String username;
  final String code;
  final VerificationType type;

  @override
  Override overrideWith(
    FutureOr<VerifyCodeResponseDto> Function(VerifyCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VerifyCodeProvider._internal(
        (ref) => create(ref as VerifyCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
        code: code,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VerifyCodeResponseDto> createElement() {
    return _VerifyCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VerifyCodeProvider &&
        other.username == username &&
        other.code == code &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VerifyCodeRef on AutoDisposeFutureProviderRef<VerifyCodeResponseDto> {
  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `code` of this provider.
  String get code;

  /// The parameter `type` of this provider.
  VerificationType get type;
}

class _VerifyCodeProviderElement
    extends AutoDisposeFutureProviderElement<VerifyCodeResponseDto>
    with VerifyCodeRef {
  _VerifyCodeProviderElement(super.provider);

  @override
  String get username => (origin as VerifyCodeProvider).username;
  @override
  String get code => (origin as VerifyCodeProvider).code;
  @override
  VerificationType get type => (origin as VerifyCodeProvider).type;
}

String _$forgotPasswordHash() => r'5b07ef7b28f083717d21832940a76192acdcaaa0';

/// Forgot password - send reset code
///
/// Copied from [forgotPassword].
@ProviderFor(forgotPassword)
const forgotPasswordProvider = ForgotPasswordFamily();

/// Forgot password - send reset code
///
/// Copied from [forgotPassword].
class ForgotPasswordFamily extends Family<AsyncValue<void>> {
  /// Forgot password - send reset code
  ///
  /// Copied from [forgotPassword].
  const ForgotPasswordFamily();

  /// Forgot password - send reset code
  ///
  /// Copied from [forgotPassword].
  ForgotPasswordProvider call({required String username}) {
    return ForgotPasswordProvider(username: username);
  }

  @override
  ForgotPasswordProvider getProviderOverride(
    covariant ForgotPasswordProvider provider,
  ) {
    return call(username: provider.username);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'forgotPasswordProvider';
}

/// Forgot password - send reset code
///
/// Copied from [forgotPassword].
class ForgotPasswordProvider extends AutoDisposeFutureProvider<void> {
  /// Forgot password - send reset code
  ///
  /// Copied from [forgotPassword].
  ForgotPasswordProvider({required String username})
    : this._internal(
        (ref) => forgotPassword(ref as ForgotPasswordRef, username: username),
        from: forgotPasswordProvider,
        name: r'forgotPasswordProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$forgotPasswordHash,
        dependencies: ForgotPasswordFamily._dependencies,
        allTransitiveDependencies:
            ForgotPasswordFamily._allTransitiveDependencies,
        username: username,
      );

  ForgotPasswordProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
  }) : super.internal();

  final String username;

  @override
  Override overrideWith(
    FutureOr<void> Function(ForgotPasswordRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ForgotPasswordProvider._internal(
        (ref) => create(ref as ForgotPasswordRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _ForgotPasswordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ForgotPasswordProvider && other.username == username;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ForgotPasswordRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `username` of this provider.
  String get username;
}

class _ForgotPasswordProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with ForgotPasswordRef {
  _ForgotPasswordProviderElement(super.provider);

  @override
  String get username => (origin as ForgotPasswordProvider).username;
}

String _$resendCodeHash() => r'8340ab37d136812877890ee79587f955a582584e';

/// Resend verification code
///
/// Copied from [resendCode].
@ProviderFor(resendCode)
const resendCodeProvider = ResendCodeFamily();

/// Resend verification code
///
/// Copied from [resendCode].
class ResendCodeFamily extends Family<AsyncValue<void>> {
  /// Resend verification code
  ///
  /// Copied from [resendCode].
  const ResendCodeFamily();

  /// Resend verification code
  ///
  /// Copied from [resendCode].
  ResendCodeProvider call({
    required String username,
    required VerificationType type,
  }) {
    return ResendCodeProvider(username: username, type: type);
  }

  @override
  ResendCodeProvider getProviderOverride(
    covariant ResendCodeProvider provider,
  ) {
    return call(username: provider.username, type: provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'resendCodeProvider';
}

/// Resend verification code
///
/// Copied from [resendCode].
class ResendCodeProvider extends AutoDisposeFutureProvider<void> {
  /// Resend verification code
  ///
  /// Copied from [resendCode].
  ResendCodeProvider({required String username, required VerificationType type})
    : this._internal(
        (ref) =>
            resendCode(ref as ResendCodeRef, username: username, type: type),
        from: resendCodeProvider,
        name: r'resendCodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$resendCodeHash,
        dependencies: ResendCodeFamily._dependencies,
        allTransitiveDependencies: ResendCodeFamily._allTransitiveDependencies,
        username: username,
        type: type,
      );

  ResendCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
    required this.type,
  }) : super.internal();

  final String username;
  final VerificationType type;

  @override
  Override overrideWith(
    FutureOr<void> Function(ResendCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResendCodeProvider._internal(
        (ref) => create(ref as ResendCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _ResendCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResendCodeProvider &&
        other.username == username &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResendCodeRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `type` of this provider.
  VerificationType get type;
}

class _ResendCodeProviderElement extends AutoDisposeFutureProviderElement<void>
    with ResendCodeRef {
  _ResendCodeProviderElement(super.provider);

  @override
  String get username => (origin as ResendCodeProvider).username;
  @override
  VerificationType get type => (origin as ResendCodeProvider).type;
}

String _$authSessionNotifierHash() =>
    r'2ae425e339d220368746bf7e48e4b6864c2ca93d';

/// Provider for current auth session
///
/// Copied from [AuthSessionNotifier].
@ProviderFor(AuthSessionNotifier)
final authSessionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AuthSessionNotifier,
      AuthSession?
    >.internal(
      AuthSessionNotifier.new,
      name: r'authSessionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authSessionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthSessionNotifier = AutoDisposeAsyncNotifier<AuthSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
