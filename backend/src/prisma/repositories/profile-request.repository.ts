import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';
import { ProfileUpdatingRequest } from '@prisma/client';

@Injectable()
export class ProfileRequestRepository extends BaseRepository<ProfileUpdatingRequest> {
  constructor(private readonly prisma: PrismaService) {
    super('ProfileUpdatingRequest');
  }

  async findById(id: string) {
    return this.prisma.profileUpdatingRequest.findUnique({
      where: { requestId: id },
    });
  }

  async findAll() {
    return this.prisma.profileUpdatingRequest.findMany();
  }

  async create(data: any) {
    return this.prisma.profileUpdatingRequest.create({ data });
  }

  async update(id: string, data: any) {
    return this.prisma.profileUpdatingRequest.update({
      where: { requestId: id },
      data,
    });
  }

  async delete(id: string) {
    return this.prisma.profileUpdatingRequest.delete({
      where: { requestId: id },
    });
  }

  async count() {
    return this.prisma.profileUpdatingRequest.count();
  }

  async createRequest(data: {
    currentProfileId: string;
    newProfileId: string;
    checkedBy: string;
  }) {
    return this.prisma.profileUpdatingRequest.create({
      data: {
        currentProfileId: data.currentProfileId,
        newProfileId: data.newProfileId,
        checkedBy: data.checkedBy,
        state: 'PENDING' as any,
      },
    });
  }

  async listRequestsForRequester(userId: string) {
    return this.prisma.profileUpdatingRequest.findMany({
      where: {
        currentProfile: {
          userId,
        },
      },
      include: {
        checker: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, nickname: true },
            },
          },
        },
        currentProfile: {
          select: {
            fullname: true, nickname: true, gender: true, dob: true,
            occupation: true, citizenId: true, dateOfIssue: true, dateOfExpire: true,
            avatarUrl: true, frontCitizenIdCardImageUrl: true, backCitizenIdCardImageUrl: true,
            rescuerCertificateUrl: true, phoneNumber: true,
            originProvinceCode: true, originWardCode: true,
            residenceProvinceCode: true, residenceWardCode: true,
            originProvince: { select: { name: true } },
            originWard: { select: { name: true } },
            residenceProvince: { select: { name: true } },
            residenceWard: { select: { name: true } },
          },
        },
        newProfile: {
          select: {
            fullname: true, nickname: true, gender: true, dob: true,
            occupation: true, citizenId: true, dateOfIssue: true, dateOfExpire: true,
            avatarUrl: true, frontCitizenIdCardImageUrl: true, backCitizenIdCardImageUrl: true,
            rescuerCertificateUrl: true, phoneNumber: true,
            originProvinceCode: true, originWardCode: true,
            residenceProvinceCode: true, residenceWardCode: true,
            originProvince: { select: { name: true } },
            originWard: { select: { name: true } },
            residenceProvince: { select: { name: true } },
            residenceWard: { select: { name: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findPendingForUser(userId: string) {
    return this.prisma.profileUpdatingRequest.findFirst({
      where: {
        currentProfile: {
          userId,
        },
        state: 'PENDING' as any,
      },
      select: { requestId: true },
    });
  }

  async getRequestForRevoke(userId: string, requestId: string) {
    return this.prisma.profileUpdatingRequest.findFirst({
      where: {
        requestId,
        currentProfile: {
          userId,
        },
      },
    });
  }

  async revokeRequest(requestId: string) {
    return this.prisma.profileUpdatingRequest.update({
      where: { requestId },
      data: {
        state: 'REVOKED' as any,
        respondedAt: new Date(),
      },
    });
  }

  async listRequestsForAuthority(
    authorityId: string,
    limit: number,
    beforeCreatedAt?: Date,
    roleFilter?: 'BENEFACTOR' | 'RESCUER',
    stateFilter?: string,
  ) {
    const where: any = {
      checkedBy: authorityId,
      createdAt: beforeCreatedAt ? { lt: beforeCreatedAt } : undefined,
    };

    if (stateFilter) {
      where.state = stateFilter as any;
    }

    if (roleFilter) {
      where.currentProfile = {
        user: {
          role: {
            has: roleFilter,
          },
        },
      };
    }

    const items = await this.prisma.profileUpdatingRequest.findMany({
      where,
      include: {
        currentProfile: {
          include: {
            user: {
              include: {
                account: true,
              },
            },
            originProvince: true,
            originWard: true,
            residenceProvince: true,
            residenceWard: true,
          },
        },
        newProfile: {
          include: {
            originProvince: true,
            originWard: true,
            residenceProvince: true,
            residenceWard: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = items.length > limit;
    const finalItems = hasMore ? items.slice(0, limit) : items;
    const nextCursor = hasMore
      ? finalItems[finalItems.length - 1].createdAt
      : null;

    return {
      items: finalItems,
      hasMore,
      nextCursor,
    };
  }

  async getRequestWithProfiles(requestId: string) {
    return this.prisma.profileUpdatingRequest.findUnique({
      where: { requestId },
      include: {
        currentProfile: true,
        newProfile: true,
      },
    });
  }

  async respondRequest(
    authorityId: string,
    requestId: string,
    state: 'APPROVED' | 'REJECTED',
    note?: string,
  ) {
    return this.prisma.profileUpdatingRequest.update({
      where: { requestId },
      data: {
        state: state as any,
        note,
        respondedAt: new Date(),
      },
    });
  }

  async approveProfileUpdate(
    requestId: string,
    currentProfileId: string,
    newProfileId: string,
    note?: string,
  ) {
    return this.prisma.$transaction([
      // Update current profile to NOT current
      this.prisma.profile.update({
        where: { profileId: currentProfileId },
        data: { isCurrent: false },
      }),
      // Update new profile TO current
      this.prisma.profile.update({
        where: { profileId: newProfileId },
        data: { isCurrent: true },
      }),
      // Update request state
      this.prisma.profileUpdatingRequest.update({
        where: { requestId },
        data: {
          state: 'APPROVED' as any,
          note,
          respondedAt: new Date(),
        },
      }),
    ]);
  }
}
