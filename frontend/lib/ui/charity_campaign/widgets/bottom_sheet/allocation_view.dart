import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/charity_campaign.dart';
import '../../view_models/allocation_view_model.dart';

class PurchasedSuppliesView extends ConsumerStatefulWidget {
  final String campaignId;
  final bool isOwner;
  final List<PurchasedSupply> supplies;
  final List<FinancialSupportAllocation> financialSupports;
  final void Function(
    List<PurchasedSupply> supplies,
    List<FinancialSupportAllocation> financialSupports,
  )?
  onAllocationSaved;
  final VoidCallback? onClose;

  const PurchasedSuppliesView({
    super.key,
    required this.campaignId,
    required this.isOwner,
    required this.supplies,
    required this.financialSupports,
    this.onAllocationSaved,
    this.onClose,
  });

  @override
  ConsumerState<PurchasedSuppliesView> createState() => _PurchasedSuppliesViewState();
}

class _PurchasedSuppliesViewState extends ConsumerState<PurchasedSuppliesView> {
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  late final AllocationViewModelSeed _seed;
  bool _isLoadingSupplies = false;
  bool _isLoadingFinancialSupports = false;
  bool _hasLoadedSupplies = false;
  bool _hasLoadedFinancialSupports = false;

  InputDecoration _inputDecoration() {
    final isReadonlyViewer = !widget.isOwner;

    if (isReadonlyViewer) {
      return const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      );
    }

