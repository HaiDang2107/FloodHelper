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

  /// Check if user is charity
  bool get isCharity => hasRole(UserRole.charity);

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

/// User roles enum
enum UserRole {
  user,
  admin,
  authority,
  charity;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'authority':
        return UserRole.authority;
      case 'charity':
        return UserRole.charity;
      default:
        return UserRole.user;
    }
  }

  String toJson() => name.toUpperCase();
}
