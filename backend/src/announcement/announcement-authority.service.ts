import { Injectable, BadRequestException, ForbiddenException, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { PublicAnnouncementType } from '@prisma/client';
import { extname } from 'node:path';
import { CloudinaryService } from '../common/cloudinary.service';
import { AnnouncementRepository, UserRepository } from '../prisma/repositories';
import { FirebaseService } from '../firebase/firebase.service';
import { CreateAnnouncementDto, QueryAnnouncementsDto } from './dto';
import type { UploadedFilePayload } from '../common/uploaded-file.type';

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
export class AnnouncementAuthorityService {
  private readonly logger = new Logger(AnnouncementAuthorityService.name);

  constructor(
    private readonly announcementRepository: AnnouncementRepository,
    private readonly userRepository: UserRepository,
    private readonly cloudinaryService: CloudinaryService,
    private readonly firebaseService: FirebaseService,
  ) {}

  async publishAuthorityAnnouncement(
    authorityUserId: string,
    dto: CreateAnnouncementDto,
    file?: UploadedFilePayload,
  ) {
    await this.assertAuthorityUser(authorityUserId);

    const created = await this.announcementRepository.createAnnouncement({
      title: dto.title.trim(),
      caption: dto.caption.trim(),
      documentUrl: null,
      publishedBy: authorityUserId,
      type: 'AUTHORITY',
    });

    let uploadedUrl: string | null = null;

    try {
      const announcement = file
        ? await this.attachAnnouncementDocument(
            authorityUserId,
            created.announcementId,
            file,
          )
        : created;

      if (file) {
        uploadedUrl = announcement.documentUrl;
      }

      await this.notifyWardUsers(authorityUserId, announcement);
      return this.toResponse(announcement);
    } catch (error) {
      this.logger.error(`Failed to publish authority announcement: ${String(error)}`);
      if (uploadedUrl) {
        await this.safeDeleteCloudinaryAsset(uploadedUrl);
      }
      await this.announcementRepository
        .deleteAnnouncement(created.announcementId)
        .catch(() => undefined);
      throw new InternalServerErrorException('Failed to publish announcement');
    }
  }

  async listAuthorityAnnouncements(
    authorityUserId: string,
    query: QueryAnnouncementsDto,
  ) {
    await this.assertAuthorityUser(authorityUserId);

    const rawLimit = Number(query.limit ?? 10);
    const limit = Number.isFinite(rawLimit)
      ? Math.min(Math.max(Math.floor(rawLimit), 1), 50)
      : 10;
    const beforeCreatedAt = query.beforeCreatedAt
      ? new Date(query.beforeCreatedAt)
      : null;

    const { items, hasMore, nextCursor } = await this.announcementRepository.listAuthorityAnnouncements(
      authorityUserId,
      limit,
      beforeCreatedAt ?? undefined,
    );

    return {
      items: items.map((item) => this.toResponse(item)),
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  async getAuthorityAnnouncement(authorityUserId: string, announcementId: string) {
    await this.assertAuthorityUser(authorityUserId);
    const announcement = await this.announcementRepository.getAnnouncement(announcementId);

    if (!announcement || announcement.publishedBy !== authorityUserId || announcement.type !== 'AUTHORITY') {
      throw new NotFoundException('Announcement not found');
    }

    return this.toResponse(announcement);
  }

  async deleteAuthorityAnnouncement(authorityUserId: string, announcementId: string) {
    await this.assertAuthorityUser(authorityUserId);

    const announcement = await this.announcementRepository.getAnnouncement(announcementId);

    if (!announcement || announcement.publishedBy !== authorityUserId || announcement.type !== 'AUTHORITY') {
      throw new NotFoundException('Announcement not found');
    }

    if (announcement.documentUrl) {
      await this.safeDeleteCloudinaryAsset(announcement.documentUrl);
    }

    await this.announcementRepository.deleteAnnouncement(announcementId);

    return this.toResponse(announcement);
  }

  //==================PRIVATE===============================

  private async assertAuthorityUser(authorityUserId: string) {
    const authority = await this.userRepository.getPublicProfile(authorityUserId);

    if (!authority) {
      throw new NotFoundException('Authority account not found');
    }

    if (!authority.role.includes('AUTHORITY')) {
      throw new ForbiddenException('Only authority users can access this resource');
    }

    if (!authority.residenceWardCode) {
      throw new BadRequestException('Authority residence ward is required');
    }

    return authority;
  }

  private async notifyWardUsers(
    authorityUserId: string,
    announcement: ReturnType<AnnouncementAuthorityService['toResponse']>,
  ) {
    const authority = await this.userRepository.getPublicProfile(authorityUserId);

    if (!authority?.residenceWardCode) {
      return;
    }

    const tokens = await this.userRepository.findUsersByWard(authority.residenceWardCode);

    this.logger.debug(`Total users found in ward: ${tokens.length}`);

    const fcmTokens = tokens
      .map((item) => item.fcmToken)
      .filter((token): token is string => Boolean(token && token.trim().length > 0));

    this.logger.debug(`notifyWardUsers fcmTokens count: ${fcmTokens.length}`);
    this.logger.debug(`notifyWardUsers fcmTokens: ${JSON.stringify(fcmTokens)}`);

    if (fcmTokens.length === 0) {
      return;
    }

    await this.firebaseService.sendMulticastNotification(
      fcmTokens,
      announcement.title,
      announcement.caption ?? 'New announcement from authority',
      {
        announcementId: announcement.announcementId,
        announcementType: announcement.type,
      },
      'announcements_from_authority',
    );
  }

  private async safeDeleteCloudinaryAsset(documentUrl: string) {
    try {
      const publicId = this.getCloudinaryPublicId(documentUrl);
      await this.cloudinaryService.deleteRawFile(publicId);
    } catch (error) {
      this.logger.warn(`Failed to delete Cloudinary asset: ${String(error)}`);
    }
  }

  private getCloudinaryPublicId(documentUrl: string) {
    const url = new URL(documentUrl);
    const uploadIndex = url.pathname.indexOf('/upload/');

    if (uploadIndex === -1) {
      throw new BadRequestException('Invalid document URL');
    }

    const publicIdWithVersion = url.pathname.slice(uploadIndex + '/upload/'.length);
    return publicIdWithVersion.replace(/^v\d+\//, '');
  }

  private getFileExtension(fileName: string) {
    const extension = extname(fileName).trim().toLowerCase();
    if (!extension) {
      throw new BadRequestException('Announcement file must have an extension');
    }

    return extension;
  }

  private async attachAnnouncementDocument(
    authorityUserId: string,
    announcementId: string,
    file: UploadedFilePayload,
  ) {
    const fileExtension = this.getFileExtension(file.originalname);
    const uploadedUrl = await this.cloudinaryService.uploadRawFile(file.buffer, {
      folder: `floodhelper/announcements/${authorityUserId}`,
      publicId: `${announcementId}/document${fileExtension}`,
    });

    return this.announcementRepository.updateAnnouncement(announcementId, {
      documentUrl: uploadedUrl,
    });
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