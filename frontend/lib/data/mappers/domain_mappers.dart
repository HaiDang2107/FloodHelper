/// Mappers for converting between data models and domain entities
/// This keeps the data layer concerns separate from domain layer

import '../../domain/models/models.dart';
import '../models/profile_model.dart' as data;
import '../models/post_model.dart' as data;
import '../models/user_model.dart' as data;
import '../models/announcement_model.dart' as data;

/// Mapper for ProfileModel -> UserProfile
extension ProfileModelMapper on data.ProfileModel {
  UserProfile toDomain() {
    return UserProfile(
      userId: userId,
      name: name,
      displayName: displayName,
      gender: Gender.fromString(gender),
      dateOfBirth: dob != null ? DateTime.tryParse(dob!) : null,
      phoneNumber: phoneNumber,
      roles: roles.map((r) => UserRole.fromString(r)).toList(),
      avatarUrl: avatarUrl,
      address: Address(
        village: village,
        district: district,
        country: country,
      ),
      location: (longitude != null && latitude != null)
          ? Location(latitude: latitude!, longitude: longitude!)
          : null,
      publicMapMode: publicMapMode,
      jobPosition: jobPosition,
      citizenInfo: CitizenInfo(
        citizenId: citizenId,
        citizenIdCardImg: citizenIdCardImg,
      ),
      accountState: account != null
          ? AccountState(
              username: account!.username,
              status: AccountStatus.fromString(account!.state),
              createdAt: account!.createdAt,
            )
          : null,
    );
  }
}

/// Mapper for UserProfile -> ProfileModel (for updates)
extension UserProfileToDataMapper on UserProfile {
  data.UpdateProfileDto toUpdateDto() {
    return data.UpdateProfileDto(
      displayName: displayName,
      gender: gender?.toBackendString(),
      dob: dateOfBirth?.toIso8601String().split('T')[0],
      village: address?.village,
      district: address?.district,
      country: address?.country,
      curLongitude: location?.longitude,
      curLatitude: location?.latitude,
      publicMapMode: publicMapMode,
      avatarUrl: avatarUrl,
      citizenId: citizenInfo?.citizenId,
      citizenIdCardImg: citizenInfo?.citizenIdCardImg,
      jobPosition: jobPosition,
    );
  }
}

/// Mapper for PostModel -> Post (domain)
extension PostModelMapper on data.PostModel {
  Post toDomain() {
    return Post(
      id: id,
      author: PostAuthor(
        userId: createdByUserId,
        name: createdBy,
        avatarUrl: createdByAvatar.isNotEmpty ? createdByAvatar : null,
      ),
      caption: caption,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      location: Location(
        latitude: latitude,
        longitude: longitude,
      ),
      createdAt: createdAt,
      deletedAt: deletedAt,
      likesCount: likesCount,
      isLikedByCurrentUser: isLikedByMe,
      comments: comments.map((c) => c.toDomain()).toList(),
    );
  }
}

/// Mapper for CommentModel -> Comment (domain)
extension CommentModelMapper on data.CommentModel {
  Comment toDomain() {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      content: content,
      createdAt: createdAt,
    );
  }
}

/// Mapper for UserModel -> MapUser (domain)
extension UserModelMapper on data.UserModel {
  MapUser toDomain() {
    return MapUser(
      userId: id,
      name: name,
      displayName: displayName,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      location: Location(
        latitude: latitude,
        longitude: longitude,
      ),
      status: UserOnlineStatus.fromString(status),
      roles: roles,
      isFriend: isFriend,
      distressInfo: isSosState
          ? DistressInfo(
              trappedCount: trappedCounts ?? 1,
              childrenCount: childrenNumbers,
              elderlyCount: elderlyNumbers,
              hasFood: hasFood ?? true,
              hasWater: hasWater ?? true,
              additionalInfo: other,
            )
          : null,
    );
  }
}

/// Mapper for AnnouncementModel -> Announcement (domain)
extension AnnouncementModelMapper on data.AnnouncementModel {
  Announcement toDomain() {
    return Announcement(
      id: id,
      title: title,
      summary: hint,
      content: content,
      type: AnnouncementType.fromString(source.name),
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}
