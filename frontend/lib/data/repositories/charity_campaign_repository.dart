import '../../domain/models/charity_campaign.dart';

abstract class CharityCampaignRepository {
  Future<List<CharityCampaign>> getExistingCampaigns({CampaignStatus? status});

  Future<List<CharityCampaign>> getMyCampaigns({CampaignStatus? status});

  Future<CharityCampaign> getCampaignDetail(String campaignId);

  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign);
}
