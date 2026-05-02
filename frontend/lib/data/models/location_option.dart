class ProvinceOption {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int phoneCode;

  const ProvinceOption({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
  });

  String get displayLabel => name;
}

class WardOption {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int provinceCode;

  const WardOption({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.provinceCode,
  });

  String get displayLabel => name;
}