import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma.service';
import { BaseRepository } from './base.repository';

/**
 * SignalRepository - Handles Signal (distress broadcasting) queries
 * Manages signal creation, listing, and updates
 */
@Injectable()
export class SignalRepository extends BaseRepository<any> {
  constructor(private readonly prisma: PrismaService) {
    super('Signal');
  }

  /**
   * Create distress signal
   */
  async createSignal(createdBy: string, data: any) {
    return this.prisma.signal.create({
      data: {
        createdBy,
        trappedCount: data.trappedCount || 0,
        childrenNum: data.childrenNum || 0,
        elderlyNum: data.elderlyNum || 0,
        hasFood: data.hasFood || false,
        hasWater: data.hasWater || false,
        note: data.note,
        state: 'BROADCASTING' as any,
      },
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
   * Get signal by ID
   */
  async getSignal(signalId: string) {
    return this.prisma.signal.findUnique({
      where: { signalId },
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
            role: true,
          },
        },
        handledByUser: {
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
   * List all active signals
   */
  async listActiveSignals() {
    return this.prisma.signal.findMany({
      where: { state: 'BROADCASTING' as any },
      include: {
        user: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, avatarUrl: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * List signals by user
   */
  async listSignalsByUser(userId: string) {
    return this.prisma.signal.findMany({
      where: { createdBy: userId },
      include: {
        user: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, avatarUrl: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listSignals(where: Prisma.SignalWhereInput) {
    return this.prisma.signal.findMany({
      where,
      include: {
        user: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                phoneNumber: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
        handledByUser: {
          include: {
            profiles: {
              where: { isCurrent: true },
              select: {
                fullname: true,
                nickname: true,
                avatarUrl: true,
              }
            }
          },
          select: {
            userId: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findActiveSignalByUser(createdBy: string) {
    return this.prisma.signal.findFirst({
      where: {
        createdBy,
        state: 'BROADCASTING' as any,
      },
      select: {
        signalId: true,
      },
    });
  }

  async getLatestSignalByUser(createdBy: string) {
    return this.prisma.signal.findFirst({
      where: { createdBy },
      include: {
        user: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, phoneNumber: true },
            },
          },
        },
        handledByUser: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listHandledSignalsByRescuer(handledBy: string) {
    return this.prisma.signal.findMany({
      where: {
        handledBy,
        state: 'HANDLED' as any,
      },
      include: {
        user: {
          select: {
            userId: true,
            profiles: {
              where: { isCurrent: true },
              select: { fullname: true, phoneNumber: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Update signal state (handle/stop)
   */
  async updateSignalState(signalId: string, state: string, handledBy?: string) {
    return this.prisma.signal.update({
      where: { signalId },
      data: {
        state: state as any,
        handledBy: handledBy || undefined,
        handledAt: handledBy ? new Date() : undefined,
      },
    });
  }

  /**
   * Stop signal
   */
  async stopSignal(signalId: string) {
    return this.prisma.signal.update({
      where: { signalId },
      data: {
        state: 'STOPPED' as any,
        stoppedAt: new Date(),
      },
    });
  }

  /**
   * Delete signal
   */
  async deleteSignal(signalId: string) {
    return this.prisma.signal.delete({
      where: { signalId },
    });
  }

  // Base CRUD methods
  async findById(id: string) {
    return this.getSignal(id);
  }

  async findAll() {
    return this.listActiveSignals();
  }

  async create(data: any) {
    throw new Error('Use createSignal method with userId');
  }

  async update(id: string, data: any) {
    return this.prisma.signal.update({
      where: { signalId: id },
      data,
    });
  }

  async delete(id: string) {
    return this.deleteSignal(id);
  }

  async count() {
    return this.prisma.signal.count();
  }
}
