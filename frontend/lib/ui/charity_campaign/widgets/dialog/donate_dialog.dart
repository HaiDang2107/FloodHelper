import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/charity_campaign_view_model.dart';

class DonateDialog extends ConsumerStatefulWidget {
  final String campaignId;

  const DonateDialog({super.key, required this.campaignId});

  @override
  ConsumerState<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends ConsumerState<DonateDialog> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _qrLink;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateQr() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = BigInt.tryParse(rawAmount);

    if (amount == null || amount <= BigInt.zero) {
      setState(() {
        _errorMessage = 'Please enter a valid amount (VND).';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final qrLink = await ref
          .read(charityCampaignViewModelProvider.notifier)
          .createDonateQr(campaignId: widget.campaignId, amount: amount);

      if (!mounted) {
        return;
      }

      setState(() {
        _qrLink = qrLink;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Donate',
        style: TextStyle(
          // color: Color(0xFF0F62FE),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter donation amount (VND) and create VietQR.',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (VND)',
              hintText: 'e.g. 50000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateQr,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create QR Code'),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          if (_qrLink != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _qrLink!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 220,
                        height: 220,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text(
                          'Unable to preview QR image\nUse qrLink directly.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _qrLink!,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test callback will be implemented later.'),
                        ),
                      );
                    },
                    child: const Text('Call API Test Callback'),
                  ),
                ),
              ],
            ),
          if (_qrLink == null)
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.qr_code, size: 100)),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Text(
              'Important: To ensure your transaction is recorded correctly, please use the pre-filled message when transferring. Otherwise, it may not be listed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepOrange, fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
