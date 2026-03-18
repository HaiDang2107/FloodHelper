/// Model representing a friend with map mode status.
/// Maps to the response of GET /friend/list.
class FriendModel {
  final String userId;
  final String name;
  final String? displayName;
  final String? avatarUrl;
  final bool friendMapMode;

  const FriendModel({
    required this.userId,
    required this.name,
    this.displayName,
    this.avatarUrl,
    required this.friendMapMode,
  });

  String get effectiveDisplayName => displayName ?? name;

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      friendMapMode: json['friendMapMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'friendMapMode': friendMapMode,
    };
  }

  FriendModel copyWith({
    String? userId,
    String? name,
    String? displayName,
    String? avatarUrl,
    bool? friendMapMode,
  }) {
    return FriendModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      friendMapMode: friendMapMode ?? this.friendMapMode,
    );
  }
}
