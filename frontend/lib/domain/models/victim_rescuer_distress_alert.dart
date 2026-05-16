class VictimOrRescuerAlert {
  final String userId;
  final String? fullname;
  final double latitude;
  final double longitude;
  final bool isSos;
  final bool isOnline;

  const VictimOrRescuerAlert({
    required this.userId,
    this.fullname,
    required this.latitude,
    required this.longitude,
    this.isSos = false,
    this.isOnline = false,
  });
}
