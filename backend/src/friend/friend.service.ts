import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { FriendRequestState } from '../common/enum/friendRequestState.enum';
import { FirebaseService } from '../firebase/firebase.service';
import { FriendRepository, UserRepository, AnnouncementRepository } from '../prisma/repositories';
import { PublicAnnouncementType } from 'src/common/enum/publicAnnoucementType.enum';

@Injectable()
export class FriendService {
  private readonly logger = new Logger(FriendService.name);

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly friendRepository: FriendRepository,
    private readonly userRepository: UserRepository,
    private readonly announcementRepository: AnnouncementRepository,
  ) {}

  async sendFriendRequest(senderId: string, email: string, note?: string) {
    const receiver = await this.userRepository.findUserByEmail(email);
    if (!receiver) {
      throw new NotFoundException('User with this email not found');
    }
    const receiverId = receiver.userId;

    if (senderId === receiverId) {
      throw new BadRequestException(
        'You cannot send a friend request to yourself',
      );
    }

    const existingFriendship = await this.friendRepository.getFriendship(
      senderId,
      receiverId,
    );
    if (existingFriendship) {
      throw new ConflictException('You are already friends with this user');
    }

    const existingRequest = await this.friendRepository.findPendingRequestBetween(
      senderId,
      receiverId,
    );
    if (existingRequest) {
      throw new ConflictException(
        'A friend request already exists between you and this user',
      );
    }

    const friendRequest = await this.friendRepository.createFriendRequest(
      senderId,
      receiverId,
      note,
    );

    if (friendRequest.receiver.fcmToken) {
      const senderName =
        friendRequest.sender.profiles?.[0]?.nickname ||
        friendRequest.sender.profiles?.[0]?.fullname ||
        '';
      const title = 'New Friend Request';
      const caption = `${senderName} sent you a friend request`;

      await this.firebaseService.sendNotification(
        friendRequest.receiver.fcmToken,
        title,
        caption,
        {
          type: 'FRIEND_REQUEST',
          requestId: friendRequest.requestId,
          senderId,
          senderName,
        },
        'friend_requests',
      );

      await this.announcementRepository.createAnnouncement({
        title,
        caption,
        publishedBy: senderId,
        type: PublicAnnouncementType.DAILY,
      });
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

        name: friendRequest.receiver.profiles?.[0]?.fullname || '',
        displayName: friendRequest.receiver.profiles?.[0]?.nickname || '',
        fullname: friendRequest.receiver.profiles?.[0]?.fullname || '',
        nickname: friendRequest.receiver.profiles?.[0]?.nickname || '',
        avatarUrl: friendRequest.receiver.profiles?.[0]?.avatarUrl || '',
      },

    };
  }

  async getSentRequests(userId: string) {
    const requests = await this.friendRepository.getSentRequests(userId);

    return requests.map((r) => ({
      requestId: r.requestId,
      state: r.state,
      note: r.note,
      createdAt: r.createdAt,
      user: {
        userId: r.receiver.userId,
        name: r.receiver.profiles?.[0]?.fullname || '',
        displayName: r.receiver.profiles?.[0]?.nickname || '',
        fullname: r.receiver.profiles?.[0]?.fullname || '',
        nickname: r.receiver.profiles?.[0]?.nickname || '',
        avatarUrl: r.receiver.profiles?.[0]?.avatarUrl || '',
      },
    }));
  }

  async getReceivedRequests(userId: string) {
    const requests = await this.friendRepository.getReceivedRequests(userId);

    return requests.map((r) => ({
      requestId: r.requestId,
      state: r.state,
      note: r.note,
      createdAt: r.createdAt,
      user: {
        userId: r.sender.userId,
        name: r.sender.profiles?.[0]?.fullname || '',
        displayName: r.sender.profiles?.[0]?.nickname || '',
        fullname: r.sender.profiles?.[0]?.fullname || '',
        nickname: r.sender.profiles?.[0]?.nickname || '',
        avatarUrl: r.sender.profiles?.[0]?.avatarUrl || '',
      },
    }));

  }

  async acceptFriendRequest(requestId: string, userId: string) {
    const result = await this.friendRepository.acceptFriendRequest(requestId);

    if (!result) {
      throw new NotFoundException('Friend request not found');
    }

    const { request, updatedRequest } = result;

    if (request.sentTo !== userId) {
      throw new BadRequestException('You can only accept requests sent to you');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    const accepterName =
      request.receiver.profiles?.[0]?.nickname ||
      request.receiver.profiles?.[0]?.fullname ||
      'Someone';
    const title = 'Friend Request Accepted';
    const caption = `${accepterName} accepted your friend request`;

    if (request.sender.fcmToken) {
      await this.firebaseService.sendNotification(
        request.sender.fcmToken,
        title,
        caption,
        {
          type: 'FRIEND_REQUEST_ACCEPTED',
          requestId,
          userId,
        },
        'friend_updates',
      );
    }

    // Create a PublicAnnouncement (type: DAILY) for the sender
    await this.announcementRepository.createAnnouncement({
      title,
      caption,
      publishedBy: userId,
      type: PublicAnnouncementType.DAILY,
    });

    return updatedRequest;
  }

  async rejectFriendRequest(requestId: string, userId: string) {
    const request = await this.friendRepository.getFriendRequest(requestId);

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.sentTo !== userId) {
      throw new BadRequestException('You can only reject requests sent to you');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    const updatedRequest = await this.friendRepository.rejectFriendRequest(
      requestId,
    );

    const rejecterName =
      updatedRequest.receiver.profiles?.[0]?.nickname ||
      updatedRequest.receiver.profiles?.[0]?.fullname ||
      'Someone';
    const title = 'Friend Request Rejected';
    const caption = `${rejecterName} rejected your friend request`;

    if (updatedRequest.sender.fcmToken) {
      await this.firebaseService.sendNotification(
        updatedRequest.sender.fcmToken,
        title,
        caption,
        {
          type: 'FRIEND_REQUEST_REJECTED',
          requestId,
          userId,
        },
        'friend_updates',
      );
    }

    // Create a PublicAnnouncement (type: APP) for the sender
    await this.announcementRepository.createAnnouncement({
      title,
      caption,
      publishedBy: userId,
      type: PublicAnnouncementType.DAILY,
    });

    return updatedRequest;
  }

  async cancelFriendRequest(requestId: string, userId: string) {
    const request = await this.friendRepository.getFriendRequest(requestId);

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.createdBy !== userId) {
      throw new BadRequestException('You can only cancel your own requests');
    }

    if (request.state !== FriendRequestState.PENDING) {
      throw new BadRequestException('This request is no longer pending');
    }

    return this.friendRepository.cancelFriendRequest(requestId);
  }

  async getFriends(userId: string) {
    const friendships = await this.friendRepository.getFriends(userId);

    return friendships.map((f) => ({
      userId: f.friend.userId,
      name: f.friend.profiles[0]?.fullname || '',
      displayName: f.friend.profiles[0]?.nickname || '',
      fullname: f.friend.profiles[0]?.fullname || '',
      nickname: f.friend.profiles[0]?.nickname || '',
      avatarUrl: f.friend.profiles[0]?.avatarUrl || '',
      friendMapMode: f.friendMapMode,
    }));
  }

  async updateFriendMapModes(
    userId: string,
    friendIds: string[],
    mapMode: boolean,
  ) {
    const result = await this.friendRepository.updateFriendMapModes(
      userId,
      friendIds,
      mapMode,
    );

    return { updated: result.count };
  }
}
