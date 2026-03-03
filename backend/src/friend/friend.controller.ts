import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { FriendService } from './friend.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { SendFriendRequestDto } from './dto';

@Controller('friend')
@UseGuards(JwtAuthGuard)
export class FriendController {
  constructor(private readonly friendService: FriendService) {}

  /**
   * POST /friend/request
   * Send a friend request
   */
  @Post('request')
  async sendFriendRequest(
    @CurrentUser() user: any,
    @Body() dto: SendFriendRequestDto,
  ) {
    const result = await this.friendService.sendFriendRequest(
      user.userId,
      dto.receiverId,
      dto.note,
    );

    return {
      success: true,
      message: 'Friend request sent successfully',
      data: result,
    };
  }

  /**
   * GET /friend/requests/sent
   * Get all sent friend requests
   */
  @Get('requests/sent')
  async getSentRequests(@CurrentUser() user: any) {
    const requests = await this.friendService.getSentRequests(user.userId);

    return {
      success: true,
      message: 'Sent requests retrieved successfully',
      data: requests,
    };
  }

  /**
   * GET /friend/requests/received
   * Get all received friend requests
   */
  @Get('requests/received')
  async getReceivedRequests(@CurrentUser() user: any) {
    const requests = await this.friendService.getReceivedRequests(user.userId);

    return {
      success: true,
      message: 'Received requests retrieved successfully',
      data: requests,
    };
  }

  /**
   * PATCH /friend/request/:id/accept
   * Accept a friend request
   */
  @Patch('request/:id/accept')
  async acceptFriendRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
  ) {
    const result = await this.friendService.acceptFriendRequest(
      requestId,
      user.userId,
    );

    return {
      success: true,
      message: 'Friend request accepted',
      data: result,
    };
  }

  /**
   * PATCH /friend/request/:id/reject
   * Reject a friend request
   */
  @Patch('request/:id/reject')
  async rejectFriendRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
  ) {
    const result = await this.friendService.rejectFriendRequest(
      requestId,
      user.userId,
    );

    return {
      success: true,
      message: 'Friend request rejected',
      data: result,
    };
  }

  /**
   * DELETE /friend/request/:id
   * Cancel a sent friend request (Hủy một lời mời kết bạn đã gửi)
   */
  @Delete('request/:id')
  async cancelFriendRequest(
    @CurrentUser() user: any,
    @Param('id') requestId: string,
  ) {
    await this.friendService.cancelFriendRequest(requestId, user.userId);

    return {
      success: true,
      message: 'Friend request cancelled',
    };
  }

  /**
   * PATCH /friend/fcm-token
   * Update FCM token for push notifications
   */
  @Patch('fcm-token')
  async updateFcmToken(
    @CurrentUser() user: any,
    @Body('fcmToken') fcmToken: string,
  ) {
    await this.friendService.updateFcmToken(user.userId, fcmToken);

    return {
      success: true,
      message: 'FCM token updated successfully',
    };
  }
}
