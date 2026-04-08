import 'package:flutter/material.dart';

import '../../../../domain/models/charity_campaign.dart';

class CreateCampaignDialog extends StatefulWidget {
  final CharityCampaign? campaignToEdit;

  const CreateCampaignDialog({super.key, this.campaignToEdit});

  bool get isUpdateMode => campaignToEdit != null;

  @override
  State<CreateCampaignDialog> createState() => _CreateCampaignDialogState();
}

class _CreateCampaignDialogState extends State<CreateCampaignDialog> {
  final nameController = TextEditingController();
  final purposeController = TextEditingController();
  final charityObjectController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    final campaign = widget.campaignToEdit;
    if (campaign == null) {
      return;
    }

    nameController.text = campaign.name;
    purposeController.text = campaign.purpose;
    charityObjectController.text = campaign.charityObject;
    accountController.text = campaign.bankInfo.accountNumber;
    bankController.text = campaign.bankInfo.bankName;
    bankStatementFileUrlController.text = campaign.bankStatementFileUrl ?? '';
    locationController.text = campaign.reliefLocation;

    _startDonationAt = campaign.startDonationAt;
    _finishDonationAt = campaign.finishDonationAt;
    _startDistributionAt = campaign.startDistributionAt;
    _finishDistributionAt = campaign.finishDistributionAt;

    startDonationAtController.text = _formatDate(_startDonationAt);
    finishDonationAtController.text = _formatDate(_finishDonationAt);
    startDistributionAtController.text = _formatDate(_startDistributionAt);
    finishDistributionAtController.text = _formatDate(_finishDistributionAt);
  }

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
    controller.text = _formatDate(picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String? _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        purposeController.text.trim().isEmpty ||
        charityObjectController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        accountController.text.trim().isEmpty ||
        bankController.text.trim().isEmpty ||
        _startDonationAt == null ||
        _finishDonationAt == null ||
        _startDistributionAt == null ||
        _finishDistributionAt == null) {
      return 'Please fill all required fields before submitting.';
    }

    final now = DateTime.now();
    final startDonationAt = _startDonationAt!;
    final finishDonationAt = _finishDonationAt!;
    final startDistributionAt = _startDistributionAt!;
    final finishDistributionAt = _finishDistributionAt!;

    if (!startDonationAt.isAfter(now)) {
      return 'Start Donation must be after current time.';
    }
    if (!startDonationAt.isBefore(finishDonationAt)) {
      return 'Timeline is invalid: Start Donation must be before Finish Donation.';
    }
    if (!finishDonationAt.isBefore(startDistributionAt)) {
      return 'Timeline is invalid: Finish Donation must be before Start Distribution.';
    }
    if (!startDistributionAt.isBefore(finishDistributionAt)) {
      return 'Timeline is invalid: Start Distribution must be before Finish Distribution.';
    }

    return null;
  }

  Future<void> _submit() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Invalid campaign data'),
          content: Text(validationError),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final existing = widget.campaignToEdit;
    final startDonationAt = _startDonationAt!;
    final finishDistributionAt = _finishDistributionAt!;

    final campaign = CharityCampaign(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      organizedBy: existing?.organizedBy,
      checkedBy: existing?.checkedBy,
      name: nameController.text.trim(),
      benefactorName: existing?.benefactorName ?? 'Me',
      purpose: purposeController.text.trim(),
      charityObject: charityObjectController.text.trim(),
      status: existing?.status ?? CampaignStatus.created,
      bankInfo: BankInfo(
        accountNumber: accountController.text.trim(),
        bankName: bankController.text.trim(),
        accountHolder: existing?.bankInfo.accountHolder,
      ),
      bankStatementFileUrl: bankStatementFileUrlController.text.trim().isEmpty
          ? null
          : bankStatementFileUrlController.text.trim(),
      requestedAt: existing?.requestedAt,
      respondedAt: existing?.respondedAt,
      noteByAuthority: existing?.noteByAuthority,
      startDonationAt: _startDonationAt,
      finishDonationAt: _finishDonationAt,
      startDistributionAt: _startDistributionAt,
      finishDistributionAt: _finishDistributionAt,
      reliefLocation: locationController.text.trim(),
      period: DateRange(
        startDate: startDonationAt,
        endDate: finishDistributionAt,
      ),
      announcements: existing?.announcements ?? const [],
      purchasedSupplies: existing?.purchasedSupplies ?? const [],
      donations: existing?.donations ?? const [],
    );

    if (!mounted) {
      return;
    }
    Navigator.pop(context, campaign);
  }

  @override
  void dispose() {
    nameController.dispose();
    purposeController.dispose();
    charityObjectController.dispose();
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
    final isUpdateMode = widget.isUpdateMode;
    final title = isUpdateMode ? 'Update Campaign' : 'Create New Campaign';
    final actionLabel = isUpdateMode ? 'Update Campaign' : 'Create Campaign';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Campaign Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Relief Location *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: purposeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Purpose *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: charityObjectController,
              decoration: const InputDecoration(
                labelText: 'Charity Object *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bankController,
              decoration: const InputDecoration(
                labelText: 'Bank Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accountController,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number *',
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
                      labelText: 'Start Donation At *',
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
                      labelText: 'Finish Donation At *',
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
                      labelText: 'Start Distribution At *',
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
                      labelText: 'Finish Distribution At *',
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
