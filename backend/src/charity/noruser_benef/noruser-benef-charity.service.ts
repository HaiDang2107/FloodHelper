import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { CampaignState, Prisma, TransactionState } from '@prisma/client';
import { extname } from 'node:path';
import {
  CreateCampaignDto,
  QueryCampaignAnnouncementsDto,
  QueryCampaignTransactionsDto,
  UpdateCampaignLocationDto,
  UpdateCampaignDto,
} from './dto';
import { CommonCharityService } from '../common.service';
import { VietQrInternalService } from '../vietqr/vietqr-internal.service';
import { VietQrService } from '../vietqr/vietqr.service';
import { CharityRepository, UserRepository } from '../../prisma/repositories';
import { formatLocation } from '../../common/location-format.util';
import { CloudinaryService } from '../../common/cloudinary.service';
import { UploadedFilePayload } from '../../common/uploaded-file.type';

type ResolvedBank = {
  id: number;
  name: string;
  code: string;
  shortName: string;
};

type CharityCampaignListItemPayload = {
  campaignId: string;
  campaignName: string;
  state: CampaignState;
  createdAt: Date;
  requestedAt: Date | null;
  respondedAt: Date | null;
  organizer?: {
    userId: string;
    fullname: string;
    nickname: string | null;
    residenceProvinceCode: number | null;
    residenceWardCode: number | null;
    residenceProvince?: { code: number; name: string } | null;
    residenceWard?: { code: number; name: string } | null;
  } | null;
};

@Injectable()
export class NoruserBenefCharityService {
  private readonly allowedStates = new Set<CampaignState>([
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'SUSPENDED',
    'FINISHED',
  ]);

  private static readonly ALLOWED_TRANSACTION_STATES = new Set<TransactionState>([
    'CREATED',
    'VERIFYING',
    'SUCCESS',
    'FAILED',
    'EXPIRED',
  ]);

