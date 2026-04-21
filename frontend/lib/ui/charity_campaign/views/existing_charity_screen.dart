import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/global_session_provider.dart';
import '../../../domain/models/charity_campaign.dart';
import '../view_models/charity_campaign_view_model.dart';
import '../widgets/charity_item.dart';
import '_base_charity_screen.dart';
import 'my_charity_screen.dart';

class ExistingCharityFocusRequest {
  final String campaignId;
  final double latitude;
  final double longitude;

  const ExistingCharityFocusRequest({
    required this.campaignId,
    required this.latitude,
    required this.longitude,
  });
}

class ExistingCharityScreen extends ConsumerStatefulWidget {
  const ExistingCharityScreen({super.key});

  @override
  ConsumerState<ExistingCharityScreen> createState() =>
      _ExistingCharityScreenState();
}

class _ExistingCharityScreenState extends ConsumerState<ExistingCharityScreen> {
  static const List<CampaignStatus> _tabStatuses = [
    CampaignStatus.donating,
    CampaignStatus.distributing,
    CampaignStatus.finished,
  ];

  Future<void> _handleTabChanged(int index) async {
    if (index < 0 || index >= _tabStatuses.length) {
      return;
    }

    final status = _tabStatuses[index];
    await ref
        .read(charityCampaignViewModelProvider.notifier)
        .ensureExistingStatusLoaded(status);
  }

  Future<void> _focusCampaignOnHomeMap(
    BuildContext context,
    String campaignId,
    double latitude,
    double longitude,
  ) async {
    if (!context.mounted) { // mounted context được truyền vào hàm
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (!mounted) { // mounted của context hiện tại
      return;
    }

    Navigator.of(this.context).pop(
      ExistingCharityFocusRequest(
        campaignId: campaignId,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(charityCampaignViewModelProvider, (previous, next) {
      final errorMessage = next.errorMessage;
      if (errorMessage == null || errorMessage == previous?.errorMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      ref.read(charityCampaignViewModelProvider.notifier).clearError();
    });

    ref.watch(charityCampaignViewModelProvider);
    final viewModel = ref.read(charityCampaignViewModelProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);
    final isBenefactor = currentUser?.isBenefactor ?? false;

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
      onTabChanged: _handleTabChanged,
      tabViews: [
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(_tabStatuses[0]),
          isLoading: viewModel.isExistingStatusLoading(_tabStatuses[0]),
          onRefresh: () => viewModel.refreshExistingStatus(_tabStatuses[0]),
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(_tabStatuses[1]),
          isLoading: viewModel.isExistingStatusLoading(_tabStatuses[1]),
          onRefresh: () => viewModel.refreshExistingStatus(_tabStatuses[1]),
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.existingByStatus(_tabStatuses[2]),
          isLoading: viewModel.isExistingStatusLoading(_tabStatuses[2]),
          onRefresh: () => viewModel.refreshExistingStatus(_tabStatuses[2]),
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
      ],
    );
  }

  Widget _buildCampaignList({
    required List<CharityCampaign> campaigns,
    required bool isLoading,
    required Future<void> Function() onRefresh,
    required Future<CharityCampaign> Function(String campaignId)
    onLoadCampaignDetail,
  }) {
    if (isLoading) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 240),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (campaigns.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 200),
            Column(
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return CharityItem(
            campaign: campaigns[index],
            onLoadCampaignDetail: onLoadCampaignDetail,
            onLoadCampaignTransactions: ref
                .read(charityCampaignViewModelProvider.notifier)
                .loadSuccessTransactions,
            onFocusCampaignLocation: (campaignId, latitude, longitude) {
              return _focusCampaignOnHomeMap(
                context,
                campaignId,
                latitude,
                longitude,
              );
            },
          );
        },
      ),
    );
  }
}
