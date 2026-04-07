import 'package:flutter/material.dart';
import '../../../../../../domain/models/charity_campaign.dart';

class CharityActionButtons extends StatelessWidget {
  final CampaignStatus status;
  final bool canDonate;
  final VoidCallback? onDonate;
  final VoidCallback? onTransaction;
  final VoidCallback? onPurchasedSupplies;

  const CharityActionButtons({
    super.key,
    required this.status,
    this.canDonate = true,
    this.onDonate,
    this.onTransaction,
    this.onPurchasedSupplies,
  });

  @override
  Widget build(BuildContext context) {
    if (status == CampaignStatus.donating) {
      if (!canDonate) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTransaction,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.grey),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Transaction'),
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onDonate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Donate'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: onTransaction,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Transaction'),
            ),
          ),
        ],
      );
    } else if (status == CampaignStatus.distributing ||
        status == CampaignStatus.finished) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPurchasedSupplies,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Allocation'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: onTransaction,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Transaction'),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
