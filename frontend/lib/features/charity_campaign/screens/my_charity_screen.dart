import 'package:flutter/material.dart';
import '../models/charity_campaign.dart';
import '../widgets/charity_item.dart';
import '_base_charity_screen.dart';
import '../widgets/dialog/create_campaign_dialog.dart';

class MyCharityScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const MyCharityScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<MyCharityScreen> createState() => _MyCharityScreenState();
}

class _MyCharityScreenState extends State<MyCharityScreen> {
  // Dummy Data for My Campaigns
  final List<CharityCampaign> _myCampaigns = [
    CharityCampaign(
      id: '5',
      name: 'My Local Relief Effort',
      benefactorName: 'Me',
      status: CampaignStatus.donating,
      bankAccountNumber: '1234567890',
      bankName: 'Vietcombank',
      reliefLocation: 'My Hometown',
      startDate: DateTime(2023, 10, 10),
      endDate: DateTime(2023, 11, 10),
      announcements: [
        CampaignAnnouncement(text: 'Starting our campaign!', date: DateTime.now())
      ],
      transactions: [
        Transaction(amount: 100000, name: 'Friend 1', date: DateTime.now()),
        Transaction(amount: -500000, name: 'Printing Banners', date: DateTime.now()),
      ],
      purchasedSupplies: [
        PurchasedSupply(
            productName: 'Banners',
            buyAt: 'Local Print Shop',
            quantity: 10,
            unitPrice: 50000),
      ],
    ),
    CharityCampaign(
      id: '6',
      name: 'Pending Approval Campaign',
      benefactorName: 'Me',
      status: CampaignStatus.pending,
      bankAccountNumber: '0987654321',
      bankName: 'Techcombank',
      reliefLocation: 'Remote Area',
      startDate: DateTime(2023, 11, 1),
      endDate: DateTime(2023, 12, 1),
      announcements: [],
    ),
    CharityCampaign(
      id: '7',
      name: 'Winter Clothes Donation',
      benefactorName: 'Me',
      status: CampaignStatus.distributing,
      bankAccountNumber: '1122334455',
      bankName: 'MB Bank',
      reliefLocation: 'Sapa, Lao Cai',
      startDate: DateTime(2023, 11, 15),
      endDate: DateTime(2023, 12, 15),
      announcements: [
        CampaignAnnouncement(
          text: 'Clothes are being distributed to local people.',
          date: DateTime.now(),
        ),
      ],
      purchasedSupplies: [],
    ),
  ];

  void _showCreateCampaignDialog() async {
    final CharityCampaign? result = await showDialog<CharityCampaign>(
      context: context,
      builder: (context) => const CreateCampaignDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _myCampaigns.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseCharityScreen(
      title: 'My Charity Campaigns',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Color(0xFF0F62FE)),
          onPressed: _showCreateCampaignDialog,
        ),
      ],
      tabs: const [
        Tab(text: 'Pending'),
        Tab(text: 'Accepted'),
        Tab(text: 'Rejected'),
        Tab(text: 'Donating'),
        Tab(text: 'Distributing'),
        Tab(text: 'Finished'),
      ],
      tabViews: [
        _buildCampaignList(CampaignStatus.pending),
        _buildCampaignList(CampaignStatus.accepted),
        _buildCampaignList(CampaignStatus.rejected),
        _buildCampaignList(CampaignStatus.donating),
        _buildCampaignList(CampaignStatus.distributing),
        _buildCampaignList(CampaignStatus.finished),
      ],
    );
  }

  Widget _buildCampaignList(CampaignStatus status) {
    final filteredCampaigns =
        _myCampaigns.where((c) => c.status == status).toList();

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
        return CharityItem(
          campaign: filteredCampaigns[index],
          isOwner: true,
        );
      },
    );
  }
}