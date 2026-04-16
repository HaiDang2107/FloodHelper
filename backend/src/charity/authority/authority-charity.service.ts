import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { ListAuthorityCampaignsDto, RespondCampaignDto } from './dto';
import { CommonCharityService } from '../common.service';

type CharityCampaignListItemPayload = Prisma.CharityCampaignGetPayload<{
  select: {
    campaignId: true;
    campaignName: true;
    state: true;
    createdAt: true;
    requestedAt: true;
    respondedAt: true;
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
        placeOfResidence: true;
      };
    };
  };
}>;

type AuthorityCampaignCursorField = 'requestedAt' | 'respondedAt';

@Injectable()
export class AuthorityCharityService {
  private readonly prisma: PrismaClient;

  constructor(private readonly commonCharityService: CommonCharityService) {
    this.prisma = new PrismaClient();
  }

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

  private async _listCampaignsForAuthority(
    authorityUserId: string,
    dto: ListAuthorityCampaignsDto,
  ) {
    const authorityResidence = await this.getAuthorityPlace(authorityUserId);
    const limit = dto.limit ?? 20;
    const stateFilter = dto.state?.toUpperCase();
    const cursorField = this.getAuthorityCursorField(stateFilter);
    const cursorTime = dto.beforeRequestedAt
      ? new Date(dto.beforeRequestedAt)
      : new Date();

    const allowedStates = stateFilter
      ? [stateFilter]
      : ['PENDING', 'APPROVED', 'REJECTED'];

    const where: Prisma.CharityCampaignWhereInput = {
      AND: [
        {
          state: {
            in: allowedStates,
          },
        },
        {
          organizer: {
            placeOfResidence: authorityResidence,
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
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
            placeOfResidence: true,
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

  private async _getCampaignDetailForAuthority(
    authorityUserId: string,
    campaignId: string,
  ) {
    await this.assertAuthorityCanAccessCampaign(authorityUserId, campaignId);
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  private async _respondCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    nextState: 'APPROVED' | 'REJECTED',
    dto: RespondCampaignDto,
  ) {
    const reviewTarget = await this.assertAuthorityCanAccessCampaign(
      authorityUserId,
      campaignId,
    );

    if (String(reviewTarget.state).toUpperCase() !== 'PENDING') {
      throw new ConflictException('Only PENDING campaigns can be processed');
    }

    const trimmedNote = dto.noteByAuthority?.trim();
    if (nextState === 'REJECTED' && !trimmedNote) {
      throw new BadRequestException('noteByAuthority is required when rejecting');
    }

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        state: nextState,
        respondedAt: new Date(),
        noteByAuthority: trimmedNote ?? reviewTarget.noteByAuthority,
      },
    });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  private getAuthorityCursorField(
    stateFilter?: string,
  ): AuthorityCampaignCursorField {
    if (stateFilter === 'APPROVED' || stateFilter === 'REJECTED') {
      return 'respondedAt';
    }
    return 'requestedAt';
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

    if (cursorField === 'respondedAt') {
      return campaign.respondedAt ?? campaign.requestedAt ?? campaign.createdAt;
    }

    return campaign.requestedAt ?? campaign.createdAt;
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      organizedBy: campaign.organizer?.userId,
      organizerResidence: campaign.organizer?.placeOfResidence ?? null,
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      createdAt: campaign.createdAt,
    };
  }

  private async getAuthorityPlace(authorityUserId: string) {
    const authority = await this.prisma.user.findUnique({
      where: { userId: authorityUserId },
      select: {
        userId: true,
        placeOfResidence: true,
        role: true,
      },
    });

    if (!authority) {
      throw new NotFoundException('Authority account not found');
    }
    if (!authority.role.includes('AUTHORITY')) {
      throw new ForbiddenException('Only authority users can access this resource');
    }
    if (!authority.placeOfResidence) {
      throw new BadRequestException(
        'Authority placeOfResidence is required to review campaigns',
      );
    }

    return authority.placeOfResidence;
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
        noteByAuthority: true,
        organizer: {
          select: {
            placeOfResidence: true,
          },
        },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    if (campaign.organizer?.placeOfResidence !== authorityPlace) {
      throw new ForbiddenException(
        'You are not allowed to review campaigns outside your residence area',
      );
    }

    if (campaign.checkedBy && campaign.checkedBy !== authorityUserId) {
      throw new ForbiddenException('This campaign has been assigned to another authority');
    }

    return campaign;
  }
}
