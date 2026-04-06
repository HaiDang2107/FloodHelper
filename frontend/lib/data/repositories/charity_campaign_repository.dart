import '../../domain/models/charity_campaign.dart';

abstract class CharityCampaignRepository {
  Future<List<CharityCampaign>> getExistingCampaigns();

  Future<List<CharityCampaign>> getMyCampaigns();

  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign);
}
