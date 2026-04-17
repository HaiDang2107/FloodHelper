import '../../../domain/models/charity_campaign.dart';
import '../../mappers/charity_campaign_mappers.dart';
import '../../services/charity_campaign_service.dart';
import '../charity_campaign_repository.dart';

class RealCharityCampaignRepository implements CharityCampaignRepository {
  final CharityCampaignService _charityCampaignService;

  RealCharityCampaignRepository({
    required CharityCampaignService charityCampaignService,
  }) : _charityCampaignService = charityCampaignService;

  static const List<CampaignStatus> _allStatuses = [
    CampaignStatus.created,
    CampaignStatus.pending,
    CampaignStatus.approved,
    CampaignStatus.rejected,
    CampaignStatus.donating,
    CampaignStatus.distributing,
    CampaignStatus.finished,
  ];

  @override
  Future<List<CharityCampaign>> getExistingCampaigns({
    CampaignStatus? status,
  }) async {
    final statuses = status == null ? _allStatuses : <CampaignStatus>[status]; // Nhận vào danh sách status 

    final resultBatches = await Future.wait(
      statuses.map(_charityCampaignService.getExistingCampaignsByState), // Gọi song song cho từng trạng thái thay vì chạy vòng for
    );
    // Kết quả trả về là list of list
    // ==> cần làm phẳng và parse. Việc loại bỏ duplicate là optional (phòng thủ)

    return _parseAndDeduplicate(resultBatches);
  }

  @override
  Future<List<CharityCampaign>> getMyCampaigns({CampaignStatus? status}) async {
    final statuses = status == null ? _allStatuses : <CampaignStatus>[status];

    final resultBatches = await Future.wait(
      statuses.map(_charityCampaignService.getMyCampaignsByState),
    );

    return _parseAndDeduplicate(resultBatches);
  }

  @override
  Future<CharityCampaign> getCampaignDetail(String campaignId) async {
    final payload = await _charityCampaignService.getCampaignDetail(campaignId);
    return CharityCampaignMappers.campaignFromApi(payload);
  }

