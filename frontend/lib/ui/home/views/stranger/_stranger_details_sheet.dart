import 'package:flutter/material.dart';

class StrangerDetailsSheet extends StatelessWidget {
  final String userId;
  final String fullName;
  final DateTime? dateOfBirth;
  final List<String> roles;
  final bool isSosState;
  final int? trappedCounts;
  final int? childrenNumbers;
  final int? elderlyNumbers;
  final bool? hasFood;
  final bool? hasWater;
  final String? other;

  const StrangerDetailsSheet({
    super.key,
    required this.userId,
    required this.fullName,
    this.dateOfBirth,
    required this.roles,
    this.isSosState = false,
    this.trappedCounts,
    this.childrenNumbers,
    this.elderlyNumbers,
    this.hasFood,
    this.hasWater,
    this.other,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Section
          const Text(
            'User Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('User ID:', userId),
          _buildInfoRow('Full Name:', fullName),
          _buildInfoRow('Date of Birth:', _formatDate(dateOfBirth)),
          _buildInfoRow(
            'Role:',
            roles.isEmpty ? 'Normal User' : roles.join(', '),
          ),
          const SizedBox(height: 24),

          // Make Friend Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement make friend functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Make Friend feature coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Make Friend'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F62FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // SOS Conditions Section (only if isSosState is true)
          if (isSosState) ...[
            const SizedBox(height: 32),
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
                      Text(
                        'Conditions and Surroundings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSosInfoRow(
                    'Trapped Counts:',
                    trappedCounts?.toString() ?? 'Unknown',
                    highlight: (trappedCounts ?? 0) > 0,
                  ),
                  _buildSosInfoRow(
                    'Children Numbers:',
                    childrenNumbers?.toString() ?? 'Unknown',
                  ),
                  _buildSosInfoRow(
                    'Elderly Numbers:',
                    elderlyNumbers?.toString() ?? 'Unknown',
                  ),
                  _buildSosInfoRow(
                    'Has Food:',
                    hasFood == null
                        ? 'Unknown'
                        : hasFood!
                            ? 'Yes'
                            : 'No',
                    highlight: hasFood == false,
                  ),
                  _buildSosInfoRow(
                    'Has Water:',
                    hasWater == null
                        ? 'Unknown'
                        : hasWater!
                            ? 'Yes'
                            : 'No',
                    highlight: hasWater == false,
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
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
