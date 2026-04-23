class BankOption {
  final int id;
  final String shortName;

  const BankOption({
    required this.id,
    required this.shortName,
  });

  String get displayLabel => shortName;
}