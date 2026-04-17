import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/charity_campaign_repository.dart';
import '../../../domain/models/charity_campaign.dart';

enum AllocationTab { supplies, financial }

class AllocationViewModelSeed {
  final String campaignId;
  final List<PurchasedSupply> supplies;
  final List<FinancialSupportAllocation> financialSupports;

  const AllocationViewModelSeed({
    required this.campaignId,
    required this.supplies,
    required this.financialSupports,
  });
}

final allocationViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<AllocationViewModel, AllocationViewModelSeed>((ref, seed) {
      return AllocationViewModel(
        repository: ref.read(charityCampaignRepositoryProvider),
        campaignId: seed.campaignId,
        supplies: seed.supplies,
        financialSupports: seed.financialSupports,
      );
    });

class EditableSupply {
  String? supplyId;
  String productName;
  String quantity;
  String unitPrice;
  bool isEditing;

  EditableSupply({
    required this.supplyId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.isEditing,
  });

  factory EditableSupply.fromModel(PurchasedSupply supply) {
    return EditableSupply(
      supplyId: supply.supplyId,
      productName: supply.productName,
      quantity: supply.quantity.toString(),
      unitPrice: supply.unitPrice.toString(),
      isEditing: false,
    );
  }

  EditableSupply copyWith() {
    return EditableSupply(
      supplyId: supplyId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      isEditing: isEditing,
    );
  }

  PurchasedSupply? toModel() {
    final parsedQty = int.tryParse(quantity.trim());
    final parsedPrice = double.tryParse(unitPrice.trim());
    if (productName.trim().isEmpty || parsedQty == null || parsedPrice == null) {
      return null;
    }

    return PurchasedSupply(
      supplyId: supplyId,
      productName: productName.trim(),
      vendor: '',
      quantity: parsedQty,
      unitPrice: parsedPrice,
    );
  }
}

class EditableSupport {
  String? financialSupportId;
  String householdName;
  String amount;
  bool isEditing;

  EditableSupport({
    required this.financialSupportId,
    required this.householdName,
    required this.amount,
    required this.isEditing,
  });

  factory EditableSupport.fromModel(FinancialSupportAllocation support) {
    return EditableSupport(
      financialSupportId: support.financialSupportId,
      householdName: support.householdName,
      amount: support.amount.toString(),
      isEditing: false,
    );
  }

  EditableSupport copyWith() {
    return EditableSupport(
      financialSupportId: financialSupportId,
      householdName: householdName,
      amount: amount,
      isEditing: isEditing,
    );
  }

  FinancialSupportAllocation? toModel() {
    final parsedAmount = double.tryParse(amount.trim());
    if (householdName.trim().isEmpty || parsedAmount == null) {
      return null;
    }

    return FinancialSupportAllocation(
      financialSupportId: financialSupportId,
      householdName: householdName.trim(),
      amount: parsedAmount,
    );
  }
}

class AllocationViewModel extends ChangeNotifier {
  final CharityCampaignRepository _repository;
  final String _campaignId;

  AllocationTab _activeTab = AllocationTab.supplies;
  bool _isSaving = false;

  late List<EditableSupply> _supplies;
  late List<EditableSupply> _initialSupplies;
  final Set<String> _deletedSupplyIds = <String>{};

  late List<EditableSupport> _supports;
  late List<EditableSupport> _initialSupports;
  final Set<String> _deletedSupportIds = <String>{};

  AllocationViewModel({
    required CharityCampaignRepository repository,
    required String campaignId,
    required List<PurchasedSupply> supplies,
    required List<FinancialSupportAllocation> financialSupports,
  }) : _repository = repository,
       _campaignId = campaignId {
    _supplies = supplies.map(EditableSupply.fromModel).toList(growable: true);
    _initialSupplies = _cloneSupplies(_supplies);
    _supports = financialSupports.map(EditableSupport.fromModel).toList(growable: true);
    _initialSupports = _cloneSupports(_supports);
  }

  AllocationTab get activeTab => _activeTab;
  bool get isSaving => _isSaving;
  List<EditableSupply> get supplies => List.unmodifiable(_supplies);
  List<EditableSupport> get supports => List.unmodifiable(_supports);

  List<PurchasedSupply> get currentSupplies {
    return _supplies
        .map((item) => item.toModel())
        .whereType<PurchasedSupply>()
        .toList(growable: false);
  }

