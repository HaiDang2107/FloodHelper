import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/global_session_provider.dart';
import '../../../domain/models/charity_campaign.dart';
import '../view_models/charity_campaign_view_model.dart';
import '../widgets/charity_item.dart';
import '_base_charity_screen.dart';
import 'my_charity_screen.dart';

class ExistingCharityScreen extends ConsumerWidget {
  const ExistingCharityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(charityCampaignViewModelProvider);
    final viewModel = ref.read(charityCampaignViewModelProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);
    final isBenefactor = currentUser?.isBenefactor ?? false;

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        viewModel.clearError();
      });
    }

    return BaseCharityScreen(
      title: 'Charity Campaigns',
      actions: isBenefactor
          ? [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCharityScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.volunteer_activism,
                  size: 20,
                  color: Color(0xFF0F62FE),
                ),
                label: const Text(
                  'My Campaigns',
                  style: TextStyle(color: Color(0xFF0F62FE)),
                ),
              ),
            ]
          : null,
      tabs: const [
        Tab(text: 'Donating'),
        Tab(text: 'Distributing'),
        Tab(text: 'Finished'),
      ],
      tabViews: [
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(CampaignStatus.donating),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(CampaignStatus.distributing),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(CampaignStatus.finished),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
      ],
    );
  }

  Widget _buildCampaignList({
    required List<CharityCampaign> campaigns,
    required bool isLoading,
    required Future<CharityCampaign> Function(String campaignId)
    onLoadCampaignDetail,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (campaigns.isEmpty) {
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
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        return CharityItem(
          campaign: campaigns[index],
          onLoadCampaignDetail: onLoadCampaignDetail,
        );
      },
    );
  }
}
