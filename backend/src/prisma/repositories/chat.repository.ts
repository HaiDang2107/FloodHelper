import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * ChatRepository - Handles ChatRoom, Message, and RoomMember queries
 * Manages real-time chat functionality and message history
 */
@Injectable()
export class ChatRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Chat');
  }

  /**
   * Create chat room
   */
  async createRoom(data: any) {
    return this.prisma.chatRoom.create({
      data: {
        createdBy: data.createdBy,
      },
    });
  }

  /**
   * Get chat room with members
   */
  async getRoomWithMembers(roomId: string) {
    return this.prisma.chatRoom.findUnique({
      where: { roomId },
      include: {
        members: {
          include: {
            user: {
              include: {
                profiles: {
                  where: { isCurrent: true },
                  select: {
                    fullname: true,
                    avatarUrl: true,
                  }
                }
              },
              select: {
                userId: true,
              },
            },
          },
        },
        creator: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
      },
    });
  }

  /**
   * Add member to room
   */
  async addMember(roomId: string, memberId: string) {
    return this.prisma.roomMember.create({
      data: {
        roomId,
        memberId,
        role: 'member',
      },
    });
  }

  /**
   * Remove member from room
   */
  async removeMember(roomId: string, memberId: string) {
    return this.prisma.roomMember.deleteMany({
      where: {
        roomId,
        memberId,
      },
    });
  }

  /**
   * Get room members
   */
  async getRoomMembers(roomId: string) {
    return this.prisma.roomMember.findMany({
      where: { roomId },
      include: {
        user: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
      },
    });
  }

  /**
   * Send message
   */
  async sendMessage(data: any) {
    return this.prisma.message.create({
      data: {
        roomId: data.roomId,
        sentBy: data.sentBy,
        type: data.type || 'TEXT',
        textContent: data.textContent,
      },
      include: {
        sender: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
      },
    });
  }

  /**
   * Get messages for room (paginated)
   */
  async getMessages(
    roomId: string,
    limit: number = 50,
    skip: number = 0,
  ) {
    return this.prisma.message.findMany({
      where: { roomId },
      include: {
        sender: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
      },
      orderBy: { sentAt: 'desc' },
      take: limit,
      skip,
    });
  }

  /**
   * Get user's chat rooms
   */
  async getUserChatRooms(userId: string) {
    return this.prisma.roomMember.findMany({
      where: { memberId: userId },
      include: {
        chatRoom: {
          include: {
            members: {
              select: {
                memberId: true,
              },
            },
          },
        },
      },
    });
  }

  /**
   * Delete message
   */
  async deleteMessage(messageId: string) {
    return this.prisma.message.delete({
      where: { messageId },
    });
  }

  /**
   * Update message
   */
  async updateMessage(messageId: string, textContent: string) {
    return this.prisma.message.update({
      where: { messageId },
      data: { textContent },
    });
  }

  // Base CRUD methods
  async findById(id: string) {
    return this.getRoomWithMembers(id);
  }

  async findAll() {
    return this.prisma.chatRoom.findMany({
      include: {
        members: true,
      },
    });
  }

  async create(data: any) {
    return this.createRoom(data);
  }

  async update(id: string, data: any) {
    return this.prisma.chatRoom.update({
      where: { roomId: id },
      data,
    });
  }

  async delete(id: string) {
    return this.prisma.chatRoom.delete({
      where: { roomId: id },
    });
  }

  async count() {
    return this.prisma.chatRoom.count();
  }
}
