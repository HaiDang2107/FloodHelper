import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/models/charity_campaign.dart';
import '../dialog/bank_statement_upload_dialog.dart';

class TransactionListView extends StatelessWidget {
  final List<Donation> transactions;
  final bool isOwner;
  final CampaignStatus campaignStatus;
  final String campaignId;
  final String? bankStatementFileUrl;
  final Future<CharityCampaign> Function(
    String campaignId, {
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required void Function(double progress) onProgress,
  })?
  onUploadBankStatement;
  final Future<CharityCampaign> Function(String campaignId)? onDeleteBankStatement;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.isOwner,
    required this.campaignStatus,
    required this.campaignId,
    this.bankStatementFileUrl,
    this.onUploadBankStatement,
    this.onDeleteBankStatement,
  });

  bool get _hasBankStatement =>
      bankStatementFileUrl != null && bankStatementFileUrl!.trim().isNotEmpty;

  String _statementLabel() {
    final url = bankStatementFileUrl;
    if (url == null || url.trim().isEmpty) {
      return 'No bank statement uploaded yet.';
    }

    final uri = Uri.tryParse(url);
    final fileName = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : 'Bank statement file';
    return fileName.isEmpty ? 'Bank statement file' : fileName;
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final handler = onUploadBankStatement;
    if (handler == null) {
      return;
    }

    final didUpload = await showDialog<bool>(
      context: context,
      builder: (_) => BankStatementUploadDialog(
        campaignId: campaignId,
        onUpload: handler,
      ),
    );

    if (didUpload == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank statement uploaded successfully.')),
      );
    }
  }

  Future<void> _deleteBankStatement(BuildContext context) async {
    final handler = onDeleteBankStatement;
    if (handler == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete bank statement?'),
        content: const Text(
          'This will remove the current bank statement from the campaign.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await handler(campaignId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank statement deleted successfully.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
    }
  }

  Future<void> _openBankStatementUrl(BuildContext context) async {
    final url = bankStatementFileUrl;
    if (url == null || url.trim().isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid bank statement URL.')),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open bank statement.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    final canUploadBankStatement =
        isOwner &&
        campaignStatus != CampaignStatus.donating &&
        campaignStatus != CampaignStatus.distributing;
    final canDownloadBankStatement =
      !isOwner &&
      campaignStatus != CampaignStatus.donating &&
      campaignStatus != CampaignStatus.distributing;

    return Column(
      children: [
        if (canUploadBankStatement)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUploadBankStatement == null
                  ? null
                  : () => _showUploadDialog(context),
              icon: const Icon(Icons.upload_file),
              label: Text(
                _hasBankStatement ? 'Replace Bank Statement' : 'Upload Bank Statement',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F62FE),
                foregroundColor: Colors.white,
              ),
            ),
          )
        else if (canDownloadBankStatement && _hasBankStatement)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openBankStatementUrl(context),
              icon: const Icon(Icons.download),
              label: const Text('Download Bank Statement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        if (isOwner && _hasBankStatement) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current bank statement',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statementLabel(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDeleteBankStatement == null
                      ? null
                      : () => _deleteBankStatement(context),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete bank statement',
                ),
                IconButton(
                  onPressed: () => _openBankStatementUrl(context),
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open bank statement',
                ),
              ],
            ),
          ),
        ] else if (!isOwner) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _hasBankStatement
                  ? 'Current bank statement: ${_statementLabel()}'
                  : 'No bank statement uploaded yet.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No transactions yet.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.amount > 0;
              return ListTile(
                title: Text(
                  transaction.donorName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormat.yMd().add_jm().format(transaction.date),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: Text(
                  '${isIncome ? '+' : ''}${currencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
