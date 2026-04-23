import 'package:flutter/material.dart';

import '../../../../data/services/charity_campaign_service.dart';
import '../../../../domain/models/bank_option.dart';
import '../../../../domain/models/charity_campaign.dart';
import '../../../core/common/widgets/location_selector.dart';

class CreateCampaignDialog extends StatefulWidget {
  final CharityCampaign? campaignToEdit;

  const CreateCampaignDialog({super.key, this.campaignToEdit});

  bool get isUpdateMode => campaignToEdit != null;

  @override
  State<CreateCampaignDialog> createState() => _CreateCampaignDialogState();
}

class _CreateCampaignDialogState extends State<CreateCampaignDialog> {
  final _charityCampaignService = CharityCampaignService();
  final nameController = TextEditingController();
  final purposeController = TextEditingController();
  final charityObjectController = TextEditingController();
  final accountController = TextEditingController();
  final bankStatementFileUrlController = TextEditingController();
  final destinationDetailController = TextEditingController();
  final startedDonationAtController = TextEditingController();
  final finishedDonationAtController = TextEditingController();
  final startedDistributionAtController = TextEditingController();
  final finishedDistributionAtController = TextEditingController();

  DateTime? _startedDonationAt;
  DateTime? _finishedDonationAt;
  DateTime? _startedDistributionAt;
  DateTime? _finishedDistributionAt;
  List<BankOption> _banks = const [];
  bool _isLoadingBanks = true;
  String? _bankLoadError;
  int? _selectedBankId;
  int? _destinationProvinceCode;
  String? _destinationProvinceName;
  int? _destinationWardCode;
  String? _destinationWardName;

  @override
  void initState() {
    super.initState();
    final campaign = widget.campaignToEdit;
    if (campaign == null) {
      _loadBanks();
      return;
    }

    nameController.text = campaign.name;
    purposeController.text = campaign.purpose;
    charityObjectController.text = campaign.charityObject;
    accountController.text = campaign.bankInfo.accountNumber;
    _selectedBankId = campaign.bankInfo.bankId;
    bankStatementFileUrlController.text = campaign.bankStatementFileUrl ?? '';
    destinationDetailController.text = campaign.destinationDetail ?? '';
    _destinationProvinceCode = campaign.destinationProvinceCode;
    _destinationProvinceName = campaign.destinationProvinceName;
    _destinationWardCode = campaign.destinationWardCode;
    _destinationWardName = campaign.destinationWardName;

    _startedDonationAt = campaign.startedDonationAt;
    _finishedDonationAt = campaign.finishedDonationAt;
    _startedDistributionAt = campaign.startedDistributionAt;
    _finishedDistributionAt = campaign.finishedDistributionAt;

    startedDonationAtController.text = _formatDate(_startedDonationAt);
    finishedDonationAtController.text = _formatDate(_finishedDonationAt);
    startedDistributionAtController.text = _formatDate(_startedDistributionAt);
    finishedDistributionAtController.text = _formatDate(_finishedDistributionAt);

    _loadBanks();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await _charityCampaignService.getBanks();
      if (!mounted) {
        return;
      }

      setState(() {
        _banks = banks;
        _isLoadingBanks = false;
        _bankLoadError = null;
        if (_selectedBankId == null && widget.campaignToEdit != null) {
          _selectedBankId = _resolveBankIdFromCampaign(
            widget.campaignToEdit!.bankInfo,
          );
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingBanks = false;
        _bankLoadError = error.toString();
      });
    }
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

  int? _resolveBankIdFromCampaign(BankInfo bankInfo) {
    for (final bank in _banks) {
      if (bankInfo.bankShortName != null &&
          bank.shortName == bankInfo.bankShortName) {
        return bank.id;
      }
      if (bankInfo.bankName == bank.shortName) {
        return bank.id;
      }
    }

    return null;
  }

  BankOption? _selectedBank() {
    if (_selectedBankId == null) {
      return null;
    }

    for (final bank in _banks) {
      if (bank.id == _selectedBankId) {
        return bank;
      }
    }

    return null;
  }

  String? _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        purposeController.text.trim().isEmpty ||
        charityObjectController.text.trim().isEmpty ||
        accountController.text.trim().isEmpty ||
        _selectedBank() == null ||
        _startedDonationAt == null ||
        _finishedDonationAt == null ||
        _startedDistributionAt == null ||
        _finishedDistributionAt == null) {
      return 'Please fill all required fields before submitting.';
    }

    final now = DateTime.now();
    final startedDonationAt = _startedDonationAt!;
    final finishedDonationAt = _finishedDonationAt!;
    final startedDistributionAt = _startedDistributionAt!;
    final finishedDistributionAt = _finishedDistributionAt!;

