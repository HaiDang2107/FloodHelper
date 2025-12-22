import 'package:flutter/material.dart';
import '../models/charity_campaign.dart';
import '../widgets/charity_item.dart';
import '_base_charity_screen.dart';
import 'my_charity_screen.dart';

class ExistingCharityScreen extends StatefulWidget {
  const ExistingCharityScreen({super.key});

  @override
  State<ExistingCharityScreen> createState() => _ExistingCharityScreenState();
}

class _ExistingCharityScreenState extends State<ExistingCharityScreen> {
  // Dummy Data
  final List<CharityCampaign> _campaigns = [
    CharityCampaign(
      id: '1',
      name: 'Flood Relief for Central Region',
      benefactorName: 'Red Cross Vietnam',
      status: CampaignStatus.donating,
      bankAccountNumber: '1234567890',
      bankName: 'Vietcombank',
      reliefLocation: 'Hue, Vietnam',
      startDate: DateTime(2023, 10, 1),
      endDate: DateTime(2023, 11, 1),
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
      bankAccountNumber: '0987654321',
      bankName: 'Techcombank',
      reliefLocation: 'Quang Tri, Vietnam',
      startDate: DateTime(2023, 10, 2),
      endDate: DateTime(2023, 10, 30),
      announcements: [],
    ),
    CharityCampaign(
      id: '3',
      name: 'Clean Water Project',
      benefactorName: 'Clean Water Foundation',
      status: CampaignStatus.distributing,
      bankAccountNumber: '1122334455',
      bankName: 'BIDV',
      reliefLocation: 'Ha Tinh, Vietnam',
      startDate: DateTime(2023, 9, 15),
      endDate: DateTime(2023, 10, 15),
      announcements: [
        CampaignAnnouncement(
          text: 'Water filters are being distributed to 100 households.',
          date: DateTime(2023, 10, 20),
        ),
      ],
      purchasedSupplies: [
        PurchasedSupply(
            productName: 'Water Filter',
            buyAt: 'Dien May Xanh',
            quantity: 100,
            unitPrice: 500000),
      ],
    ),
    CharityCampaign(
      id: '4',
      name: 'School Rebuilding Fund',
      benefactorName: 'Education for All',
      status: CampaignStatus.finished,
      bankAccountNumber: '5566778899',
      bankName: 'Agribank',
      reliefLocation: 'Nghe An, Vietnam',
      startDate: DateTime(2023, 8, 1),
      endDate: DateTime(2023, 9, 1),
      announcements: [
        CampaignAnnouncement(
          text: 'The school has been rebuilt and students are back!',
          date: DateTime(2023, 9, 10),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseCharityScreen(
      title: 'Charity Campaigns',
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyCharityScreen()),
            );
          },
          icon: const Icon(Icons.volunteer_activism,
              size: 20, color: Color(0xFF0F62FE)),
          label: const Text('My Campaigns',
              style: TextStyle(color: Color(0xFF0F62FE))),
        ),
      ],
      tabs: const [
        Tab(text: 'Donating'),
        Tab(text: 'Distributing'),
        Tab(text: 'Finished'),
      ],
      tabViews: [
        _buildCampaignList(CampaignStatus.donating),
        _buildCampaignList(CampaignStatus.distributing),
        _buildCampaignList(CampaignStatus.finished),
      ],
    );
  }

  Widget _buildCampaignList(CampaignStatus status) {
    final filteredCampaigns =
        _campaigns.where((c) => c.status == status).toList();

    if (filteredCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No campaigns found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: filteredCampaigns.length,
      itemBuilder: (context, index) {
        return CharityItem(campaign: filteredCampaigns[index]);
      },
    );
  }
}
