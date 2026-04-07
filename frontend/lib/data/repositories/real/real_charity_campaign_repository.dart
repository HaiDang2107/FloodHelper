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
    final statuses = status == null ? _allStatuses : <CampaignStatus>[status];

    final resultBatches = await Future.wait(
      statuses.map(_charityCampaignService.getExistingCampaignsByState),
    );

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
    // Backend create endpoint is not implemented yet.
    // Return input so current UI flow remains functional.
    return campaign;
  }

  List<CharityCampaign> _parseAndDeduplicate(
    List<List<Map<String, dynamic>>> batches,
  ) {
    return CharityCampaignMappers.parseAndDeduplicateCampaigns(batches);
  }
}
