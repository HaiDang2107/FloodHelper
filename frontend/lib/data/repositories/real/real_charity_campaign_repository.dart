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
  Future<String> createDonateQr({
    required String campaignId,
    required BigInt amount,
  }) async {
    final payload = await _charityCampaignService.createDonateQr(
      campaignId: campaignId,
      amount: amount,
    );

    final qrLink = payload['qrLink']?.toString() ?? '';
    if (qrLink.isEmpty) {
      throw Exception('Missing qrLink in backend response');
    }
    return qrLink;
  }

  List<CharityCampaign> _parseAndDeduplicate(
    List<List<Map<String, dynamic>>> batches,
  ) {
    return CharityCampaignMappers.parseAndDeduplicateCampaigns(batches);
  }
}
