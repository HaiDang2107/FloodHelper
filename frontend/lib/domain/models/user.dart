/// Domain model for User
/// This represents the business entity used throughout the app

class User {
  final String id;
  final String name;
  final String? displayName;
  final String? phoneNumber;
  final List<UserRole> roles;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    this.displayName,
    this.phoneNumber,
    required this.roles,
    this.avatarUrl,
  });

  /// Get the display name or fallback to name
  String get effectiveDisplayName => displayName ?? name;

  /// Check if user has a specific role
  bool hasRole(UserRole role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole(UserRole.admin);

  /// Check if user is authority
  bool get isAuthority => hasRole(UserRole.authority);

  /// Check if user is benefactor
  bool get isBenefactor => hasRole(UserRole.benefactor);

  /// Check if user is rescuer
  bool get isRescuer => hasRole(UserRole.rescuer);

  User copyWith({
    String? id,
    String? name,
    String? displayName,
    String? phoneNumber,
    List<UserRole>? roles,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roles: roles ?? this.roles,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, displayName: $displayName, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User roles enum - matches backend UserRole enum
enum UserRole {
  admin,
  authority,
  normalUser,
  benefactor,
  rescuer;

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'AUTHORITY':
        return UserRole.authority;
      case 'NORMAL USER':
      case 'NORMAL_USER':
        return UserRole.normalUser;
      case 'BENEFACTOR':
        return UserRole.benefactor;
      case 'RESCUER':
        return UserRole.rescuer;
      default:
        return UserRole.normalUser; // Default to normal user
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.authority:
        return 'Authority';
      case UserRole.normalUser:
        return 'User';
      case UserRole.benefactor:
        return 'Benefactor';
      case UserRole.rescuer:
        return 'Rescuer';
    }
  }

  /// Convert to backend format
  String toBackendString() {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.authority:
        return 'AUTHORITY';
      case UserRole.normalUser:
        return 'NORMAL USER';
      case UserRole.benefactor:
        return 'BENEFACTOR';
      case UserRole.rescuer:
        return 'RESCUER';
    }
  }

  String toJson() => toBackendString();
}
