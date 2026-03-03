/// Domain entity for displaying other users on map (Friends/Strangers)
/// Represents users shown on the home map with their status
/// Clean domain model - no JSON serialization logic

import 'user_profile.dart';

class MapUser {
  final String userId;
  final String name;
  final String? displayName;
  final String? avatarUrl;
  final Location location;
  final UserOnlineStatus status;
  final List<String> roles;
  final bool isFriend;
  final DistressInfo? distressInfo;

  const MapUser({
    required this.userId,
    required this.name,
    this.displayName,
    this.avatarUrl,
    required this.location,
    required this.status,
    this.roles = const [],
    this.isFriend = false,
    this.distressInfo,
  });

  /// Get display name or fallback to name
  String get effectiveDisplayName => displayName ?? name;

  /// Check if user is in distress (SOS state)
  bool get isInDistress => distressInfo != null;

  /// Check if user is a stranger (not friend)
  bool get isStranger => !isFriend;

  /// Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is a rescuer
  bool get isRescuer => roles.contains('Rescuer') || roles.contains('RESCUER');

  /// Check if user is a benefactor
  bool get isBenefactor => roles.contains('Benefactor') || roles.contains('BENEFACTOR');

  MapUser copyWith({
    String? userId,
    String? name,
    String? displayName,
    String? avatarUrl,
    Location? location,
    UserOnlineStatus? status,
    List<String>? roles,
    bool? isFriend,
    DistressInfo? distressInfo,
  }) {
    return MapUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      isFriend: isFriend ?? this.isFriend,
      distressInfo: distressInfo ?? this.distressInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// User online status enum
enum UserOnlineStatus {
  online,
  offline,
  unknown;

  String get displayName {
    switch (this) {
      case UserOnlineStatus.online:
        return 'Trực tuyến';
      case UserOnlineStatus.offline:
        return 'Ngoại tuyến';
      case UserOnlineStatus.unknown:
        return 'Không rõ';
    }
  }

  static UserOnlineStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return UserOnlineStatus.online;
      case 'offline':
        return UserOnlineStatus.offline;
      default:
        return UserOnlineStatus.unknown;
    }
  }
}

/// Value object for distress/SOS information
class DistressInfo {
  final int trappedCount;
  final int? childrenCount;
  final int? elderlyCount;
  final bool hasFood;
  final bool hasWater;
  final String? additionalInfo;
  final DateTime? reportedAt;

  const DistressInfo({
    required this.trappedCount,
    this.childrenCount,
    this.elderlyCount,
    this.hasFood = true,
    this.hasWater = true,
    this.additionalInfo,
    this.reportedAt,
  });

  /// Get urgency level based on conditions
  DistressUrgency get urgency {
    if (!hasFood || !hasWater) {
      return DistressUrgency.critical;
    }
    if (childrenCount != null && childrenCount! > 0 ||
        elderlyCount != null && elderlyCount! > 0) {
      return DistressUrgency.high;
    }
    if (trappedCount > 5) {
      return DistressUrgency.high;
    }
    return DistressUrgency.normal;
  }

  /// Summary of trapped people
  String get trappedSummary {
    final parts = <String>[];
    parts.add('$trappedCount người');
    if (childrenCount != null && childrenCount! > 0) {
      parts.add('$childrenCount trẻ em');
    }
    if (elderlyCount != null && elderlyCount! > 0) {
      parts.add('$elderlyCount người già');
    }
    return parts.join(', ');
  }

  /// Summary of resource status
  String get resourceSummary {
    final needs = <String>[];
    if (!hasFood) needs.add('thiếu thức ăn');
    if (!hasWater) needs.add('thiếu nước');
    if (needs.isEmpty) return 'Đủ nhu yếu phẩm';
    return needs.join(', ').capitalize();
  }

  DistressInfo copyWith({
    int? trappedCount,
    int? childrenCount,
    int? elderlyCount,
    bool? hasFood,
    bool? hasWater,
    String? additionalInfo,
    DateTime? reportedAt,
  }) {
    return DistressInfo(
      trappedCount: trappedCount ?? this.trappedCount,
      childrenCount: childrenCount ?? this.childrenCount,
      elderlyCount: elderlyCount ?? this.elderlyCount,
      hasFood: hasFood ?? this.hasFood,
      hasWater: hasWater ?? this.hasWater,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }
}

/// Distress urgency levels
enum DistressUrgency {
  normal,
  high,
  critical;

  String get displayName {
    switch (this) {
      case DistressUrgency.normal:
        return 'Bình thường';
      case DistressUrgency.high:
        return 'Khẩn cấp';
      case DistressUrgency.critical:
        return 'Rất khẩn cấp';
    }
  }
}

/// Extension to capitalize string
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
