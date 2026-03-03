import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { FriendRequestState } from '../common/enum/friendRequestState.enum';
import { FirebaseService } from '../firebase/firebase.service';

@Injectable()
export class FriendService {
  private prisma: PrismaClient;
  private readonly logger = new Logger(FriendService.name);

  constructor(private readonly firebaseService: FirebaseService) {
    this.prisma = new PrismaClient();
  }

  /**
   * Send a friend request from sender to receiver
   */
  async sendFriendRequest(senderId: string, receiverId: string, note?: string) {
    // Validate: cannot send request to yourself
    if (senderId === receiverId) {
      throw new BadRequestException('You cannot send a friend request to yourself');
    }

    // Validate: receiver exists
    const receiver = await this.prisma.user.findUnique({
      where: { userId: receiverId },
    });

    if (!receiver) {
      throw new NotFoundException('User not found');
    }

    // Check if they are already friends
    const existingFriendship = await this.prisma.friendship.findFirst({
      where: {
        OR: [
          { userId: senderId, friendId: receiverId },
          { userId: receiverId, friendId: senderId },
        ],
      },
    });

    if (existingFriendship) {
      throw new ConflictException('You are already friends with this user');
    }

    // Check if there's already a pending request between them
    const existingRequest = await this.prisma.friendMakingRequest.findFirst({
      where: {
        OR: [
          {
            createdBy: senderId,
            sentTo: receiverId,
            state: FriendRequestState.PENDING,
          },
          {
            createdBy: receiverId,
            sentTo: senderId,
            state: FriendRequestState.PENDING,
          },
        ],
      },
    });

    if (existingRequest) {
      throw new ConflictException('A friend request already exists between you and this user');
    }

    // Create the friend request
    const friendRequest = await this.prisma.friendMakingRequest.create({
      data: {
        createdBy: senderId,
        sentTo: receiverId,
        state: FriendRequestState.PENDING,
        note: note || null,
      },
      include: {
        sender: {
          select: {
            userId: true,
            name: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        receiver: {
          select: {
            userId: true,
            name: true,
            displayName: true,
            avatarUrl: true,
            fcmToken: true,
          },
        },
      },
    });

    // Send push notification to receiver
    if (friendRequest.receiver.fcmToken) {
      const senderName = friendRequest.sender.displayName || friendRequest.sender.name;
      await this.firebaseService.sendNotification(
        friendRequest.receiver.fcmToken,
        'New Friend Request',
        `${senderName} sent you a friend request`,
        {
          type: 'FRIEND_REQUEST',
          requestId: friendRequest.requestId,
          senderId: senderId,
          senderName: senderName,
        },
      );
    }

    return {
      requestId: friendRequest.requestId,
      createdBy: friendRequest.createdBy,
      sentTo: friendRequest.sentTo,
      state: friendRequest.state,
      note: friendRequest.note,
      createdAt: friendRequest.createdAt,
      sender: friendRequest.sender,
      receiver: {
        userId: friendRequest.receiver.userId,
        name: friendRequest.receiver.name,
        displayName: friendRequest.receiver.displayName,
        avatarUrl: friendRequest.receiver.avatarUrl,
      },
    };
  }

  /**
   * Get sent friend requests for a user
   */
  async getSentRequests(userId: string) {
    const requests = await this.prisma.friendMakingRequest.findMany({
      where: {
        createdBy: userId,
        state: FriendRequestState.PENDING,
      },
      include: {
        receiver: {
          select: {
            userId: true,
            name: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return requests.map((r) => ({
      requestId: r.requestId,
      state: r.state,
      note: r.note,
      createdAt: r.createdAt,
      user: r.receiver,
    }));
  }

  /**
   * Get received friend requests for a user
   */
  async getReceivedRequests(userId: string) {
    const requests = await this.prisma.friendMakingRequest.findMany({
      where: {
        sentTo: userId,
        state: FriendRequestState.PENDING,
      },
      include: {
        sender: {
          select: {
            userId: true,
            name: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return requests.map((r) => ({
      requestId: r.requestId,
      state: r.state,
      note: r.note,
      createdAt: r.createdAt,
      user: r.sender,
    }));
  }

  /**
   * Accept a friend request
   */
  async acceptFriendRequest(requestId: string, userId: string) {
    const request = await this.prisma.friendMakingRequest.findUnique({
      where: { requestId },
      include: {
        sender: {
          select: {
            userId: true,
            name: true,
            displayName: true,
            fcmToken: true,
          },
        },
        receiver: {
          select: {
            userId: true,
            name: true,
            displayName: true,
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.sentTo !== userId) {
      throw new BadRequestException('You can only accept requests sent to you');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    // Update request state and create friendship in a transaction
    const [updatedRequest] = await this.prisma.$transaction([
      this.prisma.friendMakingRequest.update({
        where: { requestId },
        data: {
          state: FriendRequestState.ACCEPTED,
          responsedAt: new Date(),
        },
      }),
      this.prisma.friendship.create({
        data: {
          userId: request.createdBy,
          friendId: request.sentTo,
        },
      }),
    ]);

    // Send push notification to the sender
    if (request.sender.fcmToken) {
      const accepterName = request.receiver.displayName || request.receiver.name;
      await this.firebaseService.sendNotification(
        request.sender.fcmToken,
        'Friend Request Accepted',
        `${accepterName} accepted your friend request`,
        {
          type: 'FRIEND_REQUEST_ACCEPTED',
          requestId: requestId,
          userId: userId,
        },
      );
    }

    return updatedRequest;
  }

  /**
   * Reject a friend request
   */
  async rejectFriendRequest(requestId: string, userId: string) {
    const request = await this.prisma.friendMakingRequest.findUnique({
      where: { requestId },
    });

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.sentTo !== userId) {
      throw new BadRequestException('You can only reject requests sent to you');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    return this.prisma.friendMakingRequest.update({
      where: { requestId },
      data: {
        state: FriendRequestState.REJECTED,
        responsedAt: new Date(),
      },
    });
  }

  /**
   * Cancel a sent friend request
   */
  async cancelFriendRequest(requestId: string, userId: string) {
    const request = await this.prisma.friendMakingRequest.findUnique({
      where: { requestId },
    });

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.createdBy !== userId) {
      throw new BadRequestException('You can only cancel your own requests');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    return this.prisma.friendMakingRequest.delete({
      where: { requestId },
    });
  }

  /**
   * Update FCM token for push notifications
   */
  async updateFcmToken(userId: string, fcmToken: string) {
    return this.prisma.user.update({
      where: { userId },
      data: { fcmToken },
    });
  }
}
