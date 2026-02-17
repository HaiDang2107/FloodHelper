import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/charity_campaign.dart';

class PurchasedSuppliesView extends StatelessWidget {
  final List<PurchasedSupply> supplies;
  final bool isOwner;

  const PurchasedSuppliesView({
    super.key,
    required this.supplies,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final double total =
        supplies.fold(0, (sum, item) => sum + item.totalPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOwner) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Add purchased supply
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Purchased Supply'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 18,
            columns: const [
              DataColumn(
                  label: Text('Product',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Store',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Qty',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)),
                  numeric: true),
              DataColumn(
                  label: Text('Unit Price',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)),
                  numeric: true),
              DataColumn(
                  label: Text('Total',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)),
                  numeric: true),
            ],
            rows: [
              ...supplies.map((supply) => DataRow(
                    cells: [
                      DataCell(Text(supply.productName,
                          style: const TextStyle(color: Colors.black87))),
                      DataCell(Text(supply.buyAt,
                          style: const TextStyle(color: Colors.black87))),
                      DataCell(Text(supply.quantity.toString(),
                          style: const TextStyle(color: Colors.black87))),
                      DataCell(Text(
                          currencyFormatter.format(supply.unitPrice),
                          style: const TextStyle(color: Colors.black87))),
                      DataCell(Text(
                          currencyFormatter.format(supply.totalPrice),
                          style: const TextStyle(color: Colors.black87))),
                    ],
                  )),
              // Total Row
              DataRow(
                cells: [
                  const DataCell(Text('Total',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(Text(
                    currencyFormatter.format(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}