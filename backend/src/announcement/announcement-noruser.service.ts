import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PublicAnnouncementType } from '@prisma/client';
import { AnnouncementRepository, UserRepository } from '../prisma/repositories';
import { QueryPublicAnnouncementsDto } from './dto';

type AnnouncementListPayload = {
  announcementId: string;
  title: string;
  caption: string | null;
  documentUrl: string | null;
  createdAt: Date;
  publishedBy: string;
  type: PublicAnnouncementType;
};

@Injectable()
export class AnnouncementNoruserService {
  constructor(
    private readonly announcementRepository: AnnouncementRepository,
    private readonly userRepository: UserRepository,
  ) {}

  async listPublicAnnouncementsForUser(
    userId: string,
    query: QueryPublicAnnouncementsDto,
  ) {
    const limit = this.normalizeLimit(query.limit);
    const beforeCreatedAt = this.parseBeforeCreatedAt(query.beforeCreatedAt);

    const where: {
      type?: PublicAnnouncementType;
      createdAt?: { lt: Date };
      publishedBy?: string;
      publishedTo?: string;
    } = {};

    // Thêm thuộc tính cho bộ lọc where
    if (query.type) {
      where.type = query.type;
    }

    if (beforeCreatedAt) {
      where.createdAt = { lt: beforeCreatedAt };
    }

    if (query.type === 'DAILY') {
      where.publishedTo = userId;
    }

    if (query.type === 'AUTHORITY') {
      const wardId = await this.resolveWardForAuthorityAnnouncements(userId, query.wardId);
      if (!wardId) {
        // user chưa khai ward ==> trả về null
        return {
          items: [],
          pagination: {
            hasMore: false,
            nextCursor: null,
          },
        };
      }

      const authority = (await this.userRepository.findAuthoritiesByWard(wardId))[0];

      if (!authority) {
        // không thấy authority ==> trả về null
        return {
          items: [],
          pagination: {
            hasMore: false,
            nextCursor: null,
          },
        };
      }

      where.publishedBy = authority.userId;
    }

    const rows = await this.announcementRepository.listPublicAnnouncements(
      where,
      limit,
      beforeCreatedAt ?? undefined,
    );

    const hasMore = rows.length > limit;
    const items = hasMore ? rows.slice(0, limit) : rows;
    const nextCursor =
      hasMore && items.length > 0
        ? items[items.length - 1].createdAt.toISOString()
        : null;

    return {
      items: items.map((item) => this.toResponse(item)),
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  //==================PRIVATE===============================

  private normalizeLimit(limit?: number) {
    const rawLimit = Number(limit ?? 10);
    return Number.isFinite(rawLimit)
      ? Math.min(Math.max(Math.floor(rawLimit), 1), 50)
      : 10;
  }

  private parseBeforeCreatedAt(beforeCreatedAt?: string) {
    if (!beforeCreatedAt) {
      return null;
    }

    const parsed = new Date(beforeCreatedAt);
    if (Number.isNaN(parsed.getTime())) {
      throw new BadRequestException('beforeCreatedAt must be a valid ISO datetime');
    }

    return parsed;
  }

  private async resolveWardForAuthorityAnnouncements(userId: string, wardId?: number) {
    if (typeof wardId === 'number') {
      return wardId;
    }

    const user = await this.userRepository.getPublicProfile(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user.residenceWardCode;
  }

  private announcementSelect() {
    return {
      announcementId: true,
      title: true,
      caption: true,
      documentUrl: true,
      createdAt: true,
      publishedBy: true,
      type: true,
    } as const;
  }

  private toResponse(announcement: AnnouncementListPayload) {
    return {
      announcementId: announcement.announcementId,
      title: announcement.title,
      caption: announcement.caption,
      documentUrl: announcement.documentUrl,
      createdAt: announcement.createdAt,
      publishedBy: announcement.publishedBy,
      type: String(announcement.type).toUpperCase(),
    };
  }
}
