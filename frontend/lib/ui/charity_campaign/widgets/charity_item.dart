import 'package:flutter/material.dart';
import '../../core/common/widgets/bottom_sheet.dart';
import '../../../domain/models/charity_campaign.dart';
import 'bottom_sheet/purchased_supplies_view.dart';
import 'bottom_sheet/transaction_list_view.dart';
import 'bottom_sheet/detail_view/detail_view.dart';

// Defines the views inside the bottom sheet
enum _SheetView { details, supplies, transactions }

class CharityItem extends StatelessWidget {
  final CharityCampaign campaign;
  final bool isOwner;
  final Future<CharityCampaign> Function(String campaignId) ? onLoadCampaignDetail;
  final Future<void> Function(String campaignId, String text) ? onPostAnnouncement;

  const CharityItem({
    super.key,
    required this.campaign,
    this.isOwner = false,
    this.onLoadCampaignDetail,
    this.onPostAnnouncement,
  });

  Future<void> _showDetailsBottomSheet(BuildContext context) async {
    var detailCampaign = campaign;
    if (onLoadCampaignDetail != null) {
      try {
        detailCampaign = await onLoadCampaignDetail!(campaign.id);
      } catch (_) {
        detailCampaign = campaign;
      }
    }

    if (!context.mounted) {
      return;
    }

    var currentView = _SheetView.details;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          Widget buildBackButton(VoidCallback onPressed) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            );
          }

          Widget content;

          switch (currentView) {
            // currentView quyết định nội dung nào sẽ được hiển thị
            case _SheetView.supplies:
              content = Column(
                key: const ValueKey('supplies'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(
                    // thay đổi trạng thái currentView
                    () => setSheetState(() => currentView = _SheetView.details),
                  ),
                  PurchasedSuppliesView(
                    supplies: detailCampaign.purchasedSupplies,
                    isOwner: isOwner,
                  ),
                ],
              );
              break;
            case _SheetView.transactions:
              content = Column(
                key: const ValueKey('transactions'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(
                    () => setSheetState(() => currentView = _SheetView.details),
                  ),
                  TransactionListView(
                    transactions: detailCampaign.donations,
                    isOwner: isOwner,
                    campaignStatus: detailCampaign.status,
                  ),
                ],
              );
              break;
            case _SheetView.details:
              content = DetailView(
                key: const ValueKey('details'),
                campaign: detailCampaign,
                isOwner: isOwner,
                onPurchasedSupplies: () =>
                    setSheetState(() => currentView = _SheetView.supplies),
                onTransaction: () =>
                    setSheetState(() => currentView = _SheetView.transactions),
                onPostAnnouncement: onPostAnnouncement == null
                    ? null
                    : (text) => onPostAnnouncement!(detailCampaign.id, text),
              );
              break;
          }

          return CustomBottomSheet(
            title: campaign.name,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailsBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    campaign.benefactorName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
