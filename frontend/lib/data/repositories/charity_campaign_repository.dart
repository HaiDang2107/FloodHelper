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
