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
              where: {
                isCurrent: true
              },
              select: {
                fullname: true,
                nickname: true,
              }
            }
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
}
