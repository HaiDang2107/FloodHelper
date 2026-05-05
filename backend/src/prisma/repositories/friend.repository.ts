import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * FriendRepository - Handles Friendship and FriendMakingRequest queries
 * Centralizes friend request and friendship persistence.
 */
@Injectable()
export class FriendRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Friend');
  }

  async getFriendship(userId1: string, userId2: string) {
    return this.prisma.friendship.findFirst({
      where: {
        OR: [
          { userId: userId1, friendId: userId2 },
          { userId: userId2, friendId: userId1 },
        ],
      },
    });
  }

  async createFriendRequest(createdBy: string, sentTo: string, note?: string) {
    return this.prisma.friendMakingRequest.create({
      data: {
        createdBy,
        sentTo,
        state: 'PENDING',
        note: note ?? null,
      },
      include: {


        sender: {
          select: {
            userId: true,
            fcmToken: true,
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
        },
        receiver: {
          select: {
            userId: true,
            fcmToken: true,
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
        },


      },
    });
  }

  async findPendingRequestBetween(createdBy: string, sentTo: string) {
    return this.prisma.friendMakingRequest.findFirst({
      where: {
        OR: [
          { createdBy, sentTo, state: 'PENDING' },
          { createdBy: sentTo, sentTo: createdBy, state: 'PENDING' },
        ],
      },
    });
  }

  async getFriendRequest(requestId: string) {
    return this.prisma.friendMakingRequest.findUnique({
      where: { requestId },

    });
  }

  async getSentRequests(userId: string) {
    return this.prisma.friendMakingRequest.findMany({
      where: { createdBy: userId, state: 'PENDING' },
      include: {
        receiver: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getReceivedRequests(userId: string) {
    return this.prisma.friendMakingRequest.findMany({
      where: { sentTo: userId, state: 'PENDING' },
      include: {
        sender: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }


  async acceptFriendRequest(requestId: string) {
    return this.prisma.$transaction(async (tx) => {

      const request = await tx.friendMakingRequest.findUnique({
        where: { requestId },
        include: {
          sender: {
            select: {
              userId: true,
              fcmToken: true,
            },
          },
          receiver: {
            select: {
              userId: true,
              profiles: {
                where: { isCurrent: true },
                select: {
                  fullname: true,
                  nickname: true,
                  avatarUrl: true,
                }
              }
            },
          },
        },
      });


      if (!request) {
        return null;
      }

      const updatedRequest = await tx.friendMakingRequest.update({
        where: { requestId },
        data: {
          state: 'ACCEPTED',
          responsedAt: new Date(),
        },
      });

      await tx.friendship.create({
        data: {
          userId: request.createdBy,
          friendId: request.sentTo,
          friendMapMode: true,
        },
      });

      await tx.friendship.create({
        data: {
          userId: request.sentTo,
          friendId: request.createdBy,
          friendMapMode: true,
        },
      });

      return { request, updatedRequest };
    });
  }

  async rejectFriendRequest(requestId: string) {
    return this.prisma.friendMakingRequest.update({
      where: { requestId },
      data: {
        state: 'REJECTED',
        responsedAt: new Date(),
      },
    });
  }

  async cancelFriendRequest(requestId: string) {
    return this.prisma.friendMakingRequest.delete({
      where: { requestId },
    });
  }

  async getFriends(userId: string) {
    return this.prisma.friendship.findMany({
      where: { userId },
      include: {
        friend: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
        },
      },
    });
  }

  async updateFriendMapModes(userId: string, friendIds: string[], mapMode: boolean) {
    return this.prisma.friendship.updateMany({
      where: {
        userId,
        friendId: { in: friendIds },
      },
      data: { friendMapMode: mapMode },
    });
  }

  async findById(id: string) {
    return this.getFriendRequest(id);
  }

  async findAll() {
    return this.prisma.friendship.findMany();
  }

  async create(data: any) {
    return this.createFriendRequest(data.createdBy, data.sentTo, data.note);
  }

  async update(id: string, data: any) {
    return this.prisma.friendMakingRequest.update({
      where: { requestId: id },
      data,
    });
  }

  async delete(id: string) {
    return this.prisma.friendMakingRequest.delete({
      where: { requestId: id },
    });
  }

  async count() {
    return this.prisma.friendship.count();
  }
}
