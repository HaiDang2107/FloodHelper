// Domain entity for User Profile
// This represents a complete user profile displayed on the profile screen
// Clean domain model - no JSON serialization logic

import 'user.dart';

/// Enum for gender
enum Gender {
  male,
  female,
  other;

  static Gender? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toUpperCase()) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      case 'OTHER':
        return Gender.other;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String toBackendString() => name.toUpperCase();
}

class UserProfile {
  final String userId;
  final String name;
  final String? displayName;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String phoneNumber;
  final List<UserRole> roles;
  final String? avatarUrl;
  final Address? address;
  final Location? location;
  final String visibilityMode; // PUBLIC | JUST_FRIEND | NO_ONE
  final String? jobPosition;
  final CitizenInfo? citizenInfo;
  final AccountState? accountState;

  const UserProfile({
    required this.userId,
    required this.name,
    this.displayName,
    this.gender,
    this.dateOfBirth,
    required this.phoneNumber,
    this.roles = const [],
    this.avatarUrl,
    this.address,
    this.location,
    this.visibilityMode = 'PUBLIC',
    this.jobPosition,
    this.citizenInfo,
    this.accountState,
  });

  /// Get display name or fallback to name
  String get effectiveDisplayName => displayName ?? name;

  /// Get full address as string
  String get fullAddress => address?.fullAddress ?? '';

  /// Check if user has a specific role
  bool hasRole(UserRole role) => roles.contains(role);

  /// Get initials from name (for avatar placeholder)
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    String? displayName,
    Gender? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    List<UserRole>? roles,
    String? avatarUrl,
    Address? address,
    Location? location,
    String? visibilityMode,
    String? jobPosition,
    CitizenInfo? citizenInfo,
    AccountState? accountState,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roles: roles ?? this.roles,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      location: location ?? this.location,
      visibilityMode: visibilityMode ?? this.visibilityMode,
      jobPosition: jobPosition ?? this.jobPosition,
      citizenInfo: citizenInfo ?? this.citizenInfo,
      accountState: accountState ?? this.accountState,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// Value object for address information
class Address {
  final String? placeOfOrigin;
  final String? placeOfResidence;

  const Address({
    this.placeOfOrigin,
    this.placeOfResidence,
  });

  String get fullAddress {
    return placeOfResidence ?? '';
  }

  bool get isEmpty => placeOfOrigin == null && placeOfResidence == null;

  Address copyWith({
    String? placeOfOrigin,
    String? placeOfResidence,
  }) {
    return Address(
      placeOfOrigin: placeOfOrigin ?? this.placeOfOrigin,
      placeOfResidence: placeOfResidence ?? this.placeOfResidence,
    );
  }
}

/// Value object for geographic location
class Location {
  final double latitude;
  final double longitude;

  const Location({
    required this.latitude,
    required this.longitude,
  });

  Location copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && 
        other.latitude == latitude && 
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Value object for citizen ID information
class CitizenInfo {
  final String? citizenId;
  final String? citizenIdCardImg;
  final DateTime? dateOfIssue;
  final DateTime? dateOfExpire;

  const CitizenInfo({
    this.citizenId,
    this.citizenIdCardImg,
    this.dateOfIssue,
    this.dateOfExpire,
  });

  bool get hasIdCard => citizenId != null && citizenId!.isNotEmpty;

  CitizenInfo copyWith({
    String? citizenId,
    String? citizenIdCardImg,
    DateTime? dateOfIssue,
    DateTime? dateOfExpire,
  }) {
    return CitizenInfo(
      citizenId: citizenId ?? this.citizenId,
      citizenIdCardImg: citizenIdCardImg ?? this.citizenIdCardImg,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      dateOfExpire: dateOfExpire ?? this.dateOfExpire,
    );
  }
}

/// Value object for account state
class AccountState {
  final String username;
  final AccountStatus status;
  final DateTime? createdAt;

  const AccountState({
    required this.username,
    required this.status,
    this.createdAt,
  });

  bool get isActive => status == AccountStatus.active;

  AccountState copyWith({
    String? username,
    AccountStatus? status,
    DateTime? createdAt,
  }) {
    return AccountState(
      username: username ?? this.username,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Enum for account status
enum AccountStatus {
  active,
  inactive,
  suspended;

  static AccountStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return AccountStatus.active;
      case 'suspended':
        return AccountStatus.suspended;
      default:
        return AccountStatus.inactive;
    }
  }
}
