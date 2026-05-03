import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { SignalState } from '../common/enum/signalState.enum';
import {
  ChangeSignalStateDto,
  CreateSignalDto,
  QuerySignalsDto,
  UpdateSignalInfoDto,
} from './dto';
import { SignalRepository } from '../prisma/repositories';

@Injectable()
export class SignalService {
  constructor(private readonly signalRepository: SignalRepository) {}

  async createSignal(createdBy: string, dto: CreateSignalDto) {
    await this.ensureNoBroadcastingSignal(createdBy);

    try {
      return await this.signalRepository.createSignal(createdBy, dto);
    } catch (error) {
      if (this.isBroadcastingUniqueViolation(error)) {
        throw new ConflictException(
          'You already have a broadcasting distress signal. Stop it before creating a new one.',
        );
      }
      throw error;
    }
  }

  async updateInfo(signalId: string, actorUserId: string, dto: UpdateSignalInfoDto) {
    const existing = await this.getByIdOrThrow(signalId);

    if (existing.createdBy !== actorUserId) {
      throw new ForbiddenException('Only creator can update distress signal info');
    }

    if (existing.state !== SignalState.BROADCASTING) {
      throw new ConflictException('Only broadcasting signals can be updated');
    }

    return this.signalRepository.update(signalId, {
      trappedCount: dto.trappedCount,
      childrenNum: dto.childrenNum,
      elderlyNum: dto.elderlyNum,
      hasFood: dto.hasFood,
      hasWater: dto.hasWater,
      note: dto.note,
    });
  }

  async deleteSignal(signalId: string, actorUserId: string) {
    const existing = await this.getByIdOrThrow(signalId);

    if (existing.createdBy !== actorUserId) {
      throw new ForbiddenException('Only creator can delete distress signal');
    }

    return this.signalRepository.delete(signalId);
  }

  async changeState(signalId: string, actorUserId: string, dto: ChangeSignalStateDto) {
    const existing = await this.getByIdOrThrow(signalId);

    if (existing.state !== SignalState.BROADCASTING) {
      throw new ConflictException('Signal is already finalized');
    }

    if (dto.state === SignalState.HANDLED) {
      const handledBy = dto.handledBy ?? actorUserId;
      if (!handledBy) {
        throw new BadRequestException('handledBy is required when changing state to HANDLED');
      }

      if (existing.handledBy && existing.handledBy !== handledBy) {
        throw new ConflictException('handledBy cannot be changed once handled');
      }

      return this.signalRepository.updateSignalState(
        signalId,
        SignalState.HANDLED,
        handledBy,
      );
    }

    if (dto.state === SignalState.STOPPED) {
      if (existing.createdBy !== actorUserId) {
        throw new ForbiddenException('Only creator can stop distress signal');
      }

      return this.signalRepository.stopSignal(signalId);
    }

    throw new BadRequestException('Invalid target state');
  }

  async listSignals(query: QuerySignalsDto) {
    if (query.createdBy && query.handledBy) {
      throw new BadRequestException('Use either createdBy or handledBy filter, not both');
    }

    if (!query.createdBy && !query.handledBy) {
      throw new BadRequestException('Either createdBy or handledBy filter is required');
    }

    const where: Prisma.SignalWhereInput = {
      ...(query.createdBy ? { createdBy: query.createdBy } : {}),
      ...(query.handledBy ? { handledBy: query.handledBy } : {}),
      ...(query.state ? { state: query.state as any } : {}),
    };

    return this.signalRepository.listSignals(where);
  }

  async listBroadcastingSignals() {
    return this.signalRepository.listActiveSignals();
  }

  async listHandledSignalsByRescuer(handledBy: string) {
    return this.signalRepository.listHandledSignalsByRescuer(handledBy);
  }

  async getLatestSignalByUser(createdBy: string) {
    return this.signalRepository.getLatestSignalByUser(createdBy);
  }

//   async updateSignalInfo(signalId: string, dto: UpdateSignalInfoDto) {
//     const actor = dto.updatedBy;
//     if (!actor) {
//       throw new BadRequestException('updatedBy is required');
//     }

//     return this.updateInfo(signalId, actor, dto);
//   }

  async updateBroadcastingInfoByUser(dto: UpdateSignalInfoDto) {
    const actor = dto.updatedBy;
    if (!actor) {
      throw new BadRequestException('updatedBy is required');
    }

    const activeSignal = await this.signalRepository.findActiveSignalByUser(actor);

    if (!activeSignal) {
      throw new NotFoundException('No broadcasting signal found for this user');
    }

    return this.updateInfo(activeSignal.signalId, actor, dto);
  }

//   async deleteSignalInternal(signalId: string, deletedBy: string) {
//     if (!deletedBy) {
//       throw new BadRequestException('deletedBy is required');
//     }

//     return this.deleteSignal(signalId, deletedBy);
//   }

//   async changeStateInternal(signalId: string, dto: ChangeSignalStateDto) {
//     const actor = dto.updatedBy ?? dto.handledBy;
//     if (!actor) {
//       throw new BadRequestException('updatedBy is required');
//     }

//     return this.changeState(signalId, actor, dto);
//   }

  async stopBroadcastingByUser(createdBy: string) {
    const activeSignal = await this.signalRepository.findActiveSignalByUser(createdBy);
    if (!activeSignal) throw new NotFoundException('No broadcasting signal found for this user');

    await this.changeState(activeSignal.signalId, createdBy, { state: SignalState.STOPPED, updatedBy: createdBy });

    return this.signalRepository.getSignal(activeSignal.signalId);
  }

  async handleBroadcastingByRescuer(createdBy: string, handledBy: string) {
    const activeSignal = await this.signalRepository.findActiveSignalByUser(createdBy);
    if (!activeSignal) throw new NotFoundException('No broadcasting signal found for this user');

    await this.changeState(activeSignal.signalId, handledBy, { state: SignalState.HANDLED, handledBy });

    return this.signalRepository.getSignal(activeSignal.signalId);
  }

  private async ensureNoBroadcastingSignal(createdBy: string) {
    const activeSignal = await this.signalRepository.findActiveSignalByUser(createdBy);

    if (activeSignal) {
      throw new ConflictException(
        'You already have a broadcasting distress signal. Stop it before creating a new one.',
      );
    }
  }

  private async getByIdOrThrow(signalId: string) {
    const signal = await this.signalRepository.getSignal(signalId);

    if (!signal) {
      throw new NotFoundException('Signal not found');
    }

    return signal;
  }

  private isBroadcastingUniqueViolation(error: unknown): boolean {
    if (!(error instanceof Prisma.PrismaClientKnownRequestError)) {
      return false;
    }

    if (error.code !== 'P2002') {
      return false;
    }

    const target = Array.isArray(error.meta?.target) ? error.meta?.target : [];
    return target.includes('Signal_created_by_broadcasting_key');
  }
}
