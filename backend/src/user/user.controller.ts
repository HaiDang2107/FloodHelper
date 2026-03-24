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
} from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto, UpdateLocationDto, UpdateVisibilityDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

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
  async updateProfile(@Request() req, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(req.user.userId, updateUserDto);
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
