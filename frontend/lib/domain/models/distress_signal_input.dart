class DistressSignalInput {
  final int trappedCounts;
  final int childrenNumbers;
  final int elderlyNumbers;
  final bool hasFood;
  final bool hasWater;
  final String? other;

  const DistressSignalInput({
    required this.trappedCounts,
    required this.childrenNumbers,
    required this.elderlyNumbers,
    required this.hasFood,
    required this.hasWater,
    this.other,
  });
}
