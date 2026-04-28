import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/charity_campaign_repository.dart';
import '../../../domain/models/charity_campaign.dart';

part 'allocation_view_model.g.dart';

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

@riverpod
class AllocationViewModel extends _$AllocationViewModel {
  late final CharityCampaignRepository _repository = ref.read(
    charityCampaignRepositoryProvider,
  );
  late final String _campaignId;

  late List<EditableSupply> _initialSupplies;
  final Set<String> _deletedSupplyIds = <String>{};

  late List<EditableSupport> _initialSupports;
  final Set<String> _deletedSupportIds = <String>{};

  @override
  AllocationState build(AllocationViewModelSeed seed) {
    _campaignId = seed.campaignId;

    final supplies = seed.supplies
        .map(EditableSupply.fromModel)
        .toList(growable: true);
    final supports = seed.financialSupports
        .map(EditableSupport.fromModel)
        .toList(growable: true);

    _initialSupplies = _cloneSupplies(supplies);
    _initialSupports = _cloneSupports(supports);
    _deletedSupplyIds.clear();
    _deletedSupportIds.clear();

    return AllocationState(
      activeTab: AllocationTab.supplies,
      isSaving: false,
      supplies: supplies,
      supports: supports,
    );
  }

  AllocationTab get activeTab => state.activeTab;
  bool get isSaving => state.isSaving;
  List<EditableSupply> get supplies => List.unmodifiable(state.supplies);
  List<EditableSupport> get supports => List.unmodifiable(state.supports);

  List<PurchasedSupply> get currentSupplies {
    return state.supplies
        .map((item) => item.toModel())
        .whereType<PurchasedSupply>()
        .toList(growable: false);
  }

  List<FinancialSupportAllocation> get currentFinancialSupports {
    return state.supports
        .map((item) => item.toModel())
        .whereType<FinancialSupportAllocation>()
        .toList(growable: false);
  }

  double get suppliesTotal {
    return state.supplies
        .map((item) => item.toModel())
        .whereType<PurchasedSupply>()
        .fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  double get supportsTotal {
    return state.supports
        .map((item) => item.toModel())
        .whereType<FinancialSupportAllocation>()
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  bool get hasUnsavedChanges {
    return _deletedSupplyIds.isNotEmpty ||
      _deletedSupportIds.isNotEmpty ||
      !_listEqualsSupply(state.supplies, _initialSupplies) ||
      !_listEqualsSupport(state.supports, _initialSupports);
  }

  void setActiveTab(AllocationTab tab) {
    if (state.activeTab == tab) {
      return;
    }
    state = state.copyWith(activeTab: tab);
  }

  void replaceSupplies(List<PurchasedSupply> supplies) {
    final nextSupplies =
      supplies.map(EditableSupply.fromModel).toList(growable: true);
    state = state.copyWith(supplies: nextSupplies);
    _initialSupplies = _cloneSupplies(nextSupplies);
    _deletedSupplyIds.clear();
  }

  void replaceFinancialSupports(List<FinancialSupportAllocation> supports) {
    final nextSupports =
      supports.map(EditableSupport.fromModel).toList(growable: true);
    state = state.copyWith(supports: nextSupports);
    _initialSupports = _cloneSupports(nextSupports);
    _deletedSupportIds.clear();
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
    final nextSupplies = [...state.supplies]
      ..insert(
        0,
        EditableSupply(
          supplyId: null,
          productName: '',
          quantity: '1',
          unitPrice: '0',
          isEditing: true,
        ),
      );
    state = state.copyWith(supplies: nextSupplies);
  }

  void addSupportRow() {
    final nextSupports = [...state.supports]
      ..insert(
        0,
        EditableSupport(
          financialSupportId: null,
          householdName: '',
          amount: '0',
          isEditing: true,
        ),
      );
    state = state.copyWith(supports: nextSupports);
  }

  void updateSupplyProductName(int index, String value) {
    final nextSupplies = [...state.supplies];
    nextSupplies[index] = nextSupplies[index].copyWith()
      ..productName = value;
    state = state.copyWith(supplies: nextSupplies);
  }

  void updateSupplyQuantity(int index, String value) {
    final nextSupplies = [...state.supplies];
    nextSupplies[index] = nextSupplies[index].copyWith()
      ..quantity = value;
    state = state.copyWith(supplies: nextSupplies);
  }

  void updateSupplyUnitPrice(int index, String value) {
    final nextSupplies = [...state.supplies];
    nextSupplies[index] = nextSupplies[index].copyWith()
      ..unitPrice = value;
    state = state.copyWith(supplies: nextSupplies);
  }

  void toggleSupplyEdit(int index) {
    final nextSupplies = [...state.supplies];
    final updated = nextSupplies[index].copyWith();
    updated.isEditing = !updated.isEditing;
    nextSupplies[index] = updated;
    state = state.copyWith(supplies: nextSupplies);
  }

  void removeSupplyAt(int index) {
    final nextSupplies = [...state.supplies];
    final row = nextSupplies[index];
    if (row.supplyId != null && row.supplyId!.isNotEmpty) {
      _deletedSupplyIds.add(row.supplyId!);
    }
    nextSupplies.removeAt(index);
    state = state.copyWith(supplies: nextSupplies);
  }

  void updateSupportHouseholdName(int index, String value) {
    final nextSupports = [...state.supports];
    nextSupports[index] = nextSupports[index].copyWith()
      ..householdName = value;
    state = state.copyWith(supports: nextSupports);
  }

  void updateSupportAmount(int index, String value) {
    final nextSupports = [...state.supports];
    nextSupports[index] = nextSupports[index].copyWith()
      ..amount = value;
    state = state.copyWith(supports: nextSupports);
  }

  void toggleSupportEdit(int index) {
    final nextSupports = [...state.supports];
    final updated = nextSupports[index].copyWith();
    updated.isEditing = !updated.isEditing;
    nextSupports[index] = updated;
    state = state.copyWith(supports: nextSupports);
  }

  void removeSupportAt(int index) {
    final nextSupports = [...state.supports];
    final row = nextSupports[index];
    if (row.financialSupportId != null && row.financialSupportId!.isNotEmpty) {
      _deletedSupportIds.add(row.financialSupportId!);
    }
    nextSupports.removeAt(index);
    state = state.copyWith(supports: nextSupports);
  }

  Future<void> saveActiveTab() async {
    if (state.isSaving) {
      return;
    }

    state = state.copyWith(isSaving: true);

    try {
      if (state.activeTab == AllocationTab.supplies) {
        await _saveSupplies();
      } else {
        await _saveFinancialSupports();
      }
    } finally {
      state = state.copyWith(isSaving: false);
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
    for (final row in state.supplies) {
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

    state = state.copyWith(supplies: saved);
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
    for (final row in state.supports) {
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

    state = state.copyWith(supports: saved);
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

class AllocationState {
  final AllocationTab activeTab;
  final bool isSaving;
  final List<EditableSupply> supplies;
  final List<EditableSupport> supports;

  const AllocationState({
    required this.activeTab,
    required this.isSaving,
    required this.supplies,
    required this.supports,
  });

  AllocationState copyWith({
    AllocationTab? activeTab,
    bool? isSaving,
    List<EditableSupply>? supplies,
    List<EditableSupport>? supports,
  }) {
    return AllocationState(
      activeTab: activeTab ?? this.activeTab,
      isSaving: isSaving ?? this.isSaving,
      supplies: supplies ?? this.supplies,
      supports: supports ?? this.supports,
    );
  }
}
