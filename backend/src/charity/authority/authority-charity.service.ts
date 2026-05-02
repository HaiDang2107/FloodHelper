import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { CampaignState, Prisma } from '@prisma/client';
import { ListAuthorityCampaignsDto, RespondCampaignDto } from './dto';
import { CommonCharityService } from '../common.service';
import { PrismaService } from '../../prisma/prisma.service';
import { formatLocation } from '../../common/location-format.util';

type CharityCampaignListItemPayload = Prisma.CharityCampaignGetPayload<{
  select: {
    campaignId: true;
    campaignName: true;
    state: true;
    createdAt: true;
    requestedAt: true;
    respondedAt: true;
    suspendedAt: true;
    noteForResponse: true;
    noteForSuspension: true;
    startedDonationAt: true;
    startedDistributionAt: true;
    finishedDistributionAt: true;
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
        residenceProvinceCode: true;
        residenceWardCode: true;
        residenceProvince: {
          select: { code: true, name: true };
        };
        residenceWard: {
          select: { code: true, name: true };
        };
      };
    };
  };
}>;

type AuthorityCampaignCursorField =
  | 'createdAt'
  | 'requestedAt'
  | 'respondedAt'
  | 'suspendedAt'
  | 'startedDonationAt'
  | 'startedDistributionAt'
  | 'finishedDistributionAt';
type AuthorityCampaignNextState =
  | 'APPROVED'
  | 'REJECTED'
  | 'SUSPENDED';

@Injectable()
export class AuthorityCharityService {
  constructor(
    private readonly commonCharityService: CommonCharityService,
    private readonly prisma: PrismaService,
  ) {}

  listCampaignsForAuthority(
    authorityUserId: string,
    dto: ListAuthorityCampaignsDto,
  ) {
    return this._listCampaignsForAuthority(authorityUserId, dto);
  }

  getCampaignDetailForAuthority(authorityUserId: string, campaignId: string) {
    return this._getCampaignDetailForAuthority(authorityUserId, campaignId);
  }

  approveCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    dto: RespondCampaignDto,
  ) {
    return this._respondCampaignForAuthority(
      authorityUserId,
      campaignId,
      'APPROVED',
      dto,
    );
  }

  rejectCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    dto: RespondCampaignDto,
  ) {
    return this._respondCampaignForAuthority(
      authorityUserId,
      campaignId,
      'REJECTED',
      dto,
    );
  }

  suspendCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    dto: RespondCampaignDto,
  ) {
    return this._respondCampaignForAuthority(
      authorityUserId,
      campaignId,
      'SUSPENDED',
      dto,
    );
  }

  //===============================PRIVATE METHOD=========================================

  private async _listCampaignsForAuthority(
    authorityUserId: string,
    dto: ListAuthorityCampaignsDto,
  ) {
    const authorityResidence = await this.getAuthorityPlace(authorityUserId);
    const limit = dto.limit ?? 20;
    const stateFilter = dto.state?.toUpperCase() as
      | CampaignState
      | undefined;
    const cursorField = this.getAuthorityCursorField(stateFilter);
    const cursorTime = dto.beforeRequestedAt
      ? new Date(dto.beforeRequestedAt)
      : new Date();

    const allowedStates: CampaignState[] = stateFilter
      ? [stateFilter]
      : [
          'PENDING',
          'APPROVED',
          'REJECTED',
          'DONATING',
          'DISTRIBUTING',
          'FINISHED',
          'SUSPENDED',
        ];

    const where: Prisma.CharityCampaignWhereInput = {
      AND: [
        {
          state: {
            in: allowedStates,
          },
        },
        {
          organizer: {
            residenceWardCode: authorityResidence,
          },
        },
        {
          [cursorField]: {
            not: null,
            lte: cursorTime,
          },
        },
        {
          checkedBy: authorityUserId,
        },
      ],
    };

    const rows = await this.prisma.charityCampaign.findMany({
      where,
      select: {
        campaignId: true,
        campaignName: true,
        state: true,
        createdAt: true,
        requestedAt: true,
        respondedAt: true,
        suspendedAt: true,
        noteForResponse: true,
        noteForSuspension: true,
        startedDonationAt: true,
        startedDistributionAt: true,
        finishedDistributionAt: true,
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            residenceProvinceCode: true,
            residenceWardCode: true,
            residenceProvince: {
              select: { code: true, name: true },
            },
            residenceWard: {
              select: { code: true, name: true },
            },
          },
        },
      },
      orderBy: this.getAuthorityOrderBy(stateFilter),
      take: limit + 1,
    });

    const hasMore = rows.length > limit;
    const sliced = hasMore ? rows.slice(0, limit) : rows;
    const lastRow = sliced[sliced.length - 1];
    const nextCursorDate =
      hasMore && lastRow
        ? this.getAuthorityCursorDate(lastRow, stateFilter)
        : null;
    const nextCursor = nextCursorDate?.toISOString() ?? null;

    return {
      items: sliced.map((campaign) => this.mapCampaignListItem(campaign)),
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  private async getAuthorityPlace(authorityUserId: string) {
    const authority = await this.prisma.user.findUnique({
      where: { userId: authorityUserId },
      select: {
        userId: true,
        residenceWardCode: true,
        residenceProvinceCode: true,
        residenceProvince: {
          select: { code: true, name: true },
        },
        residenceWard: {
          select: { code: true, name: true },
        },
        role: true,
      },
    });

    if (!authority) {
      throw new NotFoundException('Authority account not found');
    }
    if (!authority.role.includes('AUTHORITY')) {
      throw new ForbiddenException('Only authority users can access this resource');
    }
    if (!authority.residenceWardCode) {
      throw new BadRequestException(
        'Authority residence ward is required to review campaigns',
      );
    }

    return authority.residenceWardCode;
  }

  private getAuthorityCursorField(
    stateFilter?: string,
  ): AuthorityCampaignCursorField {
    switch (stateFilter) {
      case 'PENDING':
        return 'requestedAt';
      case 'APPROVED':
      case 'REJECTED':
        return 'respondedAt';
      case 'SUSPENDED':
        return 'suspendedAt';
      case 'DONATING':
        return 'startedDonationAt';
      case 'DISTRIBUTING':
        return 'startedDistributionAt';
      case 'FINISHED':
        return 'finishedDistributionAt';
      default:
        return 'createdAt';
    }
  }

  private getAuthorityOrderBy(
    stateFilter?: string,
  ): Prisma.CharityCampaignOrderByWithRelationInput[] {
    const cursorField = this.getAuthorityCursorField(stateFilter);
    return [{ [cursorField]: 'desc' }, { createdAt: 'desc' }];
  }

  private getAuthorityCursorDate(
    campaign: CharityCampaignListItemPayload,
    stateFilter?: string,
  ): Date {
    const cursorField = this.getAuthorityCursorField(stateFilter);

    switch (cursorField) {
      case 'requestedAt':
        return campaign.requestedAt ?? campaign.createdAt;
      case 'respondedAt':
        return campaign.respondedAt ?? campaign.requestedAt ?? campaign.createdAt;
      case 'suspendedAt':
        return campaign.suspendedAt ?? campaign.respondedAt ?? campaign.createdAt;
      case 'startedDonationAt':
        return campaign.startedDonationAt ?? campaign.respondedAt ?? campaign.createdAt;
      case 'startedDistributionAt':
        return campaign.startedDistributionAt ?? campaign.startedDonationAt ?? campaign.createdAt;
      case 'finishedDistributionAt':
        return campaign.finishedDistributionAt ?? campaign.startedDistributionAt ?? campaign.createdAt;
      case 'createdAt':
      default:
        return campaign.createdAt;
    }
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      organizedBy: campaign.organizer?.userId,
      organizerResidence: formatLocation(
        campaign.organizer?.residenceWard,
        campaign.organizer?.residenceProvince,
      ),
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      suspendedAt: campaign.suspendedAt,
      noteForResponse: campaign.noteForResponse,
      noteForSuspension: campaign.noteForSuspension,
      createdAt: campaign.createdAt,
    };
  }

  private async _getCampaignDetailForAuthority(
    authorityUserId: string,
    campaignId: string,
  ) {
    await this.assertAuthorityCanAccessCampaign(authorityUserId, campaignId);
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  private async assertAuthorityCanAccessCampaign(
    authorityUserId: string,
    campaignId: string,
  ) {
    const authorityPlace = await this.getAuthorityPlace(authorityUserId);
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        campaignId: true,
        checkedBy: true,
        state: true,
        respondedAt: true,
        suspendedAt: true,
        noteForResponse: true,
        noteForSuspension: true,
        organizer: {
          select: {
            residenceWardCode: true,
          },
        },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    if (campaign.organizer?.residenceWardCode !== authorityPlace) {
      throw new ForbiddenException(
        'You are not allowed to review campaigns outside your residence area',
      );
    }

    if (campaign.checkedBy && campaign.checkedBy !== authorityUserId) {
      throw new ForbiddenException('This campaign has been assigned to another authority');
    }

    return campaign;
  }

  private async _respondCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    nextState: AuthorityCampaignNextState,
    dto: RespondCampaignDto,
  ) {
    const reviewTarget = await this.assertAuthorityCanAccessCampaign(
      authorityUserId,
      campaignId,
    );

    const currentState = reviewTarget.state;
    this.validateTransition(currentState, nextState);

    const trimmedResponseNote = dto.noteForResponse?.trim();
    const trimmedSuspensionNote = dto.noteForSuspension?.trim();
    if (nextState === 'REJECTED' && !trimmedResponseNote) {
      throw new BadRequestException(
        'noteForResponse is required when rejecting',
      );
    }
    if (nextState === 'SUSPENDED' && !trimmedSuspensionNote) {
      throw new BadRequestException(
        'noteForSuspension is required when suspending',
      );
    }

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        state: nextState,
        respondedAt:
          nextState === 'APPROVED' || nextState === 'REJECTED'
            ? new Date()
            : reviewTarget.respondedAt,
        suspendedAt:
          nextState === 'SUSPENDED' ? new Date() : reviewTarget.suspendedAt,
        noteForResponse:
          nextState === 'APPROVED' || nextState === 'REJECTED'
            ? trimmedResponseNote ?? reviewTarget.noteForResponse
            : reviewTarget.noteForResponse,
        noteForSuspension:
          nextState === 'SUSPENDED'
            ? trimmedSuspensionNote ?? reviewTarget.noteForSuspension
            : reviewTarget.noteForSuspension,
      },
    });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  private validateTransition(
    currentState: CampaignState,
    nextState: AuthorityCampaignNextState,
  ) {
    if (nextState === 'APPROVED' && currentState !== 'PENDING') {
      throw new ConflictException('Only PENDING campaigns can be approved');
    }

    if (nextState === 'REJECTED') {
      if (currentState !== 'PENDING' && currentState !== 'APPROVED') {
        throw new ConflictException(
          'Only PENDING or APPROVED campaigns can be rejected',
        );
      }
      return;
    }

    if (nextState === 'SUSPENDED') {
      if (currentState !== 'DONATING' && currentState !== 'DISTRIBUTING') {
        throw new ConflictException(
          'Only DONATING or DISTRIBUTING campaigns can be suspended',
        );
      }
      return;
    }
  }

}
