import 'package:flutter/material.dart';
import '../../../../domain/models/charity_campaign.dart';

class CreateCampaignDialog extends StatefulWidget {
  const CreateCampaignDialog({super.key});

  @override
  State<CreateCampaignDialog> createState() => _CreateCampaignDialogState();
}

class _CreateCampaignDialogState extends State<CreateCampaignDialog> {
  final nameController = TextEditingController();
  final benefactorController = TextEditingController();
  final accountController = TextEditingController();
  final bankController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    benefactorController.dispose();
    accountController.dispose();
    bankController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Campaign',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Campaign Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: benefactorController,
              decoration: const InputDecoration(
                labelText: 'Benefactor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accountController,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bankController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Relief Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // TODO: Find location on map
                  },
                  icon: const Icon(Icons.map, color: Color(0xFF0F62FE)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endDateController,
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  final newCampaign = CharityCampaign(
                    id: now.microsecondsSinceEpoch.toString(),
                    name: nameController.text.isEmpty
                        ? 'New Campaign'
                        : nameController.text,
                    benefactorName: benefactorController.text.isEmpty
                        ? 'Me'
                        : benefactorController.text,
                    status: CampaignStatus.pending,
                    bankInfo: BankInfo(
                      accountNumber: accountController.text,
                      bankName: bankController.text,
                    ),
                    reliefLocation: locationController.text,
                    period: DateRange(
                      startDate: now,
                      endDate: now.add(const Duration(days: 30)),
                    ),
                    announcements: [],
                  );
                  Navigator.pop(context, newCampaign);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send creation request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
