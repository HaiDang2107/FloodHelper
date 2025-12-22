import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/charity_campaign.dart';

class TransactionListView extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isOwner;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Column(
      children: [
        if (isOwner)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Upload bank statement
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Bank Statement'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Download bank statement
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Bank Statement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
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
                  transaction.name,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500),
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