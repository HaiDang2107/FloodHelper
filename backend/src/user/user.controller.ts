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
      ],
      {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
      fileFilter: (_req, file, cb) => {
        const allowed = ['image/jpeg', 'image/png', 'image/webp'];
        if (!allowed.includes(file.mimetype)) {
          cb(new BadRequestException('Only JPG, PNG, or WebP images are allowed'), false);
          return;
        }
        cb(null, true);
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
    } = {},
  ) {
    const safeBody = body ?? {};

    const updateUserDto: UpdateUserDto = {
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
          ? String(safeBody.showCharityCampaignLocations).toLowerCase() ===
            'true'
          : undefined,
    };

    return this.userService.update(
      req.user.userId,
      updateUserDto,
      files.avatar?.[0],
      files.citizenFront?.[0],
      files.citizenBack?.[0],
    );
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
}