  List<FinancialSupportAllocation> get currentFinancialSupports {
    return _supports
        .map((item) => item.toModel())
        .whereType<FinancialSupportAllocation>()
        .toList(growable: false);
  }

  double get suppliesTotal {
    return _supplies
        .map((item) => item.toModel())
        .whereType<PurchasedSupply>()
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  double get supportsTotal {
    return _supports
        .map((item) => item.toModel())
        .whereType<FinancialSupportAllocation>()
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  bool get hasUnsavedChanges {
    return _deletedSupplyIds.isNotEmpty ||
        _deletedSupportIds.isNotEmpty ||
        !_listEqualsSupply(_supplies, _initialSupplies) ||
        !_listEqualsSupport(_supports, _initialSupports);
  }

  void setActiveTab(AllocationTab tab) {
    if (_activeTab == tab) {
      return;
    }
    _activeTab = tab;
    notifyListeners();
  }

  void replaceSupplies(List<PurchasedSupply> supplies) {
    _supplies = supplies.map(EditableSupply.fromModel).toList(growable: true);
    _initialSupplies = _cloneSupplies(_supplies);
    _deletedSupplyIds.clear();
    notifyListeners();
  }

  void replaceFinancialSupports(List<FinancialSupportAllocation> supports) {
    _supports = supports.map(EditableSupport.fromModel).toList(growable: true);
    _initialSupports = _cloneSupports(_supports);
    _deletedSupportIds.clear();
    notifyListeners();
  }

  Future<List<PurchasedSupply>> loadSupplies() async {
    final supplies = await _repository.getCampaignSupplies(campaignId: _campaignId);
    replaceSupplies(supplies);
    return supplies;
  }

  Future<List<FinancialSupportAllocation>> loadFinancialSupports() async {
    final supports = await _repository.getCampaignFinancialSupports(campaignId: _campaignId);
    replaceFinancialSupports(supports);
    return supports;
  }

  void addSupplyRow() {
    _supplies.insert(
      0,
      EditableSupply(
        supplyId: null,
        productName: '',
        quantity: '1',
        unitPrice: '0',
        isEditing: true,
      ),
    );
    notifyListeners();
  }

  void addSupportRow() {
    _supports.insert(
      0,
      EditableSupport(
        financialSupportId: null,
        householdName: '',
        amount: '0',
        isEditing: true,
      ),
    );
    notifyListeners();
  }

  void updateSupplyProductName(int index, String value) {
    _supplies[index].productName = value;
    notifyListeners();
  }

  void updateSupplyQuantity(int index, String value) {
    _supplies[index].quantity = value;
    notifyListeners();
  }

  void updateSupplyUnitPrice(int index, String value) {
    _supplies[index].unitPrice = value;
    notifyListeners();
  }

  void toggleSupplyEdit(int index) {
    _supplies[index].isEditing = !_supplies[index].isEditing;
    notifyListeners();
  }

  void removeSupplyAt(int index) {
    final row = _supplies[index];
    if (row.supplyId != null && row.supplyId!.isNotEmpty) {
      _deletedSupplyIds.add(row.supplyId!);
    }
    _supplies.removeAt(index);
    notifyListeners();
  }

  void updateSupportHouseholdName(int index, String value) {
    _supports[index].householdName = value;
    notifyListeners();
  }

  void updateSupportAmount(int index, String value) {
    _supports[index].amount = value;
    notifyListeners();
  }

  void toggleSupportEdit(int index) {
    _supports[index].isEditing = !_supports[index].isEditing;
    notifyListeners();
  }

  void removeSupportAt(int index) {
    final row = _supports[index];
    if (row.financialSupportId != null && row.financialSupportId!.isNotEmpty) {
      _deletedSupportIds.add(row.financialSupportId!);
    }
    _supports.removeAt(index);
    notifyListeners();
  }

  Future<void> saveActiveTab() async {
    if (_isSaving) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      if (_activeTab == AllocationTab.supplies) {
        await _saveSupplies();
      } else {
        await _saveFinancialSupports();
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _saveSupplies() async {
    final initialById = <String, EditableSupply>{
      for (final item in _initialSupplies)
        if (item.supplyId != null) item.supplyId!: item,
    };

    for (final supplyId in _deletedSupplyIds) {
      await _repository.deleteCampaignSupply(
        campaignId: _campaignId,
        supplyId: supplyId,
      );
    }

    final saved = <EditableSupply>[];
    for (final row in _supplies) {
      final parsed = row.toModel();
      if (parsed == null) {
        throw Exception('Supply rows must have valid name, quantity and unit price');
      }

      if (parsed.supplyId == null || parsed.supplyId!.isEmpty) {
        final created = await _repository.createCampaignSupply(
          campaignId: _campaignId,
          supply: parsed,
        );
        saved.add(EditableSupply.fromModel(created));
        continue;
      }

      final oldRow = initialById[parsed.supplyId!];
      final isChanged = oldRow == null || !_supplyEqualsModel(oldRow.toModel(), parsed);
      if (isChanged) {
        final updated = await _repository.updateCampaignSupply(
          campaignId: _campaignId,
          supply: parsed,
        );
        saved.add(EditableSupply.fromModel(updated));
      } else {
        saved.add(EditableSupply.fromModel(parsed));
      }
    }

    _supplies = saved;
    _initialSupplies = _cloneSupplies(saved);
    _deletedSupplyIds.clear();
  }

  Future<void> _saveFinancialSupports() async {
    final initialById = <String, EditableSupport>{
      for (final item in _initialSupports)
        if (item.financialSupportId != null) item.financialSupportId!: item,
    };

    for (final supportId in _deletedSupportIds) {
      await _repository.deleteCampaignFinancialSupport(
        campaignId: _campaignId,
        financialSupportId: supportId,
      );
    }

    final saved = <EditableSupport>[];
    for (final row in _supports) {
      final parsed = row.toModel();
      if (parsed == null) {
        throw Exception('Financial support rows must have valid household and amount');
      }

      if (parsed.financialSupportId == null || parsed.financialSupportId!.isEmpty) {
        final created = await _repository.createCampaignFinancialSupport(
          campaignId: _campaignId,
          support: parsed,
        );
        saved.add(EditableSupport.fromModel(created));
        continue;
      }

      final oldRow = initialById[parsed.financialSupportId!];
      final isChanged = oldRow == null || !_supportEqualsModel(oldRow.toModel(), parsed);
      if (isChanged) {
        final updated = await _repository.updateCampaignFinancialSupport(
          campaignId: _campaignId,
          support: parsed,
        );
        saved.add(EditableSupport.fromModel(updated));
      } else {
        saved.add(EditableSupport.fromModel(parsed));
      }
    }

    _supports = saved;
    _initialSupports = _cloneSupports(saved);
    _deletedSupportIds.clear();
  }

  bool _listEqualsSupply(List<EditableSupply> a, List<EditableSupply> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_supplyEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  bool _listEqualsSupport(List<EditableSupport> a, List<EditableSupport> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_supportEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  bool _supplyEquals(EditableSupply a, EditableSupply b) {
    return a.supplyId == b.supplyId &&
        a.productName.trim() == b.productName.trim() &&
        a.quantity.trim() == b.quantity.trim() &&
        a.unitPrice.trim() == b.unitPrice.trim();
  }

  bool _supplyEqualsModel(PurchasedSupply? a, PurchasedSupply? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.supplyId == b.supplyId &&
        a.productName.trim() == b.productName.trim() &&
        a.quantity == b.quantity &&
        (a.unitPrice - b.unitPrice).abs() < 0.0001;
  }

  bool _supportEquals(EditableSupport a, EditableSupport b) {
    return a.financialSupportId == b.financialSupportId &&
        a.householdName.trim() == b.householdName.trim() &&
        a.amount.trim() == b.amount.trim();
  }

  bool _supportEqualsModel(FinancialSupportAllocation? a, FinancialSupportAllocation? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.financialSupportId == b.financialSupportId &&
        a.householdName.trim() == b.householdName.trim() &&
        (a.amount - b.amount).abs() < 0.0001;
  }

  List<EditableSupply> _cloneSupplies(List<EditableSupply> items) {
    return items.map((item) => item.copyWith()).toList(growable: true);
  }

  List<EditableSupport> _cloneSupports(List<EditableSupport> items) {
    return items.map((item) => item.copyWith()).toList(growable: true);
  }
}
