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
        profileId: data.profileId,
        checkBy: data.checkBy,
        type: data.type,
        state: data.state || 'PENDING',
        note: data.note,
      },
    });
  }

  async getRequestForCreation(userId: string) { // Cần trả về nhiều trường để xem có miss trường nào không
    const profile = await this.prisma.profile.findFirst({
      where: { userId, isCurrent: true },
      select: {
        profileId: true,
        userId: true,
        fullname: true,
        nickname: true,
        avatarUrl: true,
        dob: true,
        gender: true,
        phoneNumber: true,
        occupation: true,
        citizenId: true,
        rescuerCertificateUrl: true,
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
        user: {
          select: {
            role: true,
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
    };
  }

  /**
   * Get role request by ID
   */
  async getRequest(requestId: string) {
    return this.prisma.roleUpdatingRequest.findUnique({
      where: { requestId },
      include: {
        profile: {
          select: {
            userId: true,
            fullname: true,
            avatarUrl: true,
            user: {
              select: {
                role: true,
              },
            },
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
      where: {
        profile: {
          userId,
        },
      },
      include: {
        authority: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
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
        profile: {
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
            occupation: true,
            citizenId: true,
            rescuerCertificateUrl: true,
            frontCitizenIdCardImageUrl: true,
            backCitizenIdCardImageUrl: true,
            avatarUrl: true,
            dateOfIssue: true,
            dateOfExpire: true,
            user: {
              select: {
                role: true,
                account: {
                  select: {
                    username: true,
                  },
                },
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
        profile: {
          select: {
            userId: true,
            fullname: true,
            user: {
              select: {
                role: true,
              },
            },
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
        profile: {
          userId,
        },
        type: type as any,
        state: 'PENDING' as any,
      },
      select: { requestId: true },
    });
  }

  async findAnyPendingRequest(userId: string) {
    return this.prisma.roleUpdatingRequest.findFirst({
      where: {
        profile: {
          userId,
        },
        state: 'PENDING' as any,
      },
      select: { requestId: true },
    });
  }

  async getRequestWithUser(requestId: string) {
    return this.prisma.roleUpdatingRequest.findUnique({
      where: { requestId },
      include: {
        profile: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            user: {
              select: {
                role: true,
              },
            },
          },
        },
      },
    });
  }

  async respondRequest( // Xử lý một Role Request
    authorityUserId: string,
    requestId: string,
    nextState: 'APPROVED' | 'REJECTED',
    note?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      // find request dựa trên requestId
      const existing = await tx.roleUpdatingRequest.findUnique({
        where: { requestId },
        include: {
          profile: {
            select: {
              userId: true,
              user: {
                select: {
                  role: true,
                },
              },
            },
          },
        },
      });

      if (!existing) {
        return null;
      }

      // Cập nhật request
      const updated = await tx.roleUpdatingRequest.update({
        where: { requestId },
        data: {
          state: nextState as any,
          responsedAt: new Date(),
          checkBy: authorityUserId,
          note,
        },

        include: {
          profile: {
            select: {
              userId: true,
              fullname: true,
              nickname: true,
              user: {
                select: {
                  role: true,
                },
              },
            },
          },
        },

      });

      // Nếu approve request thì thêm role cho user
      if (nextState === 'APPROVED') {
        const hasRole = existing.profile.user.role.includes(
          existing.type as unknown as string,
        );

        if (!hasRole) {
          await tx.user.update({
            where: { userId: existing.profile.userId },
            data: {
              role: {
                set: [
                  ...existing.profile.user.role,
                  existing.type as unknown as string,
                ],
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
        profile: {
          select: {
            userId: true,
            fullname: true,
            user: {
              select: { role: true },
            },
          },
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
