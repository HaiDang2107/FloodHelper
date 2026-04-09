import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import {
  CreateCampaignDto,
  ListAuthorityCampaignsDto,
  RespondCampaignDto,
  UpdateCampaignDto,
} from './dto';

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

type CharityCampaignDetailPayload = Prisma.CharityCampaignGetPayload<{
  include: {
    organizer: {
      select: {
        userId: true;
        fullname: true;
        nickname: true;
      };
    };
    bankAccount: true;
    transactions: true;
    supplies: true;
  };
}>;

@Injectable()
export class CharityService {
  private readonly prisma: PrismaClient;

  private readonly allowedStates = new Set([
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'FINISHED',
  ]);

  constructor() {
    this.prisma = new PrismaClient();
  }

  async listExistingCampaignsByState(state: string) {
    const normalizedState = this.normalizeAndValidateState(state);
    if (normalizedState === 'CREATED') {
      return [];
    }

    const campaigns = await this.prisma.charityCampaign.findMany({
      where: {
        state: {
          equals: normalizedState,
          mode: 'insensitive',
        },
      },
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
      orderBy: this.getOrderByForState(normalizedState),
    });

    return campaigns.map((campaign) => this.mapCampaignListItem(campaign));
  }

  async listMyCampaignsByState(userId: string, state: string) {
    const normalizedState = this.normalizeAndValidateState(state);

    const campaigns = await this.prisma.charityCampaign.findMany({
      where: {
        organizedBy: userId,
        state: {
          equals: normalizedState,
          mode: 'insensitive',
        },
      },
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
      orderBy: this.getOrderByForState(normalizedState),
    });

    return campaigns.map((campaign) => this.mapCampaignListItem(campaign));
  }

  async getCampaignDetail(campaignId: string) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      include: {
        organizer: {
          select: {
            userId: true,
            fullname: true,
            nickname: true,
          },
        },
        bankAccount: true,
        transactions: {
          orderBy: { donateAt: 'desc' },
        },
        supplies: {
          orderBy: { boughtAt: 'desc' },
        },
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }

    const announcements = await this.prisma.announcementFromBenefactor.findMany({
      where: { campaignId },
      orderBy: { announcementId: 'desc' },
    });

