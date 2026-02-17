import 'package:flutter/material.dart';

class DistressSignalView extends StatelessWidget {
  final int trappedCounts;
  final int childrenNumbers;
  final int elderlyNumbers;
  final bool hasFood;
  final bool hasWater;
  final String? other;
  final VoidCallback onEdit;
  final VoidCallback onRevoke;

  const DistressSignalView({
    super.key,
    required this.trappedCounts,
    required this.childrenNumbers,
    required this.elderlyNumbers,
    required this.hasFood,
    required this.hasWater,
    this.other,
    required this.onEdit,
    required this.onRevoke,
  });

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight ? Colors.red[700] : Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.red[900] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red[700], size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active Distress Signal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BROADCASTING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Trapped Counts:',
                trappedCounts.toString(),
                highlight: trappedCounts > 0,
              ),
              _buildInfoRow(
                'Children Numbers:',
                childrenNumbers.toString(),
              ),
              _buildInfoRow(
                'Elderly Numbers:',
                elderlyNumbers.toString(),
              ),
              _buildInfoRow(
                'Has Food:',
                hasFood ? 'Yes' : 'No',
                highlight: !hasFood,
              ),
              _buildInfoRow(
                'Has Water:',
                hasWater ? 'Yes' : 'No',
                highlight: !hasWater,
              ),
              if (other != null && other!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Other Information:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    other!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.blue[700]!),
                  foregroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRevoke,
                icon: const Icon(Icons.cancel),
                label: const Text('Revoke Signal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
