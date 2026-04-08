import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/charity_campaign.dart';
import '../view_models/charity_campaign_view_model.dart';
import '../widgets/charity_item.dart';
import '_base_charity_screen.dart';
import '../widgets/dialog/create_campaign_dialog.dart';

class MyCharityScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const MyCharityScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<MyCharityScreen> createState() => _MyCharityScreenState();
}

class _MyCharityScreenState extends ConsumerState<MyCharityScreen> {
  void _showCreateCampaignDialog() async {
    final CharityCampaign? result = await showDialog<CharityCampaign>(
      context: context,
      builder: (context) => const CreateCampaignDialog(),
    );

    if (result != null && mounted) {
      await ref
          .read(charityCampaignViewModelProvider.notifier)
          .createCampaign(result);
    }
  }

  Future<void> _showUpdateCampaignDialog(CharityCampaign campaign) async {
    final CharityCampaign? result = await showDialog<CharityCampaign>(
      context: context,
      builder: (context) => CreateCampaignDialog(campaignToEdit: campaign),
    );

    if (result != null && mounted) {
      await ref.read(charityCampaignViewModelProvider.notifier).updateCampaign(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charityCampaignViewModelProvider);
    final viewModel = ref.read(charityCampaignViewModelProvider.notifier);
    final errorMessage = state.errorMessage;

    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        viewModel.clearError();
      });
    }

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
        Tab(text: 'Created'),
        Tab(text: 'Pending'),
        Tab(text: 'Approved'),
        Tab(text: 'Rejected'),
        Tab(text: 'Donating'),
        Tab(text: 'Distributing'),
        Tab(text: 'Finished'),
      ],
      tabViews: [
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.created),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.pending),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.approved),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.rejected),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.donating),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.distributing),
          isLoading: state.isLoading,
          onLoadCampaignDetail: viewModel.loadCampaignDetail,
        ),
        _buildCampaignList(
          campaigns: viewModel.mineByStatus(CampaignStatus.finished),
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
          isOwner: true,
          onLoadCampaignDetail: onLoadCampaignDetail,
          onUpdateCampaign: _showUpdateCampaignDialog,
          onSendCampaignRequest: (campaignId) => ref
              .read(charityCampaignViewModelProvider.notifier)
              .sendCampaignRequest(campaignId),
          onPostAnnouncement: (campaignId, text) {
            return ref
                .read(charityCampaignViewModelProvider.notifier)
                .postAnnouncement(campaignId: campaignId, text: text);
          },
        );
      },
    );
  }
}
