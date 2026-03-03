/// Model for a friend request
class FriendRequestModel {
  final String requestId;
  final String state;
  final String? note;
  final DateTime createdAt;
  final FriendRequestUserInfo user;

  const FriendRequestModel({
    required this.requestId,
    required this.state,
    this.note,
    required this.createdAt,
    required this.user,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['requestId'] ?? '',
      state: json['state'] ?? '',
      note: json['note'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: FriendRequestUserInfo.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'state': state,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

/// User info in a friend request
class FriendRequestUserInfo {
  final String userId;
  final String name;
  final String? displayName;
  final String? avatarUrl;

  const FriendRequestUserInfo({
    required this.userId,
    required this.name,
    this.displayName,
    this.avatarUrl,
  });

  String get effectiveDisplayName => displayName ?? name;

  factory FriendRequestUserInfo.fromJson(Map<String, dynamic> json) {
    return FriendRequestUserInfo(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }
}

/// Response from sending a friend request
class SendFriendRequestResponse {
  final String requestId;
  final String createdBy;
  final String sentTo;
  final String state;
  final String? note;
  final DateTime createdAt;

  const SendFriendRequestResponse({
    required this.requestId,
    required this.createdBy,
    required this.sentTo,
    required this.state,
    this.note,
    required this.createdAt,
  });

  factory SendFriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return SendFriendRequestResponse(
      requestId: json['requestId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      sentTo: json['sentTo'] ?? '',
      state: json['state'] ?? '',
      note: json['note'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