    if (!startedDonationAt.isAfter(now)) {
      return 'Start Donation must be after current time.';
    }
    if (!startedDonationAt.isBefore(finishedDonationAt)) {
      return 'Timeline is invalid: Start Donation must be before Finish Donation.';
    }
    if (!finishedDonationAt.isBefore(startedDistributionAt)) {
      return 'Timeline is invalid: Finish Donation must be before Start Distribution.';
    }
    if (!startedDistributionAt.isBefore(finishedDistributionAt)) {
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
    final startedDonationAt = _startedDonationAt!;
    final finishedDistributionAt = _finishedDistributionAt!;
    final selectedBank = _selectedBank();

    final campaign = CharityCampaign(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      organizedBy: existing?.organizedBy,
      checkedBy: existing?.checkedBy,
      name: nameController.text.trim(),
      benefactorName: existing?.benefactorName ?? 'Me',
      purpose: purposeController.text.trim(),
      charityObject: charityObjectController.text.trim(),
      status: existing?.status ?? CampaignStatus.created,
        destinationProvinceCode: _destinationProvinceCode,
        destinationProvinceName: _destinationProvinceName,
        destinationWardCode: _destinationWardCode,
        destinationWardName: _destinationWardName,
        destinationDetail: destinationDetailController.text.trim().isEmpty
          ? null
          : destinationDetailController.text.trim(),
      bankInfo: BankInfo(
        accountNumber: accountController.text.trim(),
        bankName: selectedBank?.shortName ??
            existing?.bankInfo.bankShortName ??
            existing?.bankInfo.bankName ??
            'Unknown',
        bankId: selectedBank?.id ?? existing?.bankInfo.bankId,
        bankCode: existing?.bankInfo.bankCode,
        bankShortName: selectedBank?.shortName ?? existing?.bankInfo.bankShortName,
        accountHolder: existing?.bankInfo.accountHolder,
      ),
      bankStatementFileUrl: bankStatementFileUrlController.text.trim().isEmpty
          ? null
          : bankStatementFileUrlController.text.trim(),
      requestedAt: existing?.requestedAt,
      respondedAt: existing?.respondedAt,
      noteForResponse: existing?.noteForResponse,
      startedDonationAt: _startedDonationAt,
      finishedDonationAt: _finishedDonationAt,
      startedDistributionAt: _startedDistributionAt,
      finishedDistributionAt: _finishedDistributionAt,
      reliefLocation: _buildReliefLocation(),
      period: DateRange(
        startDate: startedDonationAt,
        endDate: finishedDistributionAt,
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
    bankStatementFileUrlController.dispose();
    destinationDetailController.dispose();
    startedDonationAtController.dispose();
    finishedDonationAtController.dispose();
    startedDistributionAtController.dispose();
    finishedDistributionAtController.dispose();
    super.dispose();
  }

  String _buildReliefLocation() {
    final parts = <String>[];
    final detail = destinationDetailController.text.trim();
    if (detail.isNotEmpty) {
      parts.add(detail);
    }
    if (_destinationWardName != null && _destinationWardName!.isNotEmpty) {
      parts.add(_destinationWardName!);
    }
    if (_destinationProvinceName != null && _destinationProvinceName!.isNotEmpty) {
      parts.add(_destinationProvinceName!);
    }
    return parts.join(', ');
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
              controller: destinationDetailController,
              decoration: const InputDecoration(
                labelText: 'Location Detail (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            LocationSelectorField(
              provinceLabel: 'Destination Province *',
              wardLabel: 'Destination Ward *',
              initialProvinceCode: _destinationProvinceCode,
              initialWardCode: _destinationWardCode,
              onChanged: (selection) {
                setState(() {
                  _destinationProvinceCode = selection.province?.code;
                  _destinationProvinceName = selection.province?.name;
                  _destinationWardCode = selection.ward?.code;
                  _destinationWardName = selection.ward?.name;
                });
              },
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
            if (_isLoadingBanks)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(minHeight: 2),
              )
            else ...[
              DropdownButtonFormField<int>(
                value: _selectedBankId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Bank',
                  border: OutlineInputBorder(),
                ),
                items: _banks
                    .map(
                      (bank) => DropdownMenuItem<int>(
                        value: bank.id,
                        child: Text(bank.displayLabel),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _selectedBankId = value;
                  });
                },
              ),
              if (_bankLoadError != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Bank list could not be loaded.',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
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
                    controller: startedDonationAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: startedDonationAtController,
                      initialDate: _startedDonationAt,
                      onSelected: (date) => _startedDonationAt = date,
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
                    controller: finishedDonationAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: finishedDonationAtController,
                      initialDate: _finishedDonationAt,
                      onSelected: (date) => _finishedDonationAt = date,
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
                    controller: startedDistributionAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: startedDistributionAtController,
                      initialDate: _startedDistributionAt,
                      onSelected: (date) => _startedDistributionAt = date,
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
                    controller: finishedDistributionAtController,
                    readOnly: true,
                    onTap: () => _pickDate(
                      controller: finishedDistributionAtController,
                      initialDate: _finishedDistributionAt,
                      onSelected: (date) => _finishedDistributionAt = date,
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
