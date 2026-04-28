import 'dart:typed_data';

import '../../domain/models/charity_campaign.dart';
import '../models/campaign_announcement_page.dart';

export '../models/campaign_announcement_page.dart';

abstract class CharityCampaignRepository {
  Future<List<CharityCampaign>> getExistingCampaigns({CampaignStatus? status});

  Future<List<CharityCampaign>> getMyCampaigns({CampaignStatus? status});

  Future<CharityCampaign> getCampaignDetail(String campaignId);

  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign);

  Future<CharityCampaign> updateMyCampaign(CharityCampaign campaign);

  Future<CharityCampaign> sendCampaignRequest(String campaignId);

  Future<void> updateCampaignLocation({
    required String campaignId,
    required double latitude,
    required double longitude,
  });

  Future<List<CharityCampaignLocation>> getDistributingCampaignLocations();

  Future<DonateQrResult> createDonateQr({
    required String campaignId,
    required BigInt amount,
  });

  Future<String> triggerDonateTestCallback({required String transactionId});

  Future<List<Donation>> getCampaignTransactions({
    required String campaignId,
    String state,
  });

  Future<CampaignAnnouncementPage> getCampaignAnnouncements({
    required String campaignId,
    int limit,
    String? beforePostedAt,
  });

  Future<CampaignAnnouncement> createCampaignAnnouncement({
    required String campaignId,
    required String caption,
    required String imagePath,
    String? imageName,
  });

  Future<CharityCampaign> uploadCampaignBankStatement({
    required String campaignId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    void Function(int sent, int total)? onSendProgress,
  });

  Future<CharityCampaign> deleteCampaignBankStatement({
    required String campaignId,
  });

  Future<List<PurchasedSupply>> getCampaignSupplies({
    required String campaignId,
  });

  Future<PurchasedSupply> createCampaignSupply({
    required String campaignId,
    required PurchasedSupply supply,
  });

  Future<PurchasedSupply> updateCampaignSupply({
    required String campaignId,
    required PurchasedSupply supply,
  });

  Future<void> deleteCampaignSupply({
    required String campaignId,
    required String supplyId,
  });

  Future<List<FinancialSupportAllocation>> getCampaignFinancialSupports({
    required String campaignId,
  });

  Future<FinancialSupportAllocation> createCampaignFinancialSupport({
    required String campaignId,
    required FinancialSupportAllocation support,
  });

  Future<FinancialSupportAllocation> updateCampaignFinancialSupport({
    required String campaignId,
    required FinancialSupportAllocation support,
  });

  Future<void> deleteCampaignFinancialSupport({
    required String campaignId,
    required String financialSupportId,
  });
}