  constructor(
    private readonly charityRepository: CharityRepository,
    private readonly userRepository: UserRepository,
    private readonly commonCharityService: CommonCharityService,
    private readonly vietQrService: VietQrService,
    private readonly vietQrInternalService: VietQrInternalService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  async listExistingCampaignsByState(state: string) {
    const normalizedState = this.normalizeAndValidateState(state);
    if (normalizedState === 'CREATED') {
      return [];
    }

    const campaigns = await this.charityRepository.listCampaignsByState(normalizedState as any);
    return campaigns.map((campaign) => this.mapCampaignListItem(campaign as any));
  }

  async listMyCampaignsByState(userId: string, state: string) {
    const normalizedState = this.normalizeAndValidateState(state);

    const campaigns = await this.charityRepository.listCampaignsByOrganizer(userId);
    const filtered = campaigns.filter((c: any) => String(c.state).toUpperCase() === String(normalizedState).toUpperCase());
    return filtered.map((campaign) => this.mapCampaignListItem(campaign as any));
  }

  getCampaignDetail(campaignId: string) {
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  listBanks() {
    return this.commonCharityService.listBanks();
  }

  async listDistributingCampaignLocations() { // Lấy vị trí của các distributing campaign 
    const campaigns = await this.charityRepository.listCampaignsByState('DISTRIBUTING');
    return (campaigns || [])
      .filter((c: any) => c.campaignLatitude != null && c.campaignLongitude != null)
      .map((campaign: any) => ({
        campaignId: campaign.campaignId,
        campaignName: campaign.campaignName,
        destination: campaign.destinationDetail,
        latitude: Number(campaign.campaignLatitude),
        longitude: Number(campaign.campaignLongitude),
      }));
  }

  async listCampaignTransactions(
    campaignId: string,
    query: QueryCampaignTransactionsDto,
  ) {
    const normalizedState = (query.state ?? 'SUCCESS').trim().toUpperCase() as TransactionState;
    if (!NoruserBenefCharityService.ALLOWED_TRANSACTION_STATES.has(normalizedState)) {
      throw new BadRequestException(
        'Invalid transaction state. Allowed values: CREATED, VERIFYING, SUCCESS, FAILED, EXPIRED',
      );
    }

    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');

    const transactions = await this.charityRepository.getCampaignTransactions(campaignId);
    const filtered = (transactions || []).filter((t: any) => String(t.state).toUpperCase() === String(normalizedState).toUpperCase());

    const donorIds = Array.from(new Set(filtered.map((t: any) => t.donatedBy).filter(Boolean)));
    const donors = donorIds.length ? await this.userRepository.findUsersByIds(donorIds) : [];
    const donorNameById = new Map(donors.map((d: any) => [d.userId, d.fullname]));

    return filtered.map((transaction: any) => ({
      transactionId: transaction.transactionId,
      state: String(transaction.state).toUpperCase(),
      amount: transaction.amount,
      donorName: (transaction.donatedBy ? donorNameById.get(transaction.donatedBy) : undefined) || 'Anonymous',
      date: transaction.transactionTime ?? transaction.donateAt,
      message: transaction.content,
    }));
  }

  async listCampaignAnnouncements(
    campaignId: string,
    query: QueryCampaignAnnouncementsDto,
  ) {
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');

    const rawLimit = Number(query.limit ?? 10);
    const limit = Number.isFinite(rawLimit)
      ? Math.min(Math.max(Math.floor(rawLimit), 1), 50)
      : 10;
    const beforePostedAt = query.beforePostedAt
      ? new Date(query.beforePostedAt)
      : null;

    const announcements = await this.charityRepository.listAnnouncementsByCampaign(campaignId);
    const itemsAll = announcements || [];
    const filteredByCursor = beforePostedAt ? itemsAll.filter((a: any) => new Date(a.postedAt) < beforePostedAt) : itemsAll;
    const items = filteredByCursor.slice(0, limit + 1);

    const hasMore = items.length > limit;
    const finalItems = hasMore ? items.slice(0, limit) : items;
    const nextCursor = hasMore && finalItems.length > 0 ? finalItems[finalItems.length - 1].postedAt.toISOString() : null;

    return {
      items: finalItems.map((announcement: any) => ({
        announcementId: announcement.announcementId,
        caption: announcement.caption,
        imageUrl: announcement.imageUrl,
        postedAt: announcement.postedAt,
      })),
      pagination: {
        hasMore,
        nextCursor,
      },
    };
  }

  async createCampaignAnnouncement(
    userId: string,
    campaignId: string,
    caption: string,
    file?: UploadedFilePayload,
  ) {
    await this.assertCampaignAnnouncementAllowed(userId, campaignId);

    const imageUrl = file ? await this.cloudinaryService.uploadImage(file.buffer, { folder: `floodhelper/announcements/${campaignId}` }) : null;
    const announcement = await this.charityRepository.createAnnouncementFromBenefactor(campaignId, { caption: caption.trim(), imageUrl, postedAt: new Date() });

    return {
      announcementId: announcement.announcementId,
      caption: announcement.caption,
      imageUrl: announcement.imageUrl,
      postedAt: announcement.postedAt,
    };
  }

  async uploadCampaignBankStatement(
    userId: string,
    campaignId: string,
    file: UploadedFilePayload,
  ) {
    await this.assertCampaignBankStatementAllowed(userId, campaignId);

    const fileExtension = this.getFileExtension(file.originalname);
    const fileUrl = await this.cloudinaryService.uploadRawFile(file.buffer, {
      folder: `floodhelper/bank-statements/${campaignId}`,
      publicId: `statement${fileExtension}`,
    });

    await this.charityRepository.updateCampaign(campaignId, { bankStatementFileUrl: fileUrl });
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  async deleteCampaignBankStatement(userId: string, campaignId: string) {
    await this.assertCampaignBankStatementAllowed(userId, campaignId);

    const detail = await this.charityRepository.getCampaignDetail(campaignId);
    const publicId = this.getBankStatementPublicId(detail?.bankStatementFileUrl, campaignId);
    await this.cloudinaryService.deleteRawFile(publicId);
    await this.charityRepository.updateCampaign(campaignId, { bankStatementFileUrl: null });
    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  private getFileExtension(fileName: string) {
    const extension = extname(fileName).trim().toLowerCase();
    if (!extension) {
      throw new BadRequestException('Bank statement file must have an extension');
    }

    return extension;
  }

  private getBankStatementPublicId(fileUrl: string | null | undefined, campaignId: string) { // Lấy relative path trên cloudinary
    const fallbackPublicId = `floodhelper/bank-statements/${campaignId}/statement`;

    if (!fileUrl) {
      return fallbackPublicId;
    }

    try {
      const url = new URL(fileUrl);
      const uploadIndex = url.pathname.indexOf('/upload/');
      if (uploadIndex === -1) {
        return fallbackPublicId;
      }

      const publicIdWithVersion = url.pathname.slice(uploadIndex + '/upload/'.length);
      const publicId = publicIdWithVersion.replace(/^v\d+\//, '');
      return publicId || fallbackPublicId;
    } catch {
      return fallbackPublicId;
    }
  }

  private async assertCampaignAnnouncementAllowed(userId: string, campaignId: string) {
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');
    if (campaign.organizedBy !== userId) throw new ForbiddenException('You are not allowed to post announcements');
    const state = String(campaign.state).toUpperCase();
    if (state !== 'DONATING' && state !== 'DISTRIBUTING' && state !== 'FINISHED') {
      throw new BadRequestException('Announcements can only be posted when campaign is DONATING, DISTRIBUTING or FINISHED');
    }
  }

  private async assertCampaignBankStatementAllowed(userId: string, campaignId: string) {
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');
    if (campaign.organizedBy !== userId) throw new ForbiddenException('You are not allowed to update bank statement');
    const state = String(campaign.state).toUpperCase();
    if (state === 'DONATING' || state === 'DISTRIBUTING') throw new BadRequestException('Bank statement can only be updated when campaign is not in DONATING or DISTRIBUTING');
  }

  async createCampaign(userId: string, payload: CreateCampaignDto) {
    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.charityRepository.ensureBankAccount({ bankId: payload.bankId, bankName: payload.bankName, bankAccountNumber: payload.bankAccountNumber, bankAccountName: payload.bankAccountName });

    const created = await this.charityRepository.createCampaign(userId, {
      campaignName: payload.campaignName.trim(),
      purpose: payload.purpose.trim(),
      destinationProvinceCode: payload.destinationProvinceCode ?? null,
      destinationWardCode: payload.destinationWardCode ?? null,
      destinationDetail: payload.destinationDetail?.trim() || payload.destination?.trim() || null,
      charityObject: payload.charityObject.trim(),
    });

    await this.charityRepository.updateCampaign(created.campaignId, {
      bankAccountId,
      startedDonationAt: timeline.startedDonationAt,
      finishedDonationAt: timeline.finishedDonationAt,
      startedDistributionAt: timeline.startedDistributionAt,
      finishedDistributionAt: timeline.finishedDistributionAt,
      bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
    });

    return this.commonCharityService.getCampaignDetail(created.campaignId);
  }

  async updateCampaign(
    userId: string,
    campaignId: string,
    payload: UpdateCampaignDto,
  ) {
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');
    if (campaign.organizedBy !== userId) throw new ForbiddenException('You are not allowed to update this campaign');
    if (String(campaign.state).toUpperCase() !== 'CREATED') throw new BadRequestException('Only CREATED campaigns can be updated');

    const timeline = this.parseAndValidateTimeline(payload);
    const bankAccountId = await this.charityRepository.ensureBankAccount({ bankId: payload.bankId, bankName: payload.bankName, bankAccountNumber: payload.bankAccountNumber, bankAccountName: payload.bankAccountName });

    await this.charityRepository.updateCampaign(campaignId, {
      bankAccountId,
      campaignName: payload.campaignName.trim(),
      purpose: payload.purpose.trim(),
      destinationProvinceCode: payload.destinationProvinceCode ?? null,
      destinationWardCode: payload.destinationWardCode ?? null,
      destinationDetail: payload.destinationDetail?.trim() || payload.destination?.trim() || null,
      charityObject: payload.charityObject.trim(),
      startedDonationAt: timeline.startedDonationAt,
      finishedDonationAt: timeline.finishedDonationAt,
      startedDistributionAt: timeline.startedDistributionAt,
      finishedDistributionAt: timeline.finishedDistributionAt,
      bankStatementFileUrl: payload.bankStatementFileUrl?.trim() || null,
    });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  async updateCampaignLocation(
    userId: string,
    campaignId: string,
    payload: UpdateCampaignLocationDto,
  ) { // Update vị trí của campaign
    const campaign = await this.charityRepository.getCampaignOwnership(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');
    if (campaign.organizedBy !== userId) throw new ForbiddenException('You are not allowed to check in this campaign location');
    const state = String(campaign.state).toUpperCase();
    if (state !== 'DISTRIBUTING') throw new BadRequestException('Campaign location can only be checked in when campaign is DISTRIBUTING');

    const updated = await this.charityRepository.updateCampaign(campaignId, {
      campaignLatitude: payload.latitude,
      campaignLongitude: payload.longitude,
    });

    return {
      campaignId: updated.campaignId,
      destination: updated.destinationDetail,
      latitude: Number(updated.campaignLatitude),
      longitude: Number(updated.campaignLongitude),
    };
  }

  async sendCampaignRequest(userId: string, campaignId: string) {
    const campaign = await this.charityRepository.getCampaignDetail(campaignId);
    if (!campaign) throw new NotFoundException('Charity campaign not found');
    if (campaign.organizedBy !== userId) throw new ForbiddenException('You are not allowed to send this campaign');
    if (String(campaign.state).toUpperCase() !== 'CREATED') throw new BadRequestException('Only CREATED campaigns can be submitted');
    if (!campaign.bankAccountId) throw new BadRequestException('Campaign bank account is required');
    if (!campaign.organizer?.profiles?.[0]?.residenceWardCode) throw new BadRequestException('Benefactor residence ward is required before sending campaign request');

    const authorities = await this.userRepository.findAuthoritiesByWard(campaign.organizer.profiles[0].residenceWardCode);
    const assignedAuthority = authorities && authorities.length > 0 ? authorities[0] : null;
    if (!assignedAuthority) throw new BadRequestException('No authority account found for benefactor residence area');

    this.validateTimelineValues(campaign.startedDonationAt, campaign.finishedDonationAt, campaign.startedDistributionAt, campaign.finishedDistributionAt);

    await this.charityRepository.updateCampaign(campaignId, { state: 'PENDING', requestedAt: new Date(), checkedBy: assignedAuthority.userId });

    return this.commonCharityService.getCampaignDetail(campaignId);
  }

  createDonationQr(campaignId: string, amountInput: string, donorUserId: string) {
    return this.vietQrService.createDonationQr(
      campaignId,
      amountInput,
      donorUserId,
    );
  }

  triggerTestCallback(transactionId: string, requesterUserId: string) {
    return this.vietQrService.triggerTestCallback(
      transactionId,
      requesterUserId,
    );
  }

  createDonationQrInternal(
    campaignId: string,
    amountInput: string,
    donorUserId: string,
  ) {
    return this.vietQrInternalService.createDonationQrInternal(
      campaignId,
      amountInput,
      donorUserId,
    );
  }

  triggerTestCallbackInternal(transactionId: string, requesterUserId: string) {
    return this.vietQrInternalService.triggerTestCallbackInternal(
      transactionId,
      requesterUserId,
    );
  }

  private normalizeAndValidateState(state: string): CampaignState {
    if (!state) {
      throw new BadRequestException('state is required');
    }

    const normalized = state.trim().toUpperCase();
    const mapped: CampaignState =
      normalized === 'ACCEPTED' ? 'APPROVED' : (normalized as CampaignState);

    if (!this.allowedStates.has(mapped)) {
      throw new BadRequestException(
        'Invalid state. Allowed values: CREATED, PENDING, APPROVED, REJECTED, DONATING, DISTRIBUTING, SUSPENDED, FINISHED',
      );
    }

    return mapped as CampaignState;
  }

  private getOrderByForState(
    state: CampaignState,
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
      case 'SUSPENDED':
        return [{ respondedAt: 'desc' }, { createdAt: 'desc' }];
      case 'CREATED':
      default:
        return [{ createdAt: 'desc' }];
    }
  }

  private mapCampaignListItem(campaign: CharityCampaignListItemPayload) {
    return {
      id: campaign.campaignId,
      name: campaign.campaignName,
      organizedBy: campaign.organizer?.userId ?? null,
      organizerResidence: formatLocation(
        campaign.organizer?.residenceWard,
        campaign.organizer?.residenceProvince,
      ),
      benefactorName:
        campaign.organizer?.fullname || campaign.organizer?.nickname || 'Unknown',
      state: String(campaign.state).toUpperCase(),
      requestedAt: campaign.requestedAt,
      respondedAt: campaign.respondedAt,
      createdAt: campaign.createdAt,
    };
  }

  private normalizeBankPayload(payload: {
    bankId?: number;
    bankName?: string;
    bankAccountNumber: string;
    bankAccountName?: string;
  }) {
    return {
      bankId: payload.bankId,
      bankName: payload.bankName?.trim(),
      bankAccountNumber: payload.bankAccountNumber.trim(),
      userBankName: payload.bankAccountName?.trim() || 'UNKNOWN',
    };
  }

  // Bank resolution & account creation delegated to CharityRepository.ensureBankAccount

  // Bank account resolution now delegated to CharityRepository.ensureBankAccount

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
}
