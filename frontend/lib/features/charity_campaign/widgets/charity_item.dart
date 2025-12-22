import 'package:flutter/material.dart';
import '../../../common/widgets/bottom_sheet.dart';
import '../models/charity_campaign.dart';
import 'bottom_sheet/purchased_supplies_view.dart';
import 'bottom_sheet/transaction_list_view.dart';
import 'bottom_sheet/detail_view/detail_view.dart';

// Defines the views inside the bottom sheet
enum _SheetView { details, supplies, transactions }

class CharityItem extends StatelessWidget {
  final CharityCampaign campaign;
  final bool isOwner;

  const CharityItem({super.key, required this.campaign, this.isOwner = false});

  void _showDetailsBottomSheet(BuildContext context) {
    var _currentView = _SheetView.details;

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

          switch (_currentView) {
            case _SheetView.supplies:
              content = Column(
                key: const ValueKey('supplies'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(
                    () =>
                        setSheetState(() => _currentView = _SheetView.details),
                  ),
                  PurchasedSuppliesView(
                    supplies: campaign.purchasedSupplies,
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
                    () =>
                        setSheetState(() => _currentView = _SheetView.details),
                  ),
                  TransactionListView(
                    transactions: campaign.transactions,
                    isOwner: isOwner,
                  ),
                ],
              );
              break;
            case _SheetView.details:
              content = DetailView(
                key: const ValueKey('details'),
                campaign: campaign,
                isOwner: isOwner,
                onPurchasedSupplies: () =>
                    setSheetState(() => _currentView = _SheetView.supplies),
                onTransaction: () =>
                    setSheetState(() => _currentView = _SheetView.transactions),
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
