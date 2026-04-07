import '../../../domain/models/charity_campaign.dart';
import '../charity_campaign_repository.dart';

class MockCharityCampaignRepository implements CharityCampaignRepository {
  final List<CharityCampaign> _existingCampaigns = [
    CharityCampaign(
      id: '1',
      name: 'Flood Relief for Central Region',
      benefactorName: 'Red Cross Vietnam',
      status: CampaignStatus.donating,
      bankInfo: const BankInfo(
        accountNumber: '1234567890',
        bankName: 'Vietcombank',
      ),
      reliefLocation: 'Hue, Vietnam',
      period: DateRange(
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 11, 1),
      ),
      announcements: [
        CampaignAnnouncement(
          text: 'We have received 500 million VND so far. Thank you!',
          date: DateTime(2023, 10, 5),
        ),
      ],
    ),
    CharityCampaign(
      id: '2',
      name: 'Emergency Food Support',
      benefactorName: 'Local NGO',
      status: CampaignStatus.donating,
      bankInfo: const BankInfo(
        accountNumber: '0987654321',
        bankName: 'Techcombank',
      ),
      reliefLocation: 'Quang Tri, Vietnam',
      period: DateRange(
        startDate: DateTime(2023, 10, 2),
        endDate: DateTime(2023, 10, 30),
      ),
      announcements: const [],
    ),
    CharityCampaign(
      id: '3',
      name: 'Clean Water Project',
      benefactorName: 'Clean Water Foundation',
      status: CampaignStatus.distributing,
      bankInfo: const BankInfo(accountNumber: '1122334455', bankName: 'BIDV'),
      reliefLocation: 'Ha Tinh, Vietnam',
      period: DateRange(
        startDate: DateTime(2023, 9, 15),
        endDate: DateTime(2023, 10, 15),
      ),
      announcements: [
        CampaignAnnouncement(
          text: 'Water filters are being distributed to 100 households.',
          date: DateTime(2023, 10, 20),
        ),
      ],
      purchasedSupplies: const [
        PurchasedSupply(
          productName: 'Water Filter',
          vendor: 'Dien May Xanh',
          quantity: 100,
          unitPrice: 500000,
        ),
      ],
    ),
    CharityCampaign(
      id: '4',
      name: 'School Rebuilding Fund',
      benefactorName: 'Education for All',
      status: CampaignStatus.finished,
      bankInfo: const BankInfo(
        accountNumber: '5566778899',
        bankName: 'Agribank',
      ),
      reliefLocation: 'Nghe An, Vietnam',
      period: DateRange(
        startDate: DateTime(2023, 8, 1),
        endDate: DateTime(2023, 9, 1),
      ),
      announcements: [
        CampaignAnnouncement(
          text: 'The school has been rebuilt and students are back!',
          date: DateTime(2023, 9, 10),
        ),
      ],
    ),
  ];

  final List<CharityCampaign> _myCampaigns = [
    CharityCampaign(
      id: '5',
      name: 'My Local Relief Effort',
      benefactorName: 'Me',
      status: CampaignStatus.donating,
      bankInfo: const BankInfo(
        accountNumber: '1234567890',
        bankName: 'Vietcombank',
      ),
      reliefLocation: 'My Hometown',
      period: DateRange(
        startDate: DateTime(2023, 10, 10),
        endDate: DateTime(2023, 11, 10),
      ),
      announcements: [
        CampaignAnnouncement(
          text: 'Starting our campaign!',
          date: DateTime.now(),
        ),
      ],
      donations: [
        Donation(amount: 100000, donorName: 'Friend 1', date: DateTime.now()),
        Donation(
          amount: -500000,
          donorName: 'Printing Banners',
          date: DateTime.now(),
        ),
      ],
      purchasedSupplies: const [
        PurchasedSupply(
          productName: 'Banners',
          vendor: 'Local Print Shop',
          quantity: 10,
          unitPrice: 50000,
        ),
      ],
    ),
    CharityCampaign(
      id: '6',
      name: 'Pending Approval Campaign',
      benefactorName: 'Me',
      status: CampaignStatus.pending,
      bankInfo: const BankInfo(
        accountNumber: '0987654321',
        bankName: 'Techcombank',
      ),
      reliefLocation: 'Remote Area',
      period: DateRange(
        startDate: DateTime(2023, 11, 1),
        endDate: DateTime(2023, 12, 1),
      ),
      announcements: const [],
    ),
    CharityCampaign(
      id: '7',
      name: 'Winter Clothes Donation',
      benefactorName: 'Me',
      status: CampaignStatus.distributing,
      bankInfo: const BankInfo(
        accountNumber: '1122334455',
        bankName: 'MB Bank',
      ),
      reliefLocation: 'Sapa, Lao Cai',
      period: DateRange(
        startDate: DateTime(2023, 11, 15),
        endDate: DateTime(2023, 12, 15),
      ),
      announcements: [
        CampaignAnnouncement(
          text: 'Clothes are being distributed to local people.',
          date: DateTime.now(),
        ),
      ],
      purchasedSupplies: const [],
    ),
  ];

  @override
  Future<List<CharityCampaign>> getExistingCampaigns({
    CampaignStatus? status,
  }) async {
    if (status == null) {
      return List<CharityCampaign>.from(_existingCampaigns);
    }

    return _existingCampaigns
        .where((campaign) => campaign.status == status)
        .toList(growable: false);
  }

  @override
  Future<List<CharityCampaign>> getMyCampaigns({CampaignStatus? status}) async {
    if (status == null) {
      return List<CharityCampaign>.from(_myCampaigns);
    }

    return _myCampaigns
        .where((campaign) => campaign.status == status)
        .toList(growable: false);
  }

  @override
  Future<CharityCampaign> getCampaignDetail(String campaignId) async {
    final all = [..._existingCampaigns, ..._myCampaigns];
    return all.firstWhere((campaign) => campaign.id == campaignId);
  }

  @override
  Future<CharityCampaign> createMyCampaign(CharityCampaign campaign) async {
    _myCampaigns.insert(0, campaign);
    return campaign;
  }
}
