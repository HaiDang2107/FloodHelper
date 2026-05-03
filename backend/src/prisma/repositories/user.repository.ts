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
    return this.prisma.user.findUnique({
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
  }

  /**
   * Get public user profile (limited fields for visibility)
   */
  async getPublicProfile(userId: string) {
    return this.prisma.user.findUnique({
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
  }

  /**
   * Update user profile fields
   */
  async updateProfile(userId: string, data: Partial<any>) {
    return this.prisma.user.update({
      where: { userId },
      data,
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
    const users = await this.prisma.user.findMany({
      where: {
        visibilityMode: 'PUBLIC',
        userId: { not: userId },
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
    return this.prisma.user.findMany({
      where: { residenceWardCode: wardCode },
      select: {
        userId: true,
        fullname: true,
        fcmToken: true,
      },
    });
  }

  async findAuthoritiesByWard(wardCode: number) {
    return this.prisma.user.findMany({
      where: {
        residenceWardCode: wardCode,
        role: { has: 'AUTHORITY' },
      },
      select: {
        userId: true,
        fullname: true,
        nickname: true,
      },
    });
  }

  async findUsersByIds(ids: string[]) {
    if (!ids || ids.length === 0) return [];
    return this.prisma.user.findMany({
      where: { userId: { in: ids } },
      select: { userId: true, fullname: true, nickname: true },
    });
  }

  /**
   * Get users by role
   */
  async findUsersByRole(role: string) {
    return this.prisma.user.findMany({
      where: {
        role: { has: role },
      },
      select: {
        userId: true,
        fullname: true,
        role: true,
        residenceWardCode: true,
      },
    });
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

  /**
   * Base CRUD methods - not typically used for User
   */
  async findById(id: string) {
    return this.getPublicProfile(id);
  }

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        userId: true,
        fullname: true,
        role: true,
      },
    });
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
