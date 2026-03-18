// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$signInViewModelHash() => r'7758b2cdf35f23439d0c138a62f163f0d348db21';

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

abstract class _$SignInViewModel
    extends BuildlessAutoDisposeNotifier<SignInState> {
  late final bool showFormInitially;

  SignInState build({bool showFormInitially = false});
}

/// See also [SignInViewModel].
@ProviderFor(SignInViewModel)
const signInViewModelProvider = SignInViewModelFamily();

/// See also [SignInViewModel].
class SignInViewModelFamily extends Family<SignInState> {
  /// See also [SignInViewModel].
  const SignInViewModelFamily();

  /// See also [SignInViewModel].
  SignInViewModelProvider call({bool showFormInitially = false}) {
    return SignInViewModelProvider(showFormInitially: showFormInitially);
  }

  @override
  SignInViewModelProvider getProviderOverride(
    covariant SignInViewModelProvider provider,
  ) {
    return call(showFormInitially: provider.showFormInitially);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'signInViewModelProvider';
}

/// See also [SignInViewModel].
class SignInViewModelProvider
    extends AutoDisposeNotifierProviderImpl<SignInViewModel, SignInState> {
  /// See also [SignInViewModel].
  SignInViewModelProvider({bool showFormInitially = false})
    : this._internal(
        () => SignInViewModel()..showFormInitially = showFormInitially,
        from: signInViewModelProvider,
        name: r'signInViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$signInViewModelHash,
        dependencies: SignInViewModelFamily._dependencies,
        allTransitiveDependencies:
            SignInViewModelFamily._allTransitiveDependencies,
        showFormInitially: showFormInitially,
      );

  SignInViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showFormInitially,
  }) : super.internal();

  final bool showFormInitially;

  @override
  SignInState runNotifierBuild(covariant SignInViewModel notifier) {
    return notifier.build(showFormInitially: showFormInitially);
  }

  @override
  Override overrideWith(SignInViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SignInViewModelProvider._internal(
        () => create()..showFormInitially = showFormInitially,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showFormInitially: showFormInitially,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SignInViewModel, SignInState>
  createElement() {
    return _SignInViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignInViewModelProvider &&
        other.showFormInitially == showFormInitially;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showFormInitially.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SignInViewModelRef on AutoDisposeNotifierProviderRef<SignInState> {
  /// The parameter `showFormInitially` of this provider.
  bool get showFormInitially;
}

class _SignInViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<SignInViewModel, SignInState>
    with SignInViewModelRef {
  _SignInViewModelProviderElement(super.provider);

  @override
  bool get showFormInitially =>
      (origin as SignInViewModelProvider).showFormInitially;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