    return InputDecoration(
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      border: const OutlineInputBorder(),
    );
  }

  @override
  void initState() {
    super.initState();
    _seed = AllocationViewModelSeed(
      campaignId: widget.campaignId,
      supplies: widget.supplies,
      financialSupports: widget.financialSupports,
    );
    _hasLoadedSupplies = widget.supplies.isNotEmpty;
    _hasLoadedFinancialSupports = widget.financialSupports.isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final viewModel = ref.read(allocationViewModelProvider(_seed));
      _ensureSuppliesLoaded(viewModel);
    });
  }

  Future<void> _ensureSuppliesLoaded(AllocationViewModel viewModel) async {
    if (_hasLoadedSupplies || _isLoadingSupplies) {
      return;
    }

    setState(() => _isLoadingSupplies = true);
    try {
      await viewModel.loadSupplies();
      if (!mounted) {
        return;
      }
      _hasLoadedSupplies = true;
      widget.onAllocationSaved?.call(
        viewModel.currentSupplies,
        viewModel.currentFinancialSupports,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Cannot load supplies: $error')),
        );
    } finally {
      if (mounted) {
        setState(() => _isLoadingSupplies = false);
      }
    }
  }

  Future<void> _ensureFinancialSupportsLoaded(AllocationViewModel viewModel) async {
    if (_hasLoadedFinancialSupports || _isLoadingFinancialSupports) {
      return;
    }

    setState(() => _isLoadingFinancialSupports = true);
    try {
      await viewModel.loadFinancialSupports();
      if (!mounted) {
        return;
      }
      _hasLoadedFinancialSupports = true;
      widget.onAllocationSaved?.call(
        viewModel.currentSupplies,
        viewModel.currentFinancialSupports,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Cannot load financial supports: $error')),
        );
    } finally {
      if (mounted) {
        setState(() => _isLoadingFinancialSupports = false);
      }
    }
  }

  Future<void> _handleClose(AllocationViewModel viewModel) async {
    if (!viewModel.hasUnsavedChanges) {
      widget.onClose?.call();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text('You have unsaved allocation changes. Discard and go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.onClose?.call();
    }
  }

  Future<void> _saveActiveTab(AllocationViewModel viewModel) async {
    if (!widget.isOwner || viewModel.isSaving) {
      return;
    }

    try {
      await viewModel.saveActiveTab();
      widget.onAllocationSaved?.call(
        viewModel.currentSupplies,
        viewModel.currentFinancialSupports,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Allocation saved successfully')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Save failed: $error')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(allocationViewModelProvider(_seed));

    final suppliesTotal = viewModel.suppliesTotal;
    final supportsTotal = viewModel.supportsTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _handleClose(viewModel),
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.black87,
              ),
            ),
            const Spacer(),
            if (widget.isOwner)
              FilledButton.icon(
                onPressed: viewModel.isSaving ? null : () => _saveActiveTab(viewModel),
                icon: viewModel.isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SegmentedButton<AllocationTab>(
          showSelectedIcon: false,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF0F62FE);
                }
                return Colors.white;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.black;
              },
            ),
          ),
          segments: const [
            ButtonSegment<AllocationTab>(
              value: AllocationTab.supplies,
              label: Text('Supply'),
              icon: Icon(Icons.inventory_2_outlined),
            ),
            ButtonSegment<AllocationTab>(
              value: AllocationTab.financial,
              label: Text('Financial Support'),
              icon: Icon(Icons.volunteer_activism_outlined),
            ),
          ],
          selected: <AllocationTab>{viewModel.activeTab},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }
            final tab = selection.first;
            viewModel.setActiveTab(tab);
            if (tab == AllocationTab.financial) {
              _ensureFinancialSupportsLoaded(viewModel);
            }
          },
        ),
        const SizedBox(height: 16),
        if (viewModel.activeTab == AllocationTab.supplies) ...[
          KeyedSubtree(
            key: const ValueKey('allocation-supply-tab'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isOwner)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: viewModel.addSupplyRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add row'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (_isLoadingSupplies)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                _buildSuppliesTable(viewModel),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_currency.format(suppliesTotal)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ],
            ),
          ),
        ] else ...[
          KeyedSubtree(
            key: const ValueKey('allocation-financial-tab'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isOwner)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: viewModel.addSupportRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add row'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (_isLoadingFinancialSupports)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                _buildFinancialTable(viewModel),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_currency.format(supportsTotal)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuppliesTable(AllocationViewModel viewModel) {
    final columns = <DataColumn>[
      const DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Product'))),
      const DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Qty'))),
      const DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Unit Price'))),
      const DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Total'))),
      if (widget.isOwner)
        const DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Actions'))),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        key: const ValueKey('allocation-supply-table'),
        horizontalMargin: 12,
        columnSpacing: 16,
        dataRowMinHeight: 62,
        dataRowMaxHeight: 72,
        headingTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: const TextStyle(
          color: Colors.black,
        ),
        columns: columns,
        rows: viewModel.supplies
            .asMap()
            .entries
            .map((entry) => _buildSupplyDataRow(viewModel, entry.key, entry.value))
            .toList(growable: false),
      ),
    );
  }

  DataRow _buildSupplyDataRow(
    AllocationViewModel viewModel,
    int index,
    EditableSupply row,
  ) {
    final model = row.toModel();
    final total = model?.totalPrice ?? 0;
    final editable = widget.isOwner && row.isEditing;

    return DataRow(
      key: ValueKey('supply-row-${row.supplyId ?? 'new'}-$index'),
      cells: <DataCell>[
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 180,
              child: TextFormField(
                key: ValueKey('supply-product-${row.supplyId ?? 'new'}-$index'),
                initialValue: row.productName,
                readOnly: !editable,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration(),
                onChanged: (value) => viewModel.updateSupplyProductName(index, value),
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 80,
              child: TextFormField(
                key: ValueKey('supply-qty-${row.supplyId ?? 'new'}-$index'),
                initialValue: row.quantity,
                readOnly: !editable,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
                onChanged: (value) => viewModel.updateSupplyQuantity(index, value),
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 120,
              child: TextFormField(
                key: ValueKey('supply-price-${row.supplyId ?? 'new'}-$index'),
                initialValue: row.unitPrice,
                readOnly: !editable,
                style: const TextStyle(color: Colors.black),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(),
                onChanged: (value) => viewModel.updateSupplyUnitPrice(index, value),
              ),
            ),
          ),
        ),
        DataCell(Text(_currency.format(total))),
        if (widget.isOwner)
          DataCell(
            Row(
              children: [
                IconButton(
                  tooltip: row.isEditing ? 'Done' : 'Edit',
                  onPressed: () => viewModel.toggleSupplyEdit(index),
                  icon: Icon(row.isEditing ? Icons.check : Icons.edit),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => viewModel.removeSupplyAt(index),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialTable(AllocationViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        key: const ValueKey('allocation-financial-table'),
        horizontalMargin: 12,
        columnSpacing: 16,
        dataRowMinHeight: 62,
        dataRowMaxHeight: 72,
        headingTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: const TextStyle(
          color: Colors.black,
        ),
        columns: const [
          DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Household'))),
          DataColumn(label: Align(alignment: Alignment.centerLeft, child: Text('Amount'))),
        ],
        rows: viewModel.supports
            .asMap()
            .entries
            .map((entry) => _buildSupportDataRow(viewModel, entry.key, entry.value))
            .toList(growable: false),
      ),
    );
  }

  DataRow _buildSupportDataRow(
    AllocationViewModel viewModel,
    int index,
    EditableSupport row,
  ) {
    const amountInputWidth = 140.0;
    final editable = widget.isOwner && row.isEditing;

    return DataRow(
      key: ValueKey('financial-row-${row.financialSupportId ?? 'new'}-$index'),
      cells: [
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 220,
              child: TextFormField(
                key: ValueKey('financial-household-${row.financialSupportId ?? 'new'}-$index'),
                initialValue: row.householdName,
                readOnly: !editable,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration(),
                onChanged: (value) => viewModel.updateSupportHouseholdName(index, value),
              ),
            ),
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: amountInputWidth,
                  child: TextFormField(
                    key: ValueKey('financial-amount-${row.financialSupportId ?? 'new'}-$index'),
                    initialValue: row.amount,
                    readOnly: !editable,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration(),
                    onChanged: (value) => viewModel.updateSupportAmount(index, value),
                  ),
                ),
                if (widget.isOwner) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: row.isEditing ? 'Done' : 'Edit',
                    onPressed: () => viewModel.toggleSupportEdit(index),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    icon: Icon(row.isEditing ? Icons.check : Icons.edit),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => viewModel.removeSupportAt(index),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