    return this.mapCampaignDetail(campaign, announcements);
  }

  async createCampaign(userId: string, payload: CreateCampaignDto) {
    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.resolveOrCreateBankAccountId(
      this.prisma,
      payload,
    );

    const created = await this.prisma.charityCampaign.create({
      data: {
        organizedBy: userId,
        bankAccountId,
        campaignName: payload.campaignName.trim(),
        purpose: payload.purpose.trim(),
        destination: payload.destination.trim(),
        charityObject: payload.charityObject.trim(),
        state: 'CREATED',
        startedDonationAt: timeline.startedDonationAt,
        finishedDonationAt: timeline.finishedDonationAt,
        startedDistributionAt: timeline.startedDistributionAt,
        finishedDistributionAt: timeline.finishedDistributionAt,
        bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
      },
      select: { campaignId: true },
    });

    return this.getCampaignDetail(created.campaignId);
  }

  async updateCampaign(
    userId: string,
    campaignId: string,
    payload: UpdateCampaignDto,
  ) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }
    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException('You are not allowed to update this campaign');
    }
    if (String(campaign.state).toUpperCase() !== 'CREATED') {
      throw new BadRequestException('Only CREATED campaigns can be updated');
    }

    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.resolveOrCreateBankAccountId(
      this.prisma,
      payload,
    );

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        bankAccountId,
        campaignName: payload.campaignName.trim(),
        purpose: payload.purpose.trim(),
        destination: payload.destination.trim(),
        charityObject: payload.charityObject.trim(),
        startedDonationAt: timeline.startedDonationAt,
        finishedDonationAt: timeline.finishedDonationAt,
        startedDistributionAt: timeline.startedDistributionAt,
        finishedDistributionAt: timeline.finishedDistributionAt,
        bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
      },
    });

    return this.getCampaignDetail(campaignId);
  }

  async sendCampaignRequest(userId: string, campaignId: string) {
    const campaign = await this.prisma.charityCampaign.findUnique({
      where: { campaignId },
      select: {
        organizedBy: true,
        state: true,
        bankAccountId: true,
        startedDonationAt: true,
        finishedDonationAt: true,
        startedDistributionAt: true,
        finishedDistributionAt: true,
      },
    });

    if (!campaign) {
      throw new NotFoundException('Charity campaign not found');
    }
    if (campaign.organizedBy !== userId) {
      throw new ForbiddenException('You are not allowed to send this campaign');
    }
    if (String(campaign.state).toUpperCase() !== 'CREATED') {
      throw new BadRequestException('Only CREATED campaigns can be submitted');
    }
    if (!campaign.bankAccountId) {
      throw new BadRequestException('Campaign bank account is required');
    }

    this.validateTimelineValues(
      campaign.startedDonationAt,
      campaign.finishedDonationAt,
      campaign.startedDistributionAt,
      campaign.finishedDistributionAt,
    );

    await this.prisma.charityCampaign.update({
      where: { campaignId },
      data: {
        state: 'PENDING',
        requestedAt: new Date(),
      },
    });

    return this.getCampaignDetail(campaignId);
  }

  async listCampaignsForAuthority(
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

    const where: Prisma.CharityCampaignWhereInput = { // Tạo bộ lọc
      AND: [ // AND các điều kiện
        {
          state: {
            in: allowedStates, // Lấy các bản ghi có trạng xuất hiện trong danh sách allowedStates 
          },
        },
        {
          organizer: {
            placeOfResidence: authorityResidence, // người tổ chức campaign có cùng residence
          },
        },
        {
          [cursorField]: { // Các trạng thái khác nhau sẽ có cursor field khác nhau
            not: null,
            lte: cursorTime,
          },
        },
        {
          checkedBy: authorityUserId,
        }
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
      orderBy: this.getAuthorityOrderBy(stateFilter), // hàm lấy thứ tự
      take: limit + 1, // Lấy ra limit + 1 bản ghi
    });

    const hasMore = rows.length > limit; // số lượng bản ghi > limit chứng tỏ vẫn còn (phục vụ cho lần lấy tiếp theo)
    const sliced = hasMore ? rows.slice(0, limit) : rows; // Cắt bản ghi cuối
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

  async getCampaignDetailForAuthority(
    authorityUserId: string,
    campaignId: string,
  ) {
    await this.assertAuthorityCanAccessCampaign(authorityUserId, campaignId); // Kiểm tra xem auth có được truy cập campaign không
    return this.getCampaignDetail(campaignId);
  }

  async approveCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    dto: RespondCampaignDto,
  ) {
    return this.respondCampaignForAuthority(
      authorityUserId,
      campaignId,
      'APPROVED',
      dto,
    );
  }

  async rejectCampaignForAuthority(
    authorityUserId: string,
    campaignId: string,
    dto: RespondCampaignDto,
  ) {
    return this.respondCampaignForAuthority(
      authorityUserId,
      campaignId,
      'REJECTED',
      dto,
    );
  }

  private async respondCampaignForAuthority( // Hàm này phục vụ 2 hàm trên (private)
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
        checkedBy: authorityUserId,
        respondedAt: new Date(),
        noteByAuthority: trimmedNote ?? reviewTarget.noteByAuthority,
      },
    });

    return this.getCampaignDetail(campaignId);
  }

  private normalizeAndValidateState(state: string): string {
    if (!state) {
      throw new BadRequestException('state is required');
    }

    const normalized = state.trim().toUpperCase();
    const mapped = normalized === 'ACCEPTED' ? 'APPROVED' : normalized;

    if (!this.allowedStates.has(mapped)) {
      throw new BadRequestException(
        'Invalid state. Allowed values: CREATED, PENDING, APPROVED, REJECTED, DONATING, DISTRIBUTING, FINISHED',
      );
    }

    return mapped;
  }

  private getOrderByForState(
    state: string,
  ): Prisma.CharityCampaignOrderByWithRelationInput[] {
    switch (state) {
      case 'PENDING':
        return [{ requestedAt: 'desc' }, { createdAt: 'desc' }];
      case 'APPROVED':
      case 'REJECTED':
        return [{ respondedAt: 'desc' }, { createdAt: 'desc' }];
      case 'DONATING':
        return [{ startedDonationAt: 'desc' }, { createdAt: 'desc' }];
      case 'DISTRIBUTING':
        return [{ startedDistributionAt: 'desc' }, { createdAt: 'desc' }];
      case 'FINISHED':
        return [{ finishedDistributionAt: 'desc' }, { createdAt: 'desc' }];
      case 'CREATED':
      default:
        return [{ createdAt: 'desc' }];
    }
  }

  private getAuthorityCursorField(stateFilter?: string): AuthorityCampaignCursorField {
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

  private async assertAuthorityCanAccessCampaign( // Xác nhận xem Authority có được truy cập campaign không
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

  private normalizeBankPayload(payload: {
    bankName: string;
    bankAccountNumber: string;
    bankAccountName?: string;
  }) {
    return {
      bankName: payload.bankName.trim(),
      bankAccountNumber: payload.bankAccountNumber.trim(),
      bankAccountName: payload.bankAccountName?.trim() || '',
    };
  }

  private async resolveOrCreateBankAccountId(
    db: Prisma.TransactionClient | PrismaClient,
    payload: {
      bankName: string;
      bankAccountNumber: string;
      bankAccountName?: string;
    },
  ) {
    const normalized = this.normalizeBankPayload(payload);
    const existing = await db.bankAccount.findUnique({ // tìm bankAccount dựa trên tên ngân hàng và só TK
      where: {
        bankName_bankAccountNumber: {
          bankName: normalized.bankName,
          bankAccountNumber: normalized.bankAccountNumber,
        },
      },
      select: {
        bankAccountId: true,
        bankAccountName: true,
      },
    });

    if (existing) {
      return existing.bankAccountId;
    }

    // Tra cứu bankAccountName sử dụng API nữa

    const created = await db.bankAccount.create({
      data: {
        bankName: normalized.bankName,
        bankAccountNumber: normalized.bankAccountNumber,
        bankAccountName: normalized.bankAccountName,
      },
      select: {
        bankAccountId: true,
      },
    });

    return created.bankAccountId;
  }

  private parseAndValidateTimeline(payload: {
    startedDonationAt: string;
    finishedDonationAt: string;
    startedDistributionAt: string;
    finishedDistributionAt: string;
  }) {
    const startedDonationAt = new Date(payload.startedDonationAt);
    const finishedDonationAt = new Date(payload.finishedDonationAt);
    const startedDistributionAt = new Date(payload.startedDistributionAt);
    const finishedDistributionAt = new Date(payload.finishedDistributionAt);

    this.validateTimelineValues(
      startedDonationAt,
      finishedDonationAt,
      startedDistributionAt,
      finishedDistributionAt,
    );

    return {
      startedDonationAt,
      finishedDonationAt,
      startedDistributionAt,
      finishedDistributionAt,
    };
  }

  private validateTimelineValues(
    startedDonationAt: Date | null,
    finishedDonationAt: Date | null,
    startedDistributionAt: Date | null,
    finishedDistributionAt: Date | null,
  ) {
    if (
      !startedDonationAt ||
      !finishedDonationAt ||
      !startedDistributionAt ||
      !finishedDistributionAt
    ) {
      throw new BadRequestException('All campaign timeline fields are required');
    }

    const now = new Date();
    if (startedDonationAt.getTime() <= now.getTime()) {
      throw new BadRequestException('startedDonationAt must be after current time');
    }
    if (startedDonationAt.getTime() >= finishedDonationAt.getTime()) {
      throw new BadRequestException(
        'startedDonationAt must be earlier than finishedDonationAt',
      );
    }
    if (finishedDonationAt.getTime() >= startedDistributionAt.getTime()) {
      throw new BadRequestException(
        'finishedDonationAt must be earlier than startedDistributionAt',
      );
    }
    if (startedDistributionAt.getTime() >= finishedDistributionAt.getTime()) {
      throw new BadRequestException(
        'startedDistributionAt must be earlier than finishedDistributionAt',
      );
    }
  }

  private mapCampaignDetail(
    campaign: CharityCampaignDetailPayload,
    announcements: Array<{ textContent: string | null; imageUrl: string | null }>,
  ) {
    const bank = campaign.bankAccount;

    const startDate =
      campaign.startedDonationAt ?? campaign.startedDistributionAt ?? campaign.createdAt;
    const endDate =
      campaign.finishedDistributionAt ?? campaign.finishedDonationAt ?? startDate;

    return {
      id: campaign.campaignId,
      organizedBy: campaign.organizer?.userId,
      checkedBy: campaign.checkedBy,
      name: campaign.campaignName,
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      purpose: campaign.purpose,
      charityObject: campaign.charityObject,
      state:
        String(campaign.state).toUpperCase() === 'ACCEPTED'
          ? 'APPROVED'
          : String(campaign.state).toUpperCase(),
      bankInfo: {
        accountNumber: bank?.bankAccountNumber ?? '',
        bankName: bank?.bankName ?? '',
        accountHolder: bank?.bankAccountName ?? null,
      },
      reliefLocation: campaign.destination,
      startedDonationAt: campaign.startedDonationAt,
      finishedDonationAt: campaign.finishedDonationAt,
      startedDistributionAt: campaign.startedDistributionAt,
      finishedDistributionAt: campaign.finishedDistributionAt,
      bankStatementFileUrl: campaign.bankStatementFileUrl,
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      noteByAuthority: campaign.noteByAuthority,
      period: {
        startDate,
        endDate,
      },
      announcements: announcements.map((announcement) => ({
        textContent: announcement.textContent,
        imageUrl: announcement.imageUrl,
        createdAt: campaign.createdAt,
      })),
      purchasedSupplies: campaign.supplies.map((supply) => ({
        supplyName: supply.supplyName,
        quantity: supply.quantity,
        unitPrice: supply.unitPrice,
        price: supply.price,
      })),
      donations: campaign.transactions.map((transaction) => ({
        transferType: transaction.transferType,
        transferAmount: transaction.transferAmount,
        transferBy: transaction.transferBy,
        donateAt: transaction.donateAt,
        message: transaction.message,
      })),
      createdAt: campaign.createdAt,
    };
  }
}