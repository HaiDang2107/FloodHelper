import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import {
  CreateRoleRequestDto,
  ListRoleRequestsDto,
  RespondRoleRequestDto,
} from './dto';

@Injectable()
export class RoleRequestService {
  private prisma: PrismaClient;

  constructor() {
    this.prisma = new PrismaClient();
  }

  async createRequest(userId: string, dto: CreateRoleRequestDto) {
    const user = await this.prisma.user.findUnique({
      where: { userId },
      select: {
        userId: true,
        role: true,
        fullname: true,
        nickname: true,
        dob: true,
        gender: true,
        phoneNumber: true,
        jobPosition: true,
        citizenId: true,
        placeOfOrigin: true,
        placeOfResidence: true,
        dateOfIssue: true,
        dateOfExpire: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const missingFields = this.getMissingProfileFields(user);
    if (missingFields.length > 0) {
      throw new BadRequestException(
        `Profile is incomplete. Missing required fields: ${missingFields.join(', ')}`,
      );
    }

    if (user.role.includes(dto.type)) {
      throw new ConflictException(`User already has role ${dto.type}`);
    }

    const existingPending = await this.prisma.roleUpdatingRequest.findFirst({
      where: {
        createdBy: userId,
        type: dto.type as any,
        state: 'PENDING' as any,
      },
      select: { requestId: true },
    });

    if (existingPending) {
      throw new ConflictException(
        `You already have a pending ${dto.type.toLowerCase()} request`,
      );
    }

    const authority = await this.prisma.user.findFirst({
      where: {
        role: { has: 'AUTHORITY' },
        placeOfResidence: user.placeOfResidence,
      },
      select: { userId: true },
    });

    if (!authority) {
      throw new NotFoundException(
        'No authority found for your place of residence',
      );
    }

    const request = await this.prisma.roleUpdatingRequest.create({
      data: {
        createdBy: userId,
        checkBy: authority.userId,
        type: dto.type as any,
        state: 'PENDING' as any,
      },
    });

    return request;
  }
  
  async listForRequester(requesterUserId: string, _dto: ListRoleRequestsDto) {
    const items = await this.prisma.roleUpdatingRequest.findMany({
      where: { createdBy: requesterUserId },
      orderBy: { createdAt: 'desc' },
    });

    return { items };
  }

  async listForAuthority(authorityUserId: string, dto: ListRoleRequestsDto) {
    const cursorTime = dto.beforeCreatedAt
      ? new Date(dto.beforeCreatedAt)
      : new Date();

    const windowStart = new Date(
      cursorTime.getTime() - 7 * 24 * 60 * 60 * 1000,
    );

    const where: any = {
      checkBy: authorityUserId,
      createdAt: {
        gt: windowStart,
        lte: cursorTime,
      },
    };

    const items = await this.prisma.roleUpdatingRequest.findMany({
      where,
      include: {
        user: {
          select: {
            userId: true,
            fullname: true,
            dob: true,
            gender: true,
            phoneNumber: true,
            placeOfOrigin: true,
            placeOfResidence: true,
            jobPosition: true,
            citizenId: true,
            citizenIdCardImg: true,
            role: true,
            account: {
              select: {
                username: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const hasOlderOutsideWindow =
      (await this.prisma.roleUpdatingRequest.count({
        where: {
          checkBy: authorityUserId,
          createdAt: { lte: windowStart },
        },
      })) > 0;

    return {
      items,
      pagination: {
        hasMore: hasOlderOutsideWindow,
        nextCursor: hasOlderOutsideWindow ? windowStart.toISOString() : null,
      },
    };
  }

  async approve(
    authorityUserId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    return this.respond(authorityUserId, requestId, 'APPROVED', dto);
  }

  async reject(
    authorityUserId: string,
    requestId: string,
    dto: RespondRoleRequestDto,
  ) {
    return this.respond(authorityUserId, requestId, 'REJECTED', dto);
  }

  private async respond(
    authorityUserId: string,
    requestId: string,
    nextState: 'APPROVED' | 'REJECTED',
    dto: RespondRoleRequestDto,
  ) {
    const existing = await this.prisma.roleUpdatingRequest.findUnique({
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
      throw new NotFoundException('Role request not found');
    }

    if (existing.checkBy && existing.checkBy !== authorityUserId) {
      throw new ForbiddenException('You are not assigned to this request');
    }

    if (existing.state !== ('PENDING' as any)) {
      throw new ConflictException('Only pending requests can be processed');
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.roleUpdatingRequest.update({
        where: { requestId },
        data: {
          state: nextState as any,
          responsedAt: new Date(),
          note: dto.note ?? existing.note,
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
                set: [
                  ...existing.user.role,
                  existing.type as unknown as string,
                ],
              },
            },
          });
        }
      }

      return updated;
    });

    return result;
  }

  private getMissingProfileFields(user: any): string[] {
    const required: Record<string, any> = {
      fullname: user.fullname,
      nickname: user.nickname,
      dob: user.dob,
      gender: user.gender,
      phoneNumber: user.phoneNumber,
      citizenId: user.citizenId,
      placeOfOrigin: user.placeOfOrigin,
      placeOfResidence: user.placeOfResidence,
      dateOfIssue: user.dateOfIssue,
      dateOfExpire: user.dateOfExpire,
    };

    return Object.entries(required)
      .filter(([, value]) => {
        if (value === null || value === undefined) return true;
        if (typeof value === 'string' && value.trim().length === 0) return true;
        return false;
      })
      .map(([field]) => field);
  }
}
