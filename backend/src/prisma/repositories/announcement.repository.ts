import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * AnnouncementRepository - Handles PublicAnnouncement queries
 * Manages announcements from authority and normal users
 */
@Injectable()
export class AnnouncementRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Announcement');
  }

  /**
   * Create announcement
   */
  async createAnnouncement(data: any) {
    return this.prisma.publicAnnouncement.create({
      data: {
        title: data.title,
        caption: data.caption,
        documentUrl: data.documentUrl,
        publishedBy: data.publishedBy,
        publishedTo: data.publishedTo,
        type: data.type,
      },
    });
  }

  /**
   * Get announcement by ID
   */
  async getAnnouncement(announcementId: string) {
    return this.prisma.publicAnnouncement.findUnique({
      where: { announcementId },
    });
  }

  /**
   * List announcements for authority (cursor-based pagination)
   */
  async listAuthorityAnnouncements(
    authorityUserId: string,
    limit: number = 10,
    beforeCreatedAt?: Date,
  ) {
    const rows = await this.prisma.publicAnnouncement.findMany({
      where: {
        publishedBy: authorityUserId,
        type: 'AUTHORITY',
        ...(beforeCreatedAt
          ? {
              createdAt: {
                lt: beforeCreatedAt,
              },
            }
          : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { announcementId: 'desc' }],
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
   * List announcements for ward (user-facing)
   */
  async listWardAnnouncements(wardCode: number, limit: number = 20) {
    return this.prisma.publicAnnouncement.findMany({
      where: {
        type: 'AUTHORITY',
        // Can be extended to find authority by wardCode
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Update announcement
   */
  async updateAnnouncement(announcementId: string, data: any) {
    return this.prisma.publicAnnouncement.update({
      where: { announcementId },
      data,
    });
  }

  /**
   * Delete announcement
   */
  async deleteAnnouncement(announcementId: string) {
    return this.prisma.publicAnnouncement.delete({
      where: { announcementId },
    });
  }

  /**
   * List announcements by type
   */
  async listAnnouncementsByType(type: string, limit: number = 50) {
    return this.prisma.publicAnnouncement.findMany({
      where: { type: type as any },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async listPublicAnnouncements(where: any, limit: number, beforeCreatedAt?: Date) {
    return this.prisma.publicAnnouncement.findMany({
      where: {
        ...where,
        ...(beforeCreatedAt
          ? {
              createdAt: {
                lt: beforeCreatedAt,
              },
            }
          : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { announcementId: 'desc' }],
      take: limit + 1,
    });
  }

  // Base CRUD methods
  async findById(id: string) {
    return this.getAnnouncement(id);
  }

  async findAll() {
    return this.prisma.publicAnnouncement.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(data: any) {
    return this.createAnnouncement(data);
  }

  async update(id: string, data: any) {
    return this.updateAnnouncement(id, data);
  }

  async delete(id: string) {
    return this.deleteAnnouncement(id);
  }

  async count() {
    return this.prisma.publicAnnouncement.count();
  }
}