  @override
  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign) async {
    final payload = await _charityCampaignService.createCampaign(
      CharityCampaignMappers.mutationPayloadFromCampaign(campaign),
    );
    return CharityCampaignMappers.campaignFromApi(payload);
  }

  @override
  Future<CharityCampaign> updateMyCampaign(CharityCampaign campaign) async {
    final payload = await _charityCampaignService.updateCampaign(
      campaign.id,
      CharityCampaignMappers.mutationPayloadFromCampaign(campaign),
    );
    return CharityCampaignMappers.campaignFromApi(payload);
  }

  @override
  Future<CharityCampaign> sendCampaignRequest(String campaignId) async {
    final payload = await _charityCampaignService.sendCampaignRequest(campaignId);
    return CharityCampaignMappers.campaignFromApi(payload);
  }

  @override
  Future<DonateQrResult> createDonateQr({
    required String campaignId,
    required BigInt amount,
  }) async {
    final payload = await _charityCampaignService.createDonateQr(
      campaignId: campaignId,
      amount: amount,
    );

    final qrLink =
        payload['qrLink']?.toString() ?? payload['qrCode']?.toString() ?? '';
    final transactionId = payload['transactionId']?.toString() ?? '';
    if (qrLink.isEmpty) {
      throw Exception('Missing qrLink in backend response');
    }
    if (transactionId.isEmpty) {
      throw Exception('Missing transactionId in backend response');
    }

    return DonateQrResult(
      qrLink: qrLink,
      transactionId: transactionId,
    );
  }

  @override
  Future<String> triggerDonateTestCallback({required String transactionId}) async {
    final payload = await _charityCampaignService.triggerDonateTestCallback(
      transactionId: transactionId,
    );

    return payload['state']?.toString() ?? 'VERIFYING';
  }

  @override
  Future<List<Donation>> getCampaignTransactions({
    required String campaignId,
    String state = 'SUCCESS',
  }) async {
    final payload = await _charityCampaignService.getCampaignTransactions(
      campaignId: campaignId,
      state: state,
    );
    return CharityCampaignMappers.donationsFromApiList(payload);
  }

  @override
  Future<List<PurchasedSupply>> getCampaignSupplies({
    required String campaignId,
  }) async {
    final payload = await _charityCampaignService.getCampaignSupplies(
      campaignId: campaignId,
    );

    return payload.map(_supplyFromApi).toList(growable: false);
  }

  @override
  Future<PurchasedSupply> createCampaignSupply({
    required String campaignId,
    required PurchasedSupply supply,
  }) async {
    final payload = await _charityCampaignService.createCampaignSupply(
      campaignId: campaignId,
      payload: {
        'supplyName': supply.productName,
        'quantity': supply.quantity,
        'unitPrice': supply.unitPrice,
        if (supply.boughtAt != null) 'boughtAt': supply.boughtAt!.toIso8601String(),
      },
    );

    return _supplyFromApi(payload);
  }

  @override
  Future<PurchasedSupply> updateCampaignSupply({
    required String campaignId,
    required PurchasedSupply supply,
  }) async {
    final supplyId = supply.supplyId;
    if (supplyId == null || supplyId.isEmpty) {
      throw Exception('Cannot update supply without supplyId');
    }

    final payload = await _charityCampaignService.updateCampaignSupply(
      campaignId: campaignId,
      supplyId: supplyId,
      payload: {
        'supplyName': supply.productName,
        'quantity': supply.quantity,
        'unitPrice': supply.unitPrice,
        if (supply.boughtAt != null) 'boughtAt': supply.boughtAt!.toIso8601String(),
      },
    );

    return _supplyFromApi(payload);
  }

  @override
  Future<void> deleteCampaignSupply({
    required String campaignId,
    required String supplyId,
  }) {
    return _charityCampaignService.deleteCampaignSupply(
      campaignId: campaignId,
      supplyId: supplyId,
    );
  }

  @override
  Future<List<FinancialSupportAllocation>> getCampaignFinancialSupports({
    required String campaignId,
  }) async {
    final payload = await _charityCampaignService.getCampaignFinancialSupports(
      campaignId: campaignId,
    );

    return payload.map(_financialSupportFromApi).toList(growable: false);
  }

  @override
  Future<FinancialSupportAllocation> createCampaignFinancialSupport({
    required String campaignId,
    required FinancialSupportAllocation support,
  }) async {
    final payload = await _charityCampaignService.createCampaignFinancialSupport(
      campaignId: campaignId,
      payload: {
        'householdName': support.householdName,
        'amount': support.amount,
        if (support.allocatedAt != null)
          'allocatedAt': support.allocatedAt!.toIso8601String(),
      },
    );

    return _financialSupportFromApi(payload);
  }

  @override
  Future<FinancialSupportAllocation> updateCampaignFinancialSupport({
    required String campaignId,
    required FinancialSupportAllocation support,
  }) async {
    final supportId = support.financialSupportId;
    if (supportId == null || supportId.isEmpty) {
      throw Exception('Cannot update financial support without financialSupportId');
    }

    final payload = await _charityCampaignService.updateCampaignFinancialSupport(
      campaignId: campaignId,
      financialSupportId: supportId,
      payload: {
        'householdName': support.householdName,
        'amount': support.amount,
        if (support.allocatedAt != null)
          'allocatedAt': support.allocatedAt!.toIso8601String(),
      },
    );

    return _financialSupportFromApi(payload);
  }

  @override
  Future<void> deleteCampaignFinancialSupport({
    required String campaignId,
    required String financialSupportId,
  }) {
    return _charityCampaignService.deleteCampaignFinancialSupport(
      campaignId: campaignId,
      financialSupportId: financialSupportId,
    );
  }

  List<CharityCampaign> _parseAndDeduplicate(
    List<List<Map<String, dynamic>>> batches,
  ) {
    return CharityCampaignMappers.parseAndDeduplicateCampaigns(batches);
  }

  PurchasedSupply _supplyFromApi(Map<String, dynamic> item) {
    final quantity = int.tryParse(item['quantity']?.toString() ?? '') ?? 0;
    final unitPrice = double.tryParse(item['unitPrice']?.toString() ?? '') ?? 0;

    return PurchasedSupply(
      supplyId: item['supplyId']?.toString(),
      productName: (item['supplyName'] ?? item['productName'] ?? '').toString(),
      vendor: (item['vendor'] ?? '').toString(),
      quantity: quantity,
      unitPrice: unitPrice,
      boughtAt: DateTime.tryParse(item['boughtAt']?.toString() ?? ''),
    );
  }

  FinancialSupportAllocation _financialSupportFromApi(Map<String, dynamic> item) {
    final amount = double.tryParse(item['amount']?.toString() ?? '') ?? 0;
    return FinancialSupportAllocation(
      financialSupportId: item['financialSupportId']?.toString(),
      householdName: (item['householdName'] ?? '').toString(),
      amount: amount,
      allocatedAt: DateTime.tryParse(item['allocatedAt']?.toString() ?? ''),
    );
  }
}
