import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Query,
  UseGuards,
  Request,
  ParseUUIDPipe,
  UploadedFiles,
  UseInterceptors,
  BadRequestException,
} from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { UserService } from './user.service';
import { UpdateUserDto, UpdateLocationDto, UpdateVisibilityDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { UploadedFilePayload } from '../common/uploaded-file.type';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../common/enum/userRole.enum';
import { ListRoleRequestsDto, RespondRoleRequestDto } from '../role-request/dto';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  /**
   * Get current user's profile
   * GET /user/profile
   */
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getProfile(@Request() req) {
    return this.userService.getProfile(req.user.userId);
  }

  /**
   * Update current user's profile
   * PATCH /user/profile
   */
  @UseGuards(JwtAuthGuard)
  @Patch('profile')
  @UseInterceptors(
    FileFieldsInterceptor(
      [
        { name: 'avatar', maxCount: 1 },
        { name: 'citizenFront', maxCount: 1 },
        { name: 'citizenBack', maxCount: 1 },
        { name: 'rescuerCertificate', maxCount: 1 },
      ],
      {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
      fileFilter: (_req, file, cb) => {
        const imageFields = ['avatar', 'citizenFront', 'citizenBack'];
        const allowedImages = ['image/jpeg', 'image/png', 'image/webp'];

        if (imageFields.includes(file.fieldname)) {
          if (!allowedImages.includes(file.mimetype)) {
            cb(new BadRequestException('Only JPG, PNG, or WebP images are allowed'), false);
            return;
          }
          cb(null, true);
          return;
        }

        if (file.fieldname === 'rescuerCertificate') {
          if (file.mimetype !== 'application/pdf') {
            cb(new BadRequestException('Only PDF files are allowed'), false);
            return;
          }
          cb(null, true);
          return;
        }

        cb(new BadRequestException('Unsupported upload field'), false);
      },
      },
    ),
  )
  async updateProfile(
    @Request() req,
    @Body() body: Record<string, unknown> = {},
    @UploadedFiles()
    files: {
      avatar?: UploadedFilePayload[];
      citizenFront?: UploadedFilePayload[];
      citizenBack?: UploadedFilePayload[];
      rescuerCertificate?: UploadedFilePayload[];
    } = {},
  ) {
    const updateUserDto = this.parseUpdateUserDto(body);

    return this.userService.update(
      req.user.userId,
      updateUserDto,
      files.avatar?.[0],
      files.citizenFront?.[0],
      files.citizenBack?.[0],
      files.rescuerCertificate?.[0],
    );
  }

  /**
   * Create a profile updating request (Benefactor/Rescuer only)
   * POST /user/profile/update-requests
   */
  @UseGuards(JwtAuthGuard)
  @Post('profile/update-requests')
  @UseInterceptors(
    FileFieldsInterceptor(
      [
        { name: 'avatar', maxCount: 1 },
        { name: 'citizenFront', maxCount: 1 },
        { name: 'citizenBack', maxCount: 1 },
        { name: 'rescuerCertificate', maxCount: 1 },
      ],
      {
        storage: memoryStorage(),
        limits: { fileSize: 5 * 1024 * 1024 },
        fileFilter: (_req, file, cb) => {
          const imageFields = ['avatar', 'citizenFront', 'citizenBack'];
          const allowedImages = ['image/jpeg', 'image/png', 'image/webp'];

          if (imageFields.includes(file.fieldname)) {
            if (!allowedImages.includes(file.mimetype)) {
              cb(new BadRequestException('Only JPG, PNG, or WebP images are allowed'), false);
              return;
            }
            cb(null, true);
            return;
          }

          if (file.fieldname === 'rescuerCertificate') {
            if (file.mimetype !== 'application/pdf') {
              cb(new BadRequestException('Only PDF files are allowed'), false);
              return;
            }
            cb(null, true);
            return;
          }

          cb(new BadRequestException('Unsupported upload field'), false);
        },
      },
    ),
  )
  async createProfileUpdateRequest(
    @Request() req,
    @Body() body: Record<string, unknown> = {},
    @UploadedFiles()
    files: {
      avatar?: UploadedFilePayload[];
      citizenFront?: UploadedFilePayload[];
      citizenBack?: UploadedFilePayload[];
      rescuerCertificate?: UploadedFilePayload[];
    } = {},
  ) {
    const updateUserDto = this.parseUpdateUserDto(body);

    const result = await this.userService.createProfileUpdateRequest(
      req.user.userId,
      updateUserDto,
      files.avatar?.[0],
      files.citizenFront?.[0],
      files.citizenBack?.[0],
      files.rescuerCertificate?.[0],
    );

    return {
      success: true,
      message: 'Profile update request created successfully',
      data: result,
    };
  }

  /**
   * Get current user's profile update requests
   * GET /user/profile/update-requests
   */
  @UseGuards(JwtAuthGuard)
  @Get('profile/update-requests')
  async listProfileUpdateRequests(@Request() req) {
    const result = await this.userService.listProfileUpdateRequests(req.user.userId);
    return {
      success: true,
      message: 'Profile update requests retrieved successfully',
      data: result,
    };
  }

  /**
   * Revoke profile update request
   * PATCH /user/profile/update-requests/:id/revoke
   */
  @UseGuards(JwtAuthGuard)
  @Patch('profile/update-requests/:id/revoke')
  async revokeProfileUpdateRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
  ) {
    const result = await this.userService.revokeProfileUpdateRequest(
      user.userId,
      requestId,
    );
    return {
      success: true,
      message: 'Profile update request revoked successfully',
      data: result,
    };
  }

  /**
   * Authority: List profile update requests
   * GET /user/authority/profile-update-requests
   */
  @Get('authority/profile-update-requests')
  @Roles(UserRole.AUTHORITY)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async listProfileUpdateRequestsForAuthority(
    @CurrentUser() user: any,
    @Query() query: ListRoleRequestsDto,
  ) {
    const result = await this.userService.listProfileUpdateRequestsForAuthority(
      user.userId,
      query,
    );
    return {
      success: true,
      message: 'Profile update requests retrieved successfully',
      data: result.items,
      pagination: result.pagination,
    };
  }

  /**
   * Authority: Approve profile update request
   * PATCH /user/authority/profile-update-requests/:id/approve
   */
  @Patch('authority/profile-update-requests/:id/approve')
  @Roles(UserRole.AUTHORITY)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async approveProfileUpdateRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
    @Body() dto: RespondRoleRequestDto,
  ) {
    const result = await this.userService.approveProfileUpdateRequest(
      user.userId,
      requestId,
      dto,
    );
    return {
      success: true,
      message: 'Profile update request approved successfully',
      data: result,
    };
  }

  /**
   * Authority: Reject profile update request
   * PATCH /user/authority/profile-update-requests/:id/reject
   */
  @Patch('authority/profile-update-requests/:id/reject')
  @Roles(UserRole.AUTHORITY)
  @UseGuards(JwtAuthGuard, RolesGuard)
  async rejectProfileUpdateRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
    @Body() dto: RespondRoleRequestDto,
  ) {
    const result = await this.userService.rejectProfileUpdateRequest(
      user.userId,
      requestId,
      dto,
    );
    return {
      success: true,
      message: 'Profile update request rejected successfully',
      data: result,
    };
  }

  /**
   * Update current user's location
   * PATCH /user/location
   */
  @UseGuards(JwtAuthGuard)
  @Patch('location')
  async updateLocation(
    @Request() req,
    @Body() updateLocationDto: UpdateLocationDto,
  ) {
    return this.userService.updateLocation(req.user.userId, updateLocationDto);
  }

  /**
   * Get nearby users (public map mode users)
   * GET /user/nearby?longitude=xxx&latitude=xxx&radius=xxx
   */
  @UseGuards(JwtAuthGuard)
  @Get('nearby')
  async findNearbyUsers(
    @Request() req,
    @Query('longitude') longitude: string,
    @Query('latitude') latitude: string,
    @Query('radius') radius?: string,
  ) {
    return this.userService.findNearbyUsers(
      req.user.userId,
      parseFloat(longitude),
      parseFloat(latitude),
      radius ? parseFloat(radius) : 10,
    );
  }

  /**
   * Get current user's location visibility
   * GET /user/visibility
   */
  @UseGuards(JwtAuthGuard)
  @Get('visibility')
  async getVisibility(@Request() req) {
    const result = await this.userService.getVisibility(req.user.userId);

    return {
      success: true,
      data: result,
    };
  }

  /**
   * Update location visibility (PUBLIC / JUST_FRIEND / NO_ONE)
   * PATCH /user/visibility
   */
  @UseGuards(JwtAuthGuard)
  @Patch('visibility')
  async updateVisibility(@Request() req, @Body() dto: UpdateVisibilityDto) {
    const result = await this.userService.updateVisibility(
      req.user.userId,
      dto,
    );

    return {
      success: true,
      message: 'Visibility updated',
      data: result,
    };
  }

  /**
   * PATCH /user/fcm-token
   * Update FCM token for push notifications
   */
  @UseGuards(JwtAuthGuard)
  @Patch('fcm-token')
  async updateFcmToken(
    @CurrentUser() user: any,
    @Body('fcmToken') fcmToken: string,
  ) {
    await this.userService.updateFcmToken(user.userId, fcmToken);

    return {
      success: true,
      message: 'FCM token updated successfully',
    };
  }

  /**
   * Get all users (paginated)
   * GET /user?page=1&limit=20
   */
  @UseGuards(JwtAuthGuard)
  @Get()
  async findAll(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.userService.findAll(
      page ? parseInt(page) : 1,
      limit ? parseInt(limit) : 20,
    );
  }

  /**
   * Get user by ID (public profile)
   * GET /user/:id
   */
  @UseGuards(JwtAuthGuard)
  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.userService.findOne(id);
  }

  private parseUpdateUserDto(body: Record<string, unknown> = {}): UpdateUserDto {
    const safeBody = body ?? {};

    return {
      ...safeBody,
      originProvinceCode:
        safeBody.originProvinceCode != null
          ? Number(safeBody.originProvinceCode)
          : undefined,
      originWardCode:
        safeBody.originWardCode != null
          ? Number(safeBody.originWardCode)
          : undefined,
      residenceProvinceCode:
        safeBody.residenceProvinceCode != null
          ? Number(safeBody.residenceProvinceCode)
          : undefined,
      residenceWardCode:
        safeBody.residenceWardCode != null
          ? Number(safeBody.residenceWardCode)
          : undefined,
      curLongitude:
        safeBody.curLongitude != null
          ? Number(safeBody.curLongitude)
          : undefined,
      curLatitude:
        safeBody.curLatitude != null ? Number(safeBody.curLatitude) : undefined,
      showCharityCampaignLocations:
        safeBody.showCharityCampaignLocations != null
          ? String(safeBody.showCharityCampaignLocations).toLowerCase() === 'true'
          : undefined,
    };
  }
}
