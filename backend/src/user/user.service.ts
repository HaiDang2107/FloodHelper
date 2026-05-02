import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import {
  CreateUserDto,
  UpdateUserDto,
  UpdateLocationDto,
  UpdateVisibilityDto,
} from './dto';
import { PrismaService } from '../prisma/prisma.service';
import { CloudinaryService } from '../common/cloudinary.service';
import { formatLocation } from '../common/location-format.util';
import type { UploadedFilePayload } from '../common/uploaded-file.type';

@Injectable()
export class UserService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cloudinary: CloudinaryService,
  ) {}

  /**
   * Get current user profile by userId (from JWT)
   */
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      include: {
        originProvince: true,
        originWard: true,
        residenceProvince: true,
        residenceWard: true,
        account: {
          select: {
            username: true,
            state: true,
            createdAt: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.formatUserResponse(user);
  }

  /**
   * Get user by ID (public profile)
   */
  async findOne(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
        role: true,
        curLongitude: true,
        curLatitude: true,
        visibilityMode: true,
        originProvinceCode: true,
        originWardCode: true,
        residenceProvinceCode: true,
        residenceWardCode: true,
        originProvince: {
          select: { code: true, name: true },
        },
        originWard: {
          select: { code: true, name: true },
        },
        residenceProvince: {
          select: { code: true, name: true },
        },
        residenceWard: {
          select: { code: true, name: true },
        },
      },
    });

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
  async update(
    userId: string,
    updateUserDto: UpdateUserDto = {},
    avatarFile?: UploadedFilePayload,
    citizenFrontFile?: UploadedFilePayload,
    citizenBackFile?: UploadedFilePayload,
  ) {
    const safeDto = updateUserDto ?? {};

    const user = await this.prisma.user.findUnique({
      where: { userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const imageUpdates: {
      avatarUrl?: string;
      frontCitizenIdCardImageUrl?: string;
      backCitizenIdCardImageUrl?: string;
    } = {};

    try {
      if (avatarFile) {
        const ext = avatarFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.avatarUrl = await this.cloudinary.uploadImage(
          avatarFile.buffer,
          {
            folder: 'floodhelper/profiles/avatars',
            publicId: `${userId}_avatar.${ext}`,
          },
        );
      }

      if (citizenFrontFile) {
        const ext = citizenFrontFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.frontCitizenIdCardImageUrl =
          await this.cloudinary.uploadImage(citizenFrontFile.buffer, {
            folder: 'floodhelper/profiles/citizen-id-cards',
            publicId: `${userId}_citizen_id_front.${ext}`,
          });
      }

      if (citizenBackFile) {
        const ext = citizenBackFile.originalname.split('.').pop() || 'jpg';
        imageUpdates.backCitizenIdCardImageUrl = await this.cloudinary.uploadImage(
          citizenBackFile.buffer,
          {
            folder: 'floodhelper/profiles/citizen-id-cards',
            publicId: `${userId}_citizen_id_back.${ext}`,
          },
        );
      }
    } catch (error) {
      throw new BadRequestException('Failed to upload profile images: ' + error.message);
    }

    const updated = await this.prisma.user.update({
      where: { userId },
      data: {
        fullname: safeDto.fullname,
        nickname: safeDto.nickname,
        gender: safeDto.gender,
        dob: safeDto.dob ? new Date(safeDto.dob) : undefined,
        originProvinceCode: safeDto.originProvinceCode,
        originWardCode: safeDto.originWardCode,
        residenceProvinceCode: safeDto.residenceProvinceCode,
        residenceWardCode: safeDto.residenceWardCode,
        dateOfIssue: safeDto.dateOfIssue
          ? new Date(safeDto.dateOfIssue)
          : undefined,
        dateOfExpire: safeDto.dateOfExpire
          ? new Date(safeDto.dateOfExpire)
          : undefined,
        curLongitude: safeDto.curLongitude,
        curLatitude: safeDto.curLatitude,
        visibilityMode: safeDto.visibilityMode,
        showCharityCampaignLocations: safeDto.showCharityCampaignLocations,
        avatarUrl: imageUpdates.avatarUrl ?? safeDto.avatarUrl,
        citizenId: safeDto.citizenId,
        citizenIdCardImg: safeDto.citizenIdCardImg,
        frontCitizenIdCardImageUrl:
          imageUpdates.frontCitizenIdCardImageUrl ??
          safeDto.frontCitizenIdCardImageUrl,
        backCitizenIdCardImageUrl:
          imageUpdates.backCitizenIdCardImageUrl ??
          safeDto.backCitizenIdCardImageUrl,
        jobPosition: safeDto.jobPosition,
      },
      include: {
        account: {
          select: {
            username: true,
            state: true,
            createdAt: true,
          },
        },
      },
    });

    return this.formatUserResponse(updated);
  }

  /**
   * Update user location
   */
  async updateLocation(userId: string, updateLocationDto: UpdateLocationDto) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const updated = await this.prisma.user.update({
      where: { userId },
      data: {
        curLongitude: updateLocationDto.curLongitude,
        curLatitude: updateLocationDto.curLatitude,
      },
    });

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
    const skip = (page - 1) * limit;

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        skip,
        take: limit,
        select: {
          userId: true,
          fullname: true,
          nickname: true,
          avatarUrl: true,
          role: true,
          phoneNumber: true,
          originProvinceCode: true,
          originWardCode: true,
          residenceProvinceCode: true,
          residenceWardCode: true,
          originProvince: {
            select: { code: true, name: true },
          },
          originWard: {
            select: { code: true, name: true },
          },
          residenceProvince: {
            select: { code: true, name: true },
          },
          residenceWard: {
            select: { code: true, name: true },
          },
        },
        orderBy: { fullname: 'asc' },
      }),
      this.prisma.user.count(),
    ]);

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
    // Get users with PUBLIC visibility
    const users = await this.prisma.user.findMany({
      where: {
        visibilityMode: 'PUBLIC',
        userId: { not: userId }, // Exclude current user
        curLongitude: { not: null },
        curLatitude: { not: null },
      },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
        role: true,
        curLongitude: true,
        curLatitude: true,
        originProvinceCode: true,
        originWardCode: true,
        residenceProvinceCode: true,
        residenceWardCode: true,
        originProvince: {
          select: { code: true, name: true },
        },
        originWard: {
          select: { code: true, name: true },
        },
        residenceProvince: {
          select: { code: true, name: true },
        },
        residenceWard: {
          select: { code: true, name: true },
        },
      },
    });

    // Filter by distance (simple calculation - for production use PostGIS)
    const nearbyUsers = users.filter((user) => {
      if (!user.curLongitude || !user.curLatitude) return false;
      const distance = this.calculateDistance(
        latitude,
        longitude,
        Number(user.curLatitude),
        Number(user.curLongitude),
      );
      return distance <= radiusKm;
    });

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
      citizenIdCardImg: user.citizenIdCardImg,
      frontCitizenIdCardImageUrl: user.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: user.backCitizenIdCardImageUrl,
      jobPosition: user.jobPosition,
      account: user.account
        ? {
            username: user.account.username,
            state: user.account.state,
            createdAt: user.account.createdAt,
          }
        : null,
    };
  }

  /**
   * Calculate distance between two points using Haversine formula
   */
  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180);
  }

  /**
   * Get user's current visibility mode.
   */
  async getVisibility(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      select: { visibilityMode: true },
    });

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
    await this.prisma.user.update({
      where: { userId },
      data: { visibilityMode: dto.visibility },
    });

    return {
      visibility: dto.visibility,
    };
  }

}
