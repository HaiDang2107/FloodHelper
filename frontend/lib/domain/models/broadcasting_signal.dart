class BroadcastingSignal {
  final String signalId;
  final String createdBy;
  final DateTime createdAt;
  final int trappedCount;
  final int childrenNum;
  final int elderlyNum;
  final bool hasFood;
  final bool hasWater;
  final String? note;
  final String userFullname;
  final String? userPhoneNumber;

  const BroadcastingSignal({
    required this.signalId,
    required this.createdBy,
    required this.createdAt,
    required this.trappedCount,
    required this.childrenNum,
    required this.elderlyNum,
    required this.hasFood,
    required this.hasWater,
    required this.note,
    required this.userFullname,
    required this.userPhoneNumber,
  });
}
