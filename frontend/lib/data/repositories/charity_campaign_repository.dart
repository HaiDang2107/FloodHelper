import '../../domain/models/charity_campaign.dart';

abstract class CharityCampaignRepository {
  Future<List<CharityCampaign>> getExistingCampaigns({CampaignStatus? status});

  Future<List<CharityCampaign>> getMyCampaigns({CampaignStatus? status});

  Future<CharityCampaign> getCampaignDetail(String campaignId);

  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign);

  Future<CharityCampaign> updateMyCampaign(CharityCampaign campaign);

  Future<CharityCampaign> sendCampaignRequest(String campaignId);

  Future<DonateQrResult> createDonateQr({
    required String campaignId,
    required BigInt amount,
  });

  Future<String> triggerDonateTestCallback({required String transactionId});

  Future<List<Donation>> getCampaignTransactions({
    required String campaignId,
    String state,
  });
}
