import 'package:flutter/material.dart';

import '../../../../data/models/location_option.dart';
import '../../../../data/services/location_service.dart';

class LocationSelection {
  final ProvinceOption? province;
  final WardOption? ward;

  const LocationSelection({this.province, this.ward});
}

class LocationSelectorField extends StatefulWidget {
  const LocationSelectorField({
    super.key,
    required this.provinceLabel,
    required this.wardLabel,
    this.initialProvinceCode,
    this.initialWardCode,
    this.onChanged,
    this.enabled = true,
    this.showDetailField = false,
    this.detailController,
    this.detailLabel,
    this.detailHint,
  });

  final String provinceLabel;
  final String wardLabel;
  final int? initialProvinceCode;
  final int? initialWardCode;
  final ValueChanged<LocationSelection>? onChanged;
  final bool enabled;
  final bool showDetailField;
  final TextEditingController? detailController;
  final String? detailLabel;
  final String? detailHint;

  @override
  State<LocationSelectorField> createState() => _LocationSelectorFieldState();
}

class _LocationSelectorFieldState extends State<LocationSelectorField> {
  final LocationService _locationService = LocationService();
  List<ProvinceOption> _provinces = const [];
  List<WardOption> _wards = const [];
  ProvinceOption? _selectedProvince;
  WardOption? _selectedWard;
  bool _isLoading = true;
  bool _isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void didUpdateWidget(covariant LocationSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProvinceCode != widget.initialProvinceCode ||
        oldWidget.initialWardCode != widget.initialWardCode) {
      if (widget.initialProvinceCode == _selectedProvince?.code &&
          widget.initialWardCode == _selectedWard?.code) {
        return;
      }
      _syncInitialSelection();
    }
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _locationService.getProvinces();
      if (!mounted) return;

      setState(() {
        _provinces = provinces;
        _isLoading = false;
      });

      await _syncInitialSelection();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _provinces = const [];
        _isLoading = false;
      });
      _notifySelection();
    }
  }

  Future<void> _syncInitialSelection() async {
    if (_provinces.isEmpty) {
      _notifySelection();
      return;
    }

    ProvinceOption? province;
    if (widget.initialProvinceCode != null) {
      for (final item in _provinces) {
        if (item.code == widget.initialProvinceCode) {
          province = item;
          break;
        }
      }
    }

    if (province == null) {
      if (!mounted) return;
      setState(() {
        _selectedProvince = null;
        _selectedWard = null;
        _wards = const [];
      });
      _notifySelection();
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedProvince = province;
      _selectedWard = null;
      _wards = const [];
      _isLoadingWards = true;
    });

    final wards = await _locationService.getWards(
      provinceCode: province.code,
    );
    if (!mounted) return;

    WardOption? ward;
    if (widget.initialWardCode != null) {
      for (final item in wards) {
        if (item.code == widget.initialWardCode) {
          ward = item;
          break;
        }
      }
    }

    setState(() {
      _wards = wards;
      _selectedWard = ward;
      _isLoadingWards = false;
    });

    _notifySelection();
  }

  Future<void> _onProvinceChanged(int? provinceCode) async {
    if (provinceCode == null) {
      setState(() {
        _selectedProvince = null;
        _selectedWard = null;
        _wards = const [];
      });
      _notifySelection();
      return;
    }

    final province = _provinces.firstWhere((item) => item.code == provinceCode);
    setState(() {
      _selectedProvince = province;
      _selectedWard = null;
      _wards = const [];
      _isLoadingWards = true;
    });

    final wards = await _locationService.getWards(provinceCode: province.code);
    if (!mounted) return;

    setState(() {
      _wards = wards;
      _isLoadingWards = false;
    });

    _notifySelection();
  }

  void _onWardChanged(int? wardCode) {
    if (wardCode == null) {
      setState(() {
        _selectedWard = null;
      });
      _notifySelection();
      return;
    }

    final ward = _wards.firstWhere((item) => item.code == wardCode);
    setState(() {
      _selectedWard = ward;
    });
    _notifySelection();
  }

  void _notifySelection() {
    widget.onChanged?.call(
      LocationSelection(
        province: _selectedProvince,
        ward: _selectedWard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedProvince?.code,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.provinceLabel,
            border: const OutlineInputBorder(),
          ),
          items: _provinces
              .map(
                (province) => DropdownMenuItem<int>(
                  value: province.code,
                  child: Text(province.displayLabel),
                ),
              )
              .toList(growable: false),
          onChanged: widget.enabled ? _onProvinceChanged : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _selectedWard?.code,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.wardLabel,
            border: const OutlineInputBorder(),
          ),
          items: _wards
              .map(
                (ward) => DropdownMenuItem<int>(
                  value: ward.code,
                  child: Text(ward.displayLabel),
                ),
              )
              .toList(growable: false),
          onChanged: widget.enabled && !_isLoadingWards
              ? _onWardChanged
              : null,
        ),
        if (widget.showDetailField && widget.detailController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.detailController,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.detailLabel ?? 'Detail',
              hintText: widget.detailHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
