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
  final purposeController = TextEditingController();
  final charityObjectController = TextEditingController();
  final organizedByController = TextEditingController();
  final checkedByController = TextEditingController();
  final accountController = TextEditingController();
  final bankController = TextEditingController();
  final bankStatementFileUrlController = TextEditingController();
  final locationController = TextEditingController();
  final startDonationAtController = TextEditingController();
  final finishDonationAtController = TextEditingController();
  final startDistributionAtController = TextEditingController();
  final finishDistributionAtController = TextEditingController();

  DateTime? _startDonationAt;
  DateTime? _finishDonationAt;
  DateTime? _startDistributionAt;
  DateTime? _finishDistributionAt;
  CampaignStatus _selectedStatus = CampaignStatus.pending;

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5);
    final safeInitialDate = (() {
      final selectedDate = initialDate ?? now;
      if (selectedDate.isBefore(firstDate)) {
        return firstDate;
      }
      if (selectedDate.isAfter(lastDate)) {
        return lastDate;
      }
      return selectedDate;
    })();
    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null) {
      return;
    }

    onSelected(picked);
    controller.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  @override
  void dispose() {
    nameController.dispose();
    benefactorController.dispose();
    purposeController.dispose();
    charityObjectController.dispose();
    organizedByController.dispose();
    checkedByController.dispose();
    accountController.dispose();
    bankController.dispose();
    bankStatementFileUrlController.dispose();
    locationController.dispose();
    startDonationAtController.dispose();
    finishDonationAtController.dispose();
    startDistributionAtController.dispose();
    finishDistributionAtController.dispose();
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
              controller: organizedByController,
              decoration: const InputDecoration(
                labelText: 'Organized By (User ID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: checkedByController,
              decoration: const InputDecoration(
                labelText: 'Checked By (User ID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: purposeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Purpose',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: charityObjectController,
              decoration: const InputDecoration(
                labelText: 'Charity Object',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CampaignStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
              items: CampaignStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedStatus = value;
                });
              },
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
            TextField(
              controller: bankStatementFileUrlController,
              decoration: const InputDecoration(
                labelText: 'Bank Statement File URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Relief Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDonationAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: startDonationAtController,
                      initialDate: _startDonationAt,
                      onSelected: (date) => _startDonationAt = date,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Start Donation At',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: finishDonationAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: finishDonationAtController,
                      initialDate: _finishDonationAt,
                      onSelected: (date) => _finishDonationAt = date,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Finish Donation At',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startDistributionAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: startDistributionAtController,
                      initialDate: _startDistributionAt,
                      onSelected: (date) => _startDistributionAt = date,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Start Distribution At',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: finishDistributionAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: finishDistributionAtController,
                      initialDate: _finishDistributionAt,
                      onSelected: (date) => _finishDistributionAt = date,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Finish Distribution At',
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
                  final startDonationAt = _startDonationAt ?? now;
                  final finishDistributionAt =
                      _finishDistributionAt ??
                      now.add(const Duration(days: 30));

                  final newCampaign = CharityCampaign(
                    id: now.microsecondsSinceEpoch.toString(),
                    organizedBy: organizedByController.text.trim().isEmpty
                        ? null
                        : organizedByController.text.trim(),
                    checkedBy: checkedByController.text.trim().isEmpty
                        ? null
                        : checkedByController.text.trim(),
                    name: nameController.text.isEmpty
                        ? 'New Campaign'
                        : nameController.text,
                    benefactorName: benefactorController.text.isEmpty
                        ? 'Me'
                        : benefactorController.text,
                    purpose: purposeController.text,
                    charityObject: charityObjectController.text,
                    status: _selectedStatus,
                    bankInfo: BankInfo(
                      accountNumber: accountController.text,
                      bankName: bankController.text,
                    ),
                    bankStatementFileUrl:
                        bankStatementFileUrlController.text.trim().isEmpty
                        ? null
                        : bankStatementFileUrlController.text.trim(),
                    startDonationAt: _startDonationAt,
                    finishDonationAt: _finishDonationAt,
                    startDistributionAt: _startDistributionAt,
                    finishDistributionAt: _finishDistributionAt,
                    reliefLocation: locationController.text,
                    period: DateRange(
                      startDate: startDonationAt,
                      endDate: finishDistributionAt,
                    ),
                    announcements: [],
                  );
                  Navigator.pop(context, newCampaign);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Charity Campaign'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
