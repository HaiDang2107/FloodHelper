import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { CreateUserDto, UpdateUserDto, UpdateLocationDto } from './dto';

@Injectable()
export class UserService {
  private prisma: PrismaClient;

  constructor() {
    this.prisma = new PrismaClient();
  }

  /**
   * Get current user profile by userId (from JWT)
   */
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
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
        name: true,
        displayName: true,
        avatarUrl: true,
        role: true,
        curLongitude: true,
        curLatitude: true,
        publicMapMode: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      userId: user.userId,
      name: user.name,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      roles: user.role,
      // Only include location if publicMapMode is true
      ...(user.publicMapMode && {
        longitude: user.curLongitude ? Number(user.curLongitude) : null,
        latitude: user.curLatitude ? Number(user.curLatitude) : null,
      }),
    };
  }

  /**
   * Update user profile
   */
  async update(userId: string, updateUserDto: UpdateUserDto) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const updated = await this.prisma.user.update({
      where: { userId },
      data: {
        displayName: updateUserDto.displayName,
        gender: updateUserDto.gender,
        dob: updateUserDto.dob ? new Date(updateUserDto.dob) : undefined,
        village: updateUserDto.village,
        district: updateUserDto.district,
        country: updateUserDto.country,
        curLongitude: updateUserDto.curLongitude,
        curLatitude: updateUserDto.curLatitude,
        publicMapMode: updateUserDto.publicMapMode,
        avatarUrl: updateUserDto.avatarUrl,
        citizenId: updateUserDto.citizenId,
        citizenIdCardImg: updateUserDto.citizenIdCardImg,
        jobPosition: updateUserDto.jobPosition,
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
        publicMapMode: updateLocationDto.publicMapMode,
      },
    });

    return {
      success: true,
      longitude: Number(updated.curLongitude),
      latitude: Number(updated.curLatitude),
      publicMapMode: updated.publicMapMode,
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
          name: true,
          displayName: true,
          avatarUrl: true,
          role: true,
          phoneNumber: true,
        },
        orderBy: { name: 'asc' },
      }),
      this.prisma.user.count(),
    ]);

    return {
      data: users.map(user => ({
        userId: user.userId,
        name: user.name,
        displayName: user.displayName,
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
  async findNearbyUsers(userId: string, longitude: number, latitude: number, radiusKm: number = 10) {
    // Get users with public location enabled
    const users = await this.prisma.user.findMany({
      where: {
        publicMapMode: true,
        userId: { not: userId }, // Exclude current user
        curLongitude: { not: null },
        curLatitude: { not: null },
      },
      select: {
        userId: true,
        name: true,
        displayName: true,
        avatarUrl: true,
        role: true,
        curLongitude: true,
        curLatitude: true,
      },
    });

    // Filter by distance (simple calculation - for production use PostGIS)
    const nearbyUsers = users.filter(user => {
      if (!user.curLongitude || !user.curLatitude) return false;
      const distance = this.calculateDistance(
        latitude,
        longitude,
        Number(user.curLatitude),
        Number(user.curLongitude),
      );
      return distance <= radiusKm;
    });

    return nearbyUsers.map(user => ({
      userId: user.userId,
      name: user.name,
      displayName: user.displayName,
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
      name: user.name,
      displayName: user.displayName,
      gender: user.gender ?? null,
      dob: user.dob ? user.dob.toISOString().split('T')[0] : null,
      village: user.village,
      district: user.district,
      country: user.country,
      roles: user.role,
      longitude: user.curLongitude ? Number(user.curLongitude) : null,
      latitude: user.curLatitude ? Number(user.curLatitude) : null,
      publicMapMode: user.publicMapMode,
      avatarUrl: user.avatarUrl,
      citizenId: user.citizenId,
      phoneNumber: user.phoneNumber,
      citizenIdCardImg: user.citizenIdCardImg,
      jobPosition: user.jobPosition,
      account: user.account ? {
        username: user.account.username,
        state: user.account.state,
        createdAt: user.account.createdAt,
      } : null,
    };
  }

  /**
   * Calculate distance between two points using Haversine formula
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}

