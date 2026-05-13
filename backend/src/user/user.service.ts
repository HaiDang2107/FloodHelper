import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import {
  CreateUserDto,
  UpdateUserDto,
  UpdateLocationDto,
  UpdateVisibilityDto,
} from './dto';
import {
  UserRepository,
  ProfileRepository,
  RoleRequestRepository,
  ProfileRequestRepository,
} from '../prisma/repositories';
import { CloudinaryService } from '../common/cloudinary.service';
import { formatLocation } from '../common/location-format.util';
import type { UploadedFilePayload } from '../common/uploaded-file.type';
import { RespondRoleRequestDto } from '../role-request/dto';

@Injectable()
export class UserService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly profileRepository: ProfileRepository,
    private readonly roleRequestRepository: RoleRequestRepository,
    private readonly profileRequestRepository: ProfileRequestRepository,
    private readonly cloudinary: CloudinaryService,
  ) { }

  /**
   * Get current user profile by userId (from JWT)
   */
  async getProfile(userId: string) {
    const user = await this.profileRepository.getCurrentProfileWithRelations(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.formatUserResponse({
      ...user,
      role: user.user?.role ?? [],
      curLongitude: user.user?.curLongitude ?? null,
      curLatitude: user.user?.curLatitude ?? null,
      visibilityMode: user.user?.visibilityMode ?? null,
      showCharityCampaignLocations: user.user?.showCharityCampaignLocations ?? false,
      account: user.user?.account ?? null,
    });
  }

  /**
   * Get user by ID (public profile)
   */
  async findOne(userId: string) {
    const user = await this.userRepository.getPublicProfile(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      userId: user.userId,
      name: user.fullname,
      displayName: user.nickname,
      fullname: user.fullname,
      nickname: user.nickname,
      avatarUrl: user.avatarUrl,
      roles: user.role,
      visibilityMode: user.visibilityMode,
      // Only include location if visibilityMode is PUBLIC
      ...(user.visibilityMode === 'PUBLIC' && {
        longitude: user.curLongitude ? Number(user.curLongitude) : null,
        latitude: user.curLatitude ? Number(user.curLatitude) : null,
      }),
    };
  }

  /**
   * Update user profile
   */
  async update( // Dành cho normal user
    userId: string,
    updateUserDto: UpdateUserDto = {},
    avatarFile?: UploadedFilePayload,
    citizenFrontFile?: UploadedFilePayload,
    citizenBackFile?: UploadedFilePayload,
    rescuerCertificateFile?: UploadedFilePayload,
  ) {
    const safeDto = updateUserDto ?? {};

    const currentProfile = await this.profileRepository.getCurrentProfileWithRelations(userId);

    if (!currentProfile) {
      throw new NotFoundException('User not found');
    }

    const roles = currentProfile.user?.role ?? [];
    const isBenefactor = roles.includes('BENEFACTOR');
    const isRescuer = roles.includes('RESCUER');
    const isNormal = !isBenefactor && !isRescuer;

    // Chặn việc update profile khi có role request hoặc profile request pending
    const pendingRoleRequest = await this.roleRequestRepository.findAnyPendingRequest(userId);
    const pendingProfileRequest = await this.profileRequestRepository.findPendingForUser(userId);

    if (pendingRoleRequest || pendingProfileRequest) {
      throw new ConflictException('Exist pending requests. Please revoke them to update your profile.');
    }

    const profileUpdateDataPreview = {
      fullname: safeDto.fullname,
      nickname: safeDto.nickname,
      gender: safeDto.gender,
      dob: safeDto.dob ? new Date(safeDto.dob) : undefined,
      originProvinceCode: safeDto.originProvinceCode,
      originWardCode: safeDto.originWardCode,
      residenceProvinceCode: safeDto.residenceProvinceCode,
      residenceWardCode: safeDto.residenceWardCode,
      dateOfIssue: safeDto.dateOfIssue ? new Date(safeDto.dateOfIssue) : undefined,
      dateOfExpire: safeDto.dateOfExpire ? new Date(safeDto.dateOfExpire) : undefined,
      citizenId: safeDto.citizenId,
      occupation: safeDto.occupation,
    } as const;

    const hasNonCertificateChangesPreview = // Kiểm tra dữ liệu mới có khác dữ liệu cũ không
      this.hasNonCertificateChanges(currentProfile, profileUpdateDataPreview) ||
      !!avatarFile || !!citizenFrontFile || !!citizenBackFile;

    const hasCertificateChangePreview = !!rescuerCertificateFile;

    if (!isNormal) {
      const onlyCertificateChange = !hasNonCertificateChangesPreview && hasCertificateChangePreview;

      if (!(isBenefactor && !isRescuer && onlyCertificateChange)) {
        throw new BadRequestException(
          'You can not change your profile freely. Please send a profile update request.',
        );
      }
    }

    // Upload ảnh lên cloudinary và lấy lại link
    const imageUpdates = await this.uploadProfileImages(
      userId,
      avatarFile,
      citizenFrontFile,
      citizenBackFile,
      rescuerCertificateFile,
    );

    const profileUpdateData = {
      ...profileUpdateDataPreview,
      avatarUrl: imageUpdates.avatarUrl,
      frontCitizenIdCardImageUrl: imageUpdates.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: imageUpdates.backCitizenIdCardImageUrl,
      rescuerCertificateUrl: imageUpdates.rescuerCertificateUrl,
    } as const;

    const userUpdateData = {
      curLongitude: safeDto.curLongitude,
      curLatitude: safeDto.curLatitude,
      visibilityMode: safeDto.visibilityMode,
      showCharityCampaignLocations: safeDto.showCharityCampaignLocations,
    } as const;

    if (userUpdateData.curLongitude != null ||
      userUpdateData.curLatitude != null ||
      userUpdateData.visibilityMode != null ||
      userUpdateData.showCharityCampaignLocations != null) {
      await this.userRepository.updateUserFields(userId, userUpdateData);
    }

    const updated = await this.profileRepository.updateCurrentProfile(
      userId,
      profileUpdateData,
    );

    if (!updated) {
      throw new NotFoundException('User not found');
    }

    return this.formatUserResponse({
      ...updated,
      role: updated.user.role,
      curLongitude: updated.user.curLongitude,
      curLatitude: updated.user.curLatitude,
      visibilityMode: updated.user.visibilityMode,
      showCharityCampaignLocations: updated.user.showCharityCampaignLocations,
      account: updated.user.account,
    });
  }

  async createProfileUpdateRequest( // Dành cho benefactor và rescuer 
    userId: string,
    updateUserDto: UpdateUserDto = {},
    avatarFile?: UploadedFilePayload,
    citizenFrontFile?: UploadedFilePayload,
    citizenBackFile?: UploadedFilePayload,
    rescuerCertificateFile?: UploadedFilePayload,
  ) {
    const safeDto = updateUserDto ?? {};
    const currentProfile = await this.profileRepository.findCurrentProfileSummary(userId);

    if (!currentProfile) {
      throw new NotFoundException('User not found');
    }

    const roles = currentProfile.user?.role ?? [];
    const isBenefactor = roles.includes('BENEFACTOR');
    const isRescuer = roles.includes('RESCUER');

    if (!isBenefactor && !isRescuer) {
      throw new BadRequestException('Only benefactor or rescuer can request profile updates');
    }

    const pendingRoleRequest = await this.roleRequestRepository.findAnyPendingRequest(userId);
    const pendingProfileRequest = await this.profileRequestRepository.findPendingForUser(userId);

    if (pendingRoleRequest || pendingProfileRequest) {
      throw new ConflictException('Exist pending requests. Please revoke them to update your profile.');
    }

    const profileUpdateDataPreview = {
      fullname: safeDto.fullname ?? currentProfile.fullname,
      nickname: safeDto.nickname ?? currentProfile.nickname,
      gender: safeDto.gender ?? currentProfile.gender,
      dob: safeDto.dob ? new Date(safeDto.dob) : currentProfile.dob,
      originProvinceCode: safeDto.originProvinceCode ?? currentProfile.originProvinceCode,
      originWardCode: safeDto.originWardCode ?? currentProfile.originWardCode,
      residenceProvinceCode: safeDto.residenceProvinceCode ?? currentProfile.residenceProvinceCode,
      residenceWardCode: safeDto.residenceWardCode ?? currentProfile.residenceWardCode,
      dateOfIssue: safeDto.dateOfIssue ? new Date(safeDto.dateOfIssue) : currentProfile.dateOfIssue,
      dateOfExpire: safeDto.dateOfExpire ? new Date(safeDto.dateOfExpire) : currentProfile.dateOfExpire,
      citizenId: safeDto.citizenId ?? currentProfile.citizenId,
      occupation: safeDto.occupation ?? currentProfile.occupation,
      phoneNumber: safeDto.phoneNumber ?? currentProfile.phoneNumber,
    } as const;

    const hasChangesPreview =
      this.hasNonCertificateChanges(currentProfile, profileUpdateDataPreview) ||
      !!avatarFile || !!citizenFrontFile || !!citizenBackFile ||
      !!rescuerCertificateFile;

    if (!hasChangesPreview) {
      throw new BadRequestException('No profile changes detected');
    }

    if (!currentProfile.residenceWardCode) {
      throw new BadRequestException('Residence ward is required to send a profile update request');
    }

    const authorities = await this.userRepository.findAuthoritiesByWard(
      currentProfile.residenceWardCode,
    );
    const authority = authorities[0];

    if (!authority) {
      throw new BadRequestException('No authority found for your residence ward');
    }

    // Upload ảnh lên cloudinary và lấy lại link
    // Dùng timestamp làm suffix để tránh ghi đè ảnh hiện tại khi đang chờ duyệt
    const imageUpdates = await this.uploadProfileImages(
      userId,
      avatarFile,
      citizenFrontFile,
      citizenBackFile,
      rescuerCertificateFile,
      `req_${Date.now()}`,
    );

    const profileUpdateData = {
      ...profileUpdateDataPreview,
      avatarUrl: imageUpdates.avatarUrl ?? currentProfile.avatarUrl,
      frontCitizenIdCardImageUrl: imageUpdates.frontCitizenIdCardImageUrl ?? currentProfile.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: imageUpdates.backCitizenIdCardImageUrl ?? currentProfile.backCitizenIdCardImageUrl,
      rescuerCertificateUrl: imageUpdates.rescuerCertificateUrl ?? currentProfile.rescuerCertificateUrl,
    } as const;

    const newProfile = await this.profileRepository.createProfile({
      userId,
      isCurrent: false,
      fullname: profileUpdateData.fullname,
      nickname: profileUpdateData.nickname,
      dob: profileUpdateData.dob,
      gender: profileUpdateData.gender,
      phoneNumber: profileUpdateData.phoneNumber,
      avatarUrl: profileUpdateData.avatarUrl,
      citizenId: profileUpdateData.citizenId,
      rescuerCertificateUrl: profileUpdateData.rescuerCertificateUrl,
      frontCitizenIdCardImageUrl: profileUpdateData.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: profileUpdateData.backCitizenIdCardImageUrl,
      occupation: profileUpdateData.occupation,
      originProvinceCode: profileUpdateData.originProvinceCode,
      originWardCode: profileUpdateData.originWardCode,
      residenceProvinceCode: profileUpdateData.residenceProvinceCode,
      residenceWardCode: profileUpdateData.residenceWardCode,
      dateOfIssue: profileUpdateData.dateOfIssue,
      dateOfExpire: profileUpdateData.dateOfExpire,
    });

    return this.profileRequestRepository.createRequest({
      currentProfileId: currentProfile.profileId,
      newProfileId: newProfile.profileId,
      checkedBy: authority.userId,
    });
  }

  async listProfileUpdateRequests(userId: string) {
    const items = await this.profileRequestRepository.listRequestsForRequester(
      userId,
    );

    const formatted = items.map((item) => {
      const { currentProfile, newProfile, checker, ...rest } = item as any;
      const checkerProfile = checker?.profiles?.[0];
      const authorityName =
        checkerProfile?.nickname ?? checkerProfile?.fullname ?? null;

      const changedFields = this.calculateChangedFields(
        currentProfile,
        newProfile,
      );

      return { ...rest, authorityName, changedFields };
    });

    return { items: formatted };
  }

  async listProfileUpdateRequestsForAuthority(authorityId: string, dto: any) {
    await this.assertAuthorityUser(authorityId);

    const rawLimit = Number(dto.limit ?? 10);
    const limit = Number.isFinite(rawLimit)
      ? Math.min(Math.max(Math.floor(rawLimit), 1), 50)
      : 10;
    const beforeCreatedAt = dto.beforeCreatedAt
      ? new Date(dto.beforeCreatedAt)
      : undefined;

    const { items, hasMore, nextCursor } =
      await this.profileRequestRepository.listRequestsForAuthority(
        authorityId,
        limit,
        beforeCreatedAt,
        dto.type, // BENEFACTOR | RESCUER
        dto.state,
      );

    const formatted = items.map((item) => {
      const { currentProfile, newProfile, ...rest } = item as any;
      const changedFields = this.calculateChangedFields(
        currentProfile,
        newProfile,
      );

      // Get requester role and name
      const requester = currentProfile.user;
      const requesterName = currentProfile.fullname;
      const requesterEmail = requester.account?.username;
      const requesterRole = requester.role.includes('RESCUER')
        ? 'RESCUER'
        : 'BENEFACTOR';

      return {
        ...rest,
        requesterName,
        requesterEmail,
        requesterRole,
        changedFields,
      };
    });

    return {
      items: formatted,
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  async approveProfileUpdateRequest(
    authorityId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    await this.assertAuthorityUser(authorityId);

    const request = await this.profileRequestRepository.getRequestWithProfiles(
      requestId,
    );
    if (!request) {
      throw new NotFoundException('Profile update request not found');
    }

    if (request.checkedBy !== authorityId) {
      throw new ForbiddenException('You are not assigned to this request');
    }

    if (request.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be approved');
    }

    await this.profileRequestRepository.approveProfileUpdate(
      requestId,
      request.currentProfileId,
      request.newProfileId,
      dto.note,
    );

    return { success: true };
  }

  async rejectProfileUpdateRequest(
    authorityId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    await this.assertAuthorityUser(authorityId);

    const request = await this.profileRequestRepository.findById(requestId);
    if (!request) {
      throw new NotFoundException('Profile update request not found');
    }

    if (request.checkedBy !== authorityId) {
      throw new ForbiddenException('You are not assigned to this request');
    }

    if (request.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be rejected');
    }

    await this.profileRequestRepository.respondRequest(
      authorityId,
      requestId,
      'REJECTED',
      dto.note,
    );

    return { success: true };
  }

  private async assertAuthorityUser(authorityUserId: string) {
    const authority = await this.userRepository.getPublicProfile(
      authorityUserId,
    );

    if (!authority) {
      throw new NotFoundException('Authority account not found');
    }

    if (!authority.role.includes('AUTHORITY')) {
      throw new ForbiddenException(
        'Only authority users can access this resource',
      );
    }
  }

  private readonly FIELD_LABELS: Record<string, string> = {
    fullname: 'Full name',
    nickname: 'Nickname',
    gender: 'Gender',
    dob: 'Date of birth',
    occupation: 'Occupation',
    phoneNumber: 'Phone number',
    citizenId: 'Citizen ID',
    dateOfIssue: 'Date of issue',
    dateOfExpire: 'Date of expire',
    avatarUrl: 'Avatar',
    originProvince: 'Origin province',
    originWard: 'Origin ward',
    residenceProvince: 'Residence province',
    residenceWard: 'Residence ward',
    frontCitizenIdCardImageUrl: 'ID card (front)',
    backCitizenIdCardImageUrl: 'ID card (back)',
    rescuerCertificateUrl: 'Rescuer certificate',
  };

  private calculateChangedFields(currentProfile: any, newProfile: any) {
    const safeIsoDate = (val: any): string | null => {
      if (val == null) return null;
      const d = new Date(val);
      if (isNaN(d.getTime())) return null;
      return d.toISOString().split('T')[0];
    };

    const formatVal = (key: string, val: any, profile: any): string => {
      if (val == null) return '-';
      if (key === 'dob' || key === 'dateOfIssue' || key === 'dateOfExpire') {
        return safeIsoDate(val) ?? '-';
      }
      if (key === 'originProvince') return profile.originProvince?.name ?? '-';
      if (key === 'originWard') return profile.originWard?.name ?? '-';
      if (key === 'residenceProvince')
        return profile.residenceProvince?.name ?? '-';
      if (key === 'residenceWard') return profile.residenceWard?.name ?? '-';
      if (typeof val === 'string' && val.startsWith('http'))
        return '[File updated]';
      return String(val);
    };

    const COMPARABLE_FIELDS = [
      'fullname',
      'nickname',
      'gender',
      'dob',
      'occupation',
      'phoneNumber',
      'citizenId',
      'dateOfIssue',
      'dateOfExpire',
      'avatarUrl',
      'frontCitizenIdCardImageUrl',
      'backCitizenIdCardImageUrl',
      'rescuerCertificateUrl',
      'originProvince',
      'originWard',
      'residenceProvince',
      'residenceWard',
    ];

    const getVal = (key: string, profile: any) => {
      if (key === 'originProvince') return profile.originProvince?.name ?? null;
      if (key === 'originWard') return profile.originWard?.name ?? null;
      if (key === 'residenceProvince')
        return profile.residenceProvince?.name ?? null;
      if (key === 'residenceWard') return profile.residenceWard?.name ?? null;

      const v = profile[key];
      if (
        v instanceof Date ||
        key.toLowerCase().includes('date') ||
        key === 'dob'
      ) {
        return safeIsoDate(v);
      }
      return v ?? null;
    };

    const changedFields: {
      field: string;
      label: string;
      oldValue: string;
      newValue: string;
    }[] = [];

    if (currentProfile && newProfile) {
      for (const key of COMPARABLE_FIELDS) {
        // So sánh
        const oldVal = getVal(key, currentProfile);
        const newVal = getVal(key, newProfile);

        if (oldVal !== newVal) {
          const oldStr = formatVal(key, oldVal, currentProfile);
          const newStr = formatVal(key, newVal, newProfile);
          changedFields.push({
            field: key,
            label: this.FIELD_LABELS[key] ?? key,
            oldValue: oldStr,
            newValue: newStr,
          });
        }
      }
    }

    return changedFields;
  }

  async revokeProfileUpdateRequest(userId: string, requestId: string) {
    const existing = await this.profileRequestRepository.getRequestForRevoke(
      userId,
      requestId,
    );

    if (!existing) {
      throw new NotFoundException('Profile update request not found');
    }

    if (existing.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be revoked');
    }

    return this.profileRequestRepository.revokeRequest(requestId);
  }

  /**
   * Update user location
   */
  async updateLocation(userId: string, updateLocationDto: UpdateLocationDto) {
    const user = await this.userRepository.exists(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const updated = await this.userRepository.updateLocation(
      userId,
      updateLocationDto.curLongitude,
      updateLocationDto.curLatitude,
    );

    return {
      success: true,
      longitude: Number(updated.curLongitude),
      latitude: Number(updated.curLatitude),
    };
  }

  /**
   * Get all users (admin only - paginated)
   */
  async findAll(page: number = 1, limit: number = 20) {
    const { users, total } = await this.userRepository.findAllPaginated(page, limit);

    return {
      data: users.map((user) => ({
        userId: user.userId,
        name: user.fullname,
        displayName: user.nickname,
        fullname: user.fullname,
        nickname: user.nickname,
        avatarUrl: user.avatarUrl,
        roles: user.role,
        phoneNumber: user.phoneNumber,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get nearby users (users with publicMapMode enabled)
   */
  async findNearbyUsers(
    userId: string,
    longitude: number,
    latitude: number,
    radiusKm: number = 10,
  ) {
    const nearbyUsers = await this.userRepository.findNearbyUsers(
      userId,
      latitude,
      longitude,
      radiusKm,
    );

    return nearbyUsers.map((user) => ({
      userId: user.userId,
      name: user.fullname,
      displayName: user.nickname,
      fullname: user.fullname,
      nickname: user.nickname,
      avatarUrl: user.avatarUrl,
      roles: user.role,
      longitude: Number(user.curLongitude),
      latitude: Number(user.curLatitude),
    }));
  }

  /**
   * Format user response
   */
  private formatUserResponse(user: any) {
    return {
      userId: user.userId,
      name: user.fullname,
      displayName: user.nickname,
      fullname: user.fullname,
      nickname: user.nickname,
      gender: user.gender ?? null,
      dob: user.dob ? user.dob.toISOString().split('T')[0] : null,
      placeOfOrigin: formatLocation(user.originWard, user.originProvince),
      placeOfResidence: formatLocation(
        user.residenceWard,
        user.residenceProvince,
      ),
      originProvinceCode: user.originProvinceCode ?? null,
      originProvinceName: user.originProvince?.name ?? null,
      originWardCode: user.originWardCode ?? null,
      originWardName: user.originWard?.name ?? null,
      residenceProvinceCode: user.residenceProvinceCode ?? null,
      residenceProvinceName: user.residenceProvince?.name ?? null,
      residenceWardCode: user.residenceWardCode ?? null,
      residenceWardName: user.residenceWard?.name ?? null,
      dateOfIssue: user.dateOfIssue
        ? user.dateOfIssue.toISOString().split('T')[0]
        : null,
      dateOfExpire: user.dateOfExpire
        ? user.dateOfExpire.toISOString().split('T')[0]
        : null,
      roles: user.role,
      longitude: user.curLongitude ? Number(user.curLongitude) : null,
      latitude: user.curLatitude ? Number(user.curLatitude) : null,
      visibilityMode: user.visibilityMode,
      showCharityCampaignLocations: Boolean(user.showCharityCampaignLocations),
      avatarUrl: user.avatarUrl,
      citizenId: user.citizenId,
      phoneNumber: user.phoneNumber,
      rescuerCertificateUrl: user.rescuerCertificateUrl ?? null,
      frontCitizenIdCardImageUrl: user.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: user.backCitizenIdCardImageUrl,
      occupation: user.occupation,
      account: user.account
        ? {
          username: user.account.username,
          state: user.account.state,
          createdAt: user.account.createdAt,
        }
        : null,
    };
  }

  private async uploadProfileImages(
    userId: string,
    avatarFile?: UploadedFilePayload,
    citizenFrontFile?: UploadedFilePayload,
    citizenBackFile?: UploadedFilePayload,
    rescuerCertificateFile?: UploadedFilePayload,
    suffix?: string,
  ) {
    const imageUpdates: {
      avatarUrl?: string;
      frontCitizenIdCardImageUrl?: string;
      backCitizenIdCardImageUrl?: string;
      rescuerCertificateUrl?: string;
    } = {};

    const getPublicId = (base: string, ext: string) => {
      return suffix ? `${userId}_${base}_${suffix}.${ext}` : `${userId}_${base}.${ext}`;
    };

    try {
      if (avatarFile) {
        const ext = avatarFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.avatarUrl = await this.cloudinary.uploadImage(
          avatarFile.buffer,
          {
            folder: 'floodhelper/profiles/avatars',
            publicId: getPublicId('avatar', ext),
          },
        );
      }

      if (citizenFrontFile) {
        const ext = citizenFrontFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.frontCitizenIdCardImageUrl =
          await this.cloudinary.uploadImage(citizenFrontFile.buffer, {
            folder: 'floodhelper/profiles/citizen-id-cards',
            publicId: getPublicId('citizen_id_front', ext),
          });
      }

      if (citizenBackFile) {
        const ext = citizenBackFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.backCitizenIdCardImageUrl = await this.cloudinary.uploadImage(
          citizenBackFile.buffer,
          {
            folder: 'floodhelper/profiles/citizen-id-cards',
            publicId: getPublicId('citizen_id_back', ext),
          },
        );
      }

      if (rescuerCertificateFile) {
        const ext = rescuerCertificateFile.originalname.split('.').pop() || 'pdf';
        imageUpdates.rescuerCertificateUrl = await this.cloudinary.uploadRawFile(
          rescuerCertificateFile.buffer,
          {
            folder: 'floodhelper/profiles/rescuer-certificates',
            publicId: getPublicId('rescuer_certificate', ext),
          },
        );
      }
    } catch (error) {
      throw new BadRequestException('Failed to upload profile images: ' + error.message);
    }

    return imageUpdates;
  }

  private hasNonCertificateChanges(
    currentProfile: any,
    updateData: Record<string, unknown>,
    newCertificateUrl?: string,
  ) {
    const current = {
      fullname: currentProfile.fullname,
      nickname: currentProfile.nickname,
      gender: currentProfile.gender,
      dob: currentProfile.dob?.toISOString?.() ?? currentProfile.dob,
      originProvinceCode: currentProfile.originProvinceCode,
      originWardCode: currentProfile.originWardCode,
      residenceProvinceCode: currentProfile.residenceProvinceCode,
      residenceWardCode: currentProfile.residenceWardCode,
      dateOfIssue: currentProfile.dateOfIssue?.toISOString?.() ?? currentProfile.dateOfIssue,
      dateOfExpire: currentProfile.dateOfExpire?.toISOString?.() ?? currentProfile.dateOfExpire,
      avatarUrl: currentProfile.avatarUrl,
      citizenId: currentProfile.citizenId,
      frontCitizenIdCardImageUrl: currentProfile.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: currentProfile.backCitizenIdCardImageUrl,
      occupation: currentProfile.occupation,
      phoneNumber: currentProfile.phoneNumber,
    };

    const next = {
      fullname: updateData.fullname ?? current.fullname,
      nickname: updateData.nickname ?? current.nickname,
      gender: updateData.gender ?? current.gender,
      dob: updateData.dob ? new Date(updateData.dob as any).toISOString() : current.dob,
      originProvinceCode: updateData.originProvinceCode ?? current.originProvinceCode,
      originWardCode: updateData.originWardCode ?? current.originWardCode,
      residenceProvinceCode: updateData.residenceProvinceCode ?? current.residenceProvinceCode,
      residenceWardCode: updateData.residenceWardCode ?? current.residenceWardCode,
      dateOfIssue: updateData.dateOfIssue ? new Date(updateData.dateOfIssue as any).toISOString() : current.dateOfIssue,
      dateOfExpire: updateData.dateOfExpire ? new Date(updateData.dateOfExpire as any).toISOString() : current.dateOfExpire,
      avatarUrl: updateData.avatarUrl ?? current.avatarUrl,
      citizenId: updateData.citizenId ?? current.citizenId,
      frontCitizenIdCardImageUrl:
        updateData.frontCitizenIdCardImageUrl ?? current.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl:
        updateData.backCitizenIdCardImageUrl ?? current.backCitizenIdCardImageUrl,
      occupation: updateData.occupation ?? current.occupation,
      phoneNumber: updateData.phoneNumber ?? current.phoneNumber,
    };

    if (newCertificateUrl) {
      return Object.keys(next).some((key) => next[key] !== current[key]);
    }

    return Object.keys(next).some((key) => next[key] !== current[key]);
  }

  /**
   * Calculate distance between two points using Haversine formula
   */
  /**
   * Get user's current visibility mode.
   */
  async getVisibility(userId: string) {
    const user = await this.userRepository.getVisibility(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return { visibility: user.visibilityMode };
  }

  /**
   * Update user location visibility setting.
   * Only updates the visibilityMode field in User table.
   * Does NOT modify friendMapMode in Friendship table.
   * - 'PUBLIC': everyone can see
   * - 'JUST_FRIEND': only friends with friendMapMode=true can see
   * - 'NO_ONE': nobody can see
   */
  async updateVisibility(userId: string, dto: UpdateVisibilityDto) {
    await this.userRepository.updateVisibility(userId, dto.visibility);

    return {
      visibility: dto.visibility,
    };
  }

  /**
   * Update FCM token for push notifications.
   */
  async updateFcmToken(userId: string, fcmToken: string) {
    return this.userRepository.updateFcmToken(userId, fcmToken);
  }
}
