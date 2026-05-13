import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * UserRepository - Handles all User, Account, Session, Provider queries
 * Manages user profiles, authentication state, FCM tokens, and geo-location data
 */
@Injectable()
export class UserRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('User');
  }

  /**
   * Get full user profile with relationships (locations, account state)
   */
  async getProfileWithRelations(userId: string) {
    const profile = await this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      include: {
        originProvince: true,
        originWard: true,
        residenceProvince: true,
        residenceWard: true,
        user: {
          select: {
            userId: true,
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
            showCharityCampaignLocations: true,
            account: {
              select: {
                username: true,
                state: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });

    if (!profile) {
      return null;
    }

    return {
      ...profile,
      role: profile.user.role,
      curLongitude: profile.user.curLongitude,
      curLatitude: profile.user.curLatitude,
      visibilityMode: profile.user.visibilityMode,
      showCharityCampaignLocations: profile.user.showCharityCampaignLocations,
      account: profile.user.account,
    };
  }

  /**
   * Get public user profile (limited fields for visibility)
   */
  async getPublicProfile(userId: string) {
    const profile = await this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
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
        user: {
          select: {
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
          },
        },
      },
    });

    if (!profile) {
      return null;
    }

    return {
      ...profile,
      role: profile.user.role,
      curLongitude: profile.user.curLongitude,
      curLatitude: profile.user.curLatitude,
      visibilityMode: profile.user.visibilityMode,
    };
  }

  /**
   * Update user profile fields
   */
  async updateProfile(userId: string, data: Partial<any>) {
    const currentProfile = await this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      select: { profileId: true },
    });

    if (!currentProfile) {
      return null;
    }

    return this.prisma.profile.update({
      where: { profileId: currentProfile.profileId },
      data,
      include: {
        originProvince: true,
        originWard: true,
        residenceProvince: true,
        residenceWard: true,
        user: {
          select: {
            role: true,
            curLongitude: true,
            curLatitude: true,
            visibilityMode: true,
            showCharityCampaignLocations: true,
            account: {
              select: {
                username: true,
                state: true,
                createdAt: true,
              },
            },
          },
        },
      },
    });
  }

  /**
   * Update user location
   */
  async updateLocation(
    userId: string,
    longitude: number,
    latitude: number,
  ) {
    return this.prisma.user.update({
      where: { userId },
      data: {
        curLongitude: longitude,
        curLatitude: latitude,
      },
    });
  }

  /**
   * Update user FCM token (for Firebase push notifications)
   */
  async updateFcmToken(userId: string, fcmToken: string) {
    return this.prisma.user.update({
      where: { userId },
      data: { fcmToken },
    });
  }

  /**
   * Get all users with pagination (admin use)
   */
  async findAllPaginated(page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    const [profiles, total] = await Promise.all([
      this.prisma.profile.findMany({
        skip,
        take: limit,
        where: { isCurrent: true },
        select: {
          userId: true,
          fullname: true,
          nickname: true,
          avatarUrl: true,
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
          user: {
            select: {
              role: true,
            },
          },
        },
        orderBy: { fullname: 'asc' },
      }),
      this.prisma.profile.count({ where: { isCurrent: true } }),
    ]);

    const users = profiles.map((profile) => ({
      ...profile,
      role: profile.user.role,
    }));

    return { users, total, page, limit };
  }

  /**
   * Find users with PUBLIC visibility within radius
   */
  async findNearbyUsers(
    userId: string,
    latitude: number,
    longitude: number,
    radiusKm: number = 10,
  ) {
    const profiles = await this.prisma.profile.findMany({
      where: {
        isCurrent: true,
        user: {
          visibilityMode: 'PUBLIC',
          userId: { not: userId },
          curLongitude: { not: null },
          curLatitude: { not: null },
        },
      },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
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
        user: {
          select: {
            role: true,
            curLongitude: true,
            curLatitude: true,
          },
        },
      },
    });

    const users = profiles.map((profile) => ({
      ...profile,
      role: profile.user.role,
      curLongitude: profile.user.curLongitude,
      curLatitude: profile.user.curLatitude,
    }));

    return users.filter((user) => {
      if (!user.curLongitude || !user.curLatitude) return false;

      const distance = this.calculateDistance(
        latitude,
        longitude,
        Number(user.curLatitude),
        Number(user.curLongitude),
      );

      return distance <= radiusKm;
    });
  }

  /**
   * Find users by ward code
   */
  async findUsersByWard(wardCode: number) {
    const profiles = await this.prisma.profile.findMany({
      where: {
        isCurrent: true,
        residenceWardCode: wardCode,
      },
      select: {
        userId: true,
        fullname: true,
        user: {
          select: { fcmToken: true },
        },
      },
    });

    return profiles.map((profile) => ({
      userId: profile.userId,
      fullname: profile.fullname,
      fcmToken: profile.user.fcmToken,
    }));
  }

  async findAuthoritiesByWard(wardCode: number) {
    const profiles = await this.prisma.profile.findMany({
      where: {
        isCurrent: true,
        residenceWardCode: wardCode,
        user: {
          role: { has: 'AUTHORITY' },
        },
      },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
      },
    });

    return profiles.map((profile) => ({
      userId: profile.userId,
      fullname: profile.fullname,
      nickname: profile.nickname,
    }));
  }

  async findUsersByIds(ids: string[]) {
    if (!ids || ids.length === 0) return [];
    return this.prisma.profile.findMany({
      where: { userId: { in: ids }, isCurrent: true },
      select: { userId: true, fullname: true, nickname: true },
    });
  }

  /**
   * Get users by role
   */
  async findUsersByRole(role: string) {
    const profiles = await this.prisma.profile.findMany({
      where: {
        isCurrent: true,
        user: {
          role: { has: role },
        },
      },
      select: {
        userId: true,
        fullname: true,
        residenceWardCode: true,
        user: {
          select: { role: true },
        },
      },
    });

    return profiles.map((profile) => ({
      userId: profile.userId,
      fullname: profile.fullname,
      role: profile.user.role,
      residenceWardCode: profile.residenceWardCode,
    }));
  }

  /**
   * Check if user exists
   */
  async exists(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      select: { userId: true },
    });
    return !!user;
  }

  async findUserByEmail(email: string) {
    const account = await this.prisma.account.findUnique({
      where: { username: email },
      include: {
        user: {
          include: {
            profiles: {
              where: { isCurrent: true },
            },
          },
        },
      },
    });

    if (!account) return null;
    return account.user;
  }

  async getVisibility(userId: string) {
    return this.prisma.user.findUnique({
      where: { userId },
      select: { visibilityMode: true },
    });
  }

  async updateVisibility(userId: string, visibilityMode: string) {
    return this.prisma.user.update({
      where: { userId },
      data: { visibilityMode },
    });
  }

  async updateUserFields(userId: string, data: Record<string, unknown>) {
    return this.prisma.user.update({
      where: { userId },
      data,
    });
  }

  /**
   * Base CRUD methods - not typically used for User
   */
  async findById(id: string) {
    return this.getPublicProfile(id);
  }

  async findAll() {
    const profiles = await this.prisma.profile.findMany({
      where: { isCurrent: true },
      select: {
        userId: true,
        fullname: true,
        user: {
          select: { role: true },
        },
      },
    });

    return profiles.map((profile) => ({
      userId: profile.userId,
      fullname: profile.fullname,
      role: profile.user.role,
    }));
  }

  async create(data: any) {
    throw new Error('User creation should use AuthService');
  }

  async update(id: string, data: any) {
    return this.updateProfile(id, data);
  }

  async delete(id: string) {
    throw new Error('User deletion not implemented');
  }

  async count() {
    return this.prisma.user.count();
  }

  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371;
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
}
