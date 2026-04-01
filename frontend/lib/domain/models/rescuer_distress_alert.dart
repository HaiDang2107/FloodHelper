class VictimAlert {
  final String userId;
  final String? fullname;
  final double latitude;
  final double longitude;

  const VictimAlert({
    required this.userId,
    this.fullname,
    required this.latitude,
    required this.longitude,
  });
}
