// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allocationViewModelHash() =>
    r'c9fc83b937a98090a1bf4fbec27719dd47167d72';

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

abstract class _$AllocationViewModel
    extends BuildlessAutoDisposeNotifier<AllocationState> {
  late final AllocationViewModelSeed seed;

  AllocationState build(AllocationViewModelSeed seed);
}

/// See also [AllocationViewModel].
@ProviderFor(AllocationViewModel)
const allocationViewModelProvider = AllocationViewModelFamily();

/// See also [AllocationViewModel].
class AllocationViewModelFamily extends Family<AllocationState> {
  /// See also [AllocationViewModel].
  const AllocationViewModelFamily();

  /// See also [AllocationViewModel].
  AllocationViewModelProvider call(AllocationViewModelSeed seed) {
    return AllocationViewModelProvider(seed);
  }

  @override
  AllocationViewModelProvider getProviderOverride(
    covariant AllocationViewModelProvider provider,
  ) {
    return call(provider.seed);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allocationViewModelProvider';
}

/// See also [AllocationViewModel].
class AllocationViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<AllocationViewModel, AllocationState> {
  /// See also [AllocationViewModel].
  AllocationViewModelProvider(AllocationViewModelSeed seed)
    : this._internal(
        () => AllocationViewModel()..seed = seed,
        from: allocationViewModelProvider,
        name: r'allocationViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allocationViewModelHash,
        dependencies: AllocationViewModelFamily._dependencies,
        allTransitiveDependencies:
            AllocationViewModelFamily._allTransitiveDependencies,
        seed: seed,
      );

  AllocationViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.seed,
  }) : super.internal();

  final AllocationViewModelSeed seed;

  @override
  AllocationState runNotifierBuild(covariant AllocationViewModel notifier) {
    return notifier.build(seed);
  }

  @override
  Override overrideWith(AllocationViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllocationViewModelProvider._internal(
        () => create()..seed = seed,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        seed: seed,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AllocationViewModel, AllocationState>
  createElement() {
    return _AllocationViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllocationViewModelProvider && other.seed == seed;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, seed.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllocationViewModelRef
    on AutoDisposeNotifierProviderRef<AllocationState> {
  /// The parameter `seed` of this provider.
  AllocationViewModelSeed get seed;
}

class _AllocationViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<AllocationViewModel, AllocationState>
    with AllocationViewModelRef {
  _AllocationViewModelProviderElement(super.provider);

  @override
  AllocationViewModelSeed get seed =>
      (origin as AllocationViewModelProvider).seed;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
