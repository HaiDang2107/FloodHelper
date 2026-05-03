import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * RoleRequestRepository - Handles RoleUpdatingRequest queries
 * Manages role promotion requests from users to authority
 */
@Injectable()
export class RoleRequestRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('RoleRequest');
  }

  /**
   * Create role request
   */
  async createRequest(data: any) {
    return this.prisma.roleUpdatingRequest.create({
      data: {
        createdBy: data.createdBy,
        checkBy: data.checkBy,
        type: data.type,
        state: data.state || 'PENDING',
        note: data.note,
      },
    });
  }

  async getRequestForCreation(userId: string) {
    return this.prisma.user.findUnique({
      where: { userId },
      select: {
        userId: true,
        role: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
        dob: true,
        gender: true,
        phoneNumber: true,
        jobPosition: true,
        citizenId: true,
        frontCitizenIdCardImageUrl: true,
        backCitizenIdCardImageUrl: true,
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
        dateOfIssue: true,
        dateOfExpire: true,
      },
    });
  }

  /**
   * Get role request by ID
   */
  async getRequest(requestId: string) {
    return this.prisma.roleUpdatingRequest.findUnique({
      where: { requestId },
      include: {
        user: {
          select: {
            userId: true,
            fullname: true,
            avatarUrl: true,
            role: true,
          },
        },
      },
    });
  }

  /**
   * List requests for requester (my requests)
   */
  async listRequestsForRequester(userId: string) {
    return this.prisma.roleUpdatingRequest.findMany({
      where: { createdBy: userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * List requests for authority (assigned to review) - cursor-based
   */
  async listRequestsForAuthority(
    authorityUserId: string,
    limit: number = 10,
    beforeCreatedAt?: Date,
  ) {
    const rows = await this.prisma.roleUpdatingRequest.findMany({
      where: {
        checkBy: authorityUserId,
        ...(beforeCreatedAt
          ? {
              createdAt: {
                lt: beforeCreatedAt,
              },
            }
          : {}),
      },
      include: {
        user: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            dob: true,
            gender: true,
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
            jobPosition: true,
            citizenId: true,
            citizenIdCardImg: true,
            frontCitizenIdCardImageUrl: true,
            backCitizenIdCardImageUrl: true,
            avatarUrl: true,
            dateOfIssue: true,
            dateOfExpire: true,
            role: true,
            account: {
              select: {
                username: true,
              },
            },
          },
        },
      },
      orderBy: [{ createdAt: 'desc' }, { requestId: 'desc' }],
      take: limit + 1,
    });

    const hasMore = rows.length > limit;
    const items = hasMore ? rows.slice(0, limit) : rows;
    const nextCursor = hasMore && items.length > 0
      ? items[items.length - 1].createdAt.toISOString()
      : null;

    return { items, hasMore, nextCursor };
  }

  /**
   * Update request state (approve/reject)
   */
  async updateRequestState(requestId: string, state: string, note?: string) {
    return this.prisma.roleUpdatingRequest.update({
      where: { requestId },
      data: {
        state: state as any,
        responsedAt: new Date(),
        note,
      },
      include: {
        user: {
          select: {
            userId: true,
            fullname: true,
            role: true,
          },
        },
      },
    });
  }

  /**
   * Check for existing pending request
   */
  async findPendingRequest(userId: string, type: string) {
    return this.prisma.roleUpdatingRequest.findFirst({
      where: {
        createdBy: userId,
        type: type as any,
        state: 'PENDING' as any,
      },
      select: { requestId: true },
    });
  }

  async getRequestWithUser(requestId: string) {
    return this.prisma.roleUpdatingRequest.findUnique({
      where: { requestId },
      include: {
        user: {
          select: {
            userId: true,
            role: true,
            fullname: true,
            nickname: true,
          },
        },
      },
    });
  }

  async respondRequest(
    authorityUserId: string,
    requestId: string,
    nextState: 'APPROVED' | 'REJECTED',
    note?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.roleUpdatingRequest.findUnique({
        where: { requestId },
        include: {
          user: {
            select: {
              userId: true,
              role: true,
            },
          },
        },
      });

      if (!existing) {
        return null;
      }

      const updated = await tx.roleUpdatingRequest.update({
        where: { requestId },
        data: {
          state: nextState as any,
          responsedAt: new Date(),
          note,
        },
        include: {
          user: {
            select: {
              userId: true,
              fullname: true,
              nickname: true,
              role: true,
            },
          },
        },
      });

      if (nextState === 'APPROVED') {
        const hasRole = existing.user.role.includes(
          existing.type as unknown as string,
        );

        if (!hasRole) {
          await tx.user.update({
            where: { userId: existing.createdBy },
            data: {
              role: {
                set: [...existing.user.role, existing.type as unknown as string],
              },
            },
          });
        }
      }

      return updated;
    });
  }

  /**
   * List requests by state
   */
  async listRequestsByState(state: string) {
    return this.prisma.roleUpdatingRequest.findMany({
      where: { state: state as any },
      include: {
        user: {
          select: { userId: true, fullname: true, role: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Delete request (reject + cleanup)
   */
  async deleteRequest(requestId: string) {
    return this.prisma.roleUpdatingRequest.delete({
      where: { requestId },
    });
  }

  // Base CRUD methods
  async findById(id: string) {
    return this.getRequest(id);
  }

  async findAll() {
    return this.prisma.roleUpdatingRequest.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: any) {
    return this.createRequest(data);
  }

  async update(id: string, data: any) {
    return this.updateRequestState(id, data.state, data.note);
  }

  async delete(id: string) {
    return this.deleteRequest(id);
  }

  async count() {
    return this.prisma.roleUpdatingRequest.count();
  }
}
