import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enum/userRole.enum';
import {
  CreateAnnouncementDto,
  QueryAnnouncementsDto,
  QueryPublicAnnouncementsDto,
} from './dto';
import { AnnouncementAuthorityService } from './announcement-authority.service';
import { AnnouncementNoruserService } from './announcement-noruser.service';
import type { UploadedFilePayload } from '../common/uploaded-file.type';

@Controller('announcements')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AnnouncementController {
  constructor(
    private readonly announcementService: AnnouncementAuthorityService,
    private readonly announcementNoruserService: AnnouncementNoruserService,
  ) {}

  @Roles(UserRole.AUTHORITY)
  @Post('authority')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: 10 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        const allowed = [
          'application/pdf',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ];

        if (!allowed.includes(file.mimetype)) {
          cb(new BadRequestException('Only PDF, DOCX, or XLSX files are allowed'), false);
          return;
        }

        cb(null, true);
      },
    }),
  )
  async publishAuthorityAnnouncement(
    @CurrentUser() user: any,
    @Body() body: CreateAnnouncementDto,
    @UploadedFile() file?: UploadedFilePayload,
  ) {
    const data = await this.announcementService.publishAuthorityAnnouncement(
      user.userId,
      body,
      file,
    );

    return {
      success: true,
      message: 'Announcement published successfully',
      data,
    };
  }

  @Roles(UserRole.AUTHORITY)
  @Get('authority')
  async listAuthorityAnnouncements(
    @CurrentUser() user: any,
    @Query() query: QueryAnnouncementsDto,
  ) {
    const data = await this.announcementService.listAuthorityAnnouncements(
      user.userId,
      query,
    );

    return {
      success: true,
      message: 'Authority announcements retrieved successfully',
      data,
    };
  }

  @Get('public')
  async listPublicAnnouncements(
    @CurrentUser() user: any,
    @Query() query: QueryPublicAnnouncementsDto,
  ) {
    const data = await this.announcementNoruserService.listPublicAnnouncementsForUser(
      user.userId,
      query,
    );

    return {
      success: true,
      message: 'Public announcements retrieved successfully',
      data,
    };
  }

  @Roles(UserRole.AUTHORITY)
  @Get('authority/:announcementId')
  async getAuthorityAnnouncement(
    @CurrentUser() user: any,
    @Param('announcementId') announcementId: string,
  ) {
    const data = await this.announcementService.getAuthorityAnnouncement(
      user.userId,
      announcementId,
    );

    return {
      success: true,
      message: 'Authority announcement retrieved successfully',
      data,
    };
  }

  @Roles(UserRole.AUTHORITY)
  @Delete('authority/:announcementId')
  async deleteAuthorityAnnouncement(
    @CurrentUser() user: any,
    @Param('announcementId') announcementId: string,
  ) {
    const data = await this.announcementService.deleteAuthorityAnnouncement(
      user.userId,
      announcementId,
    );

    return {
      success: true,
      message: 'Authority announcement deleted successfully',
      data,
    };
  }
}