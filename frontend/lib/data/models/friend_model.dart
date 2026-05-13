/// Model representing a friend with map mode status.
/// Maps to the response of GET /friend/list.
class FriendModel {
  final String userId;
  final String name;
  final String? displayName;
  final String? avatarUrl;
  final bool friendMapMode;
  final List<String> roles;

  const FriendModel({
    required this.userId,
    required this.name,
    this.displayName,
    this.avatarUrl,
    required this.friendMapMode,
    this.roles = const [],
  });

  String get effectiveDisplayName => displayName ?? name;

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      friendMapMode: json['friendMapMode'] ?? false,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'friendMapMode': friendMapMode,
      'roles': roles,
    };
  }

  FriendModel copyWith({
    String? userId,
    String? name,
    String? displayName,
    String? avatarUrl,
    bool? friendMapMode,
    List<String>? roles,
  }) {
    return FriendModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      friendMapMode: friendMapMode ?? this.friendMapMode,
      roles: roles ?? this.roles,
    );
  }
}
