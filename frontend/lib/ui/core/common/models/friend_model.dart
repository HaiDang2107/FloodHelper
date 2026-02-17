import 'package:antiflood/ui/core/common/constants/user_state.dart';
import 'package:latlong2/latlong.dart';

class FriendModel {
  final String id;
  final String name;
  final String avatarUrl;
  final UserStatus status;
  final LatLng location;
  final bool isSosState;
  final List<String> roles;
  final DateTime dateOfBirth;
  final int? trappedCounts;
  final int? childrenNumbers;
  final int? elderlyNumbers;
  final bool? hasFood;
  final bool? hasWater;
  final String? other;
  final bool isFriend;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.location,
    required this.dateOfBirth,
    this.isSosState = false,
    this.roles = const [],
    this.trappedCounts,
    this.childrenNumbers,
    this.elderlyNumbers,
    this.hasFood,
    this.hasWater,
    this.other,
    this.isFriend = true,
  });
}

// Mock friends data
final List<FriendModel> mockFriends = [
  FriendModel(
    id: '1',
    name: 'Nguyễn Văn An',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    status: UserStatus.online,
    location: const LatLng(21.0285, 105.8542), // Hanoi
    dateOfBirth: DateTime(1990, 5, 15),
    roles: ['Rescuer'],
    isFriend: true,
  ),
  FriendModel(
    id: '2',
    name: 'Trần Thị Bình',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    status: UserStatus.online,
    location: const LatLng(21.0295, 105.8552),
    dateOfBirth: DateTime(1988, 8, 22),
    isSosState: true,
    trappedCounts: 5,
    childrenNumbers: 2,
    elderlyNumbers: 1,
    hasFood: false,
    hasWater: true,
    other: 'Need immediate rescue. Water level rising.',
    isFriend: false, // Stranger
  ),
  FriendModel(
    id: '3',
    name: 'Lê Văn Cường',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    status: UserStatus.offline,
    location: const LatLng(21.0275, 105.8532),
    dateOfBirth: DateTime(1995, 3, 10),
    isFriend: true,
  ),
  FriendModel(
    id: '4',
    name: 'Phạm Thị Dung',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
    status: UserStatus.online,
    location: const LatLng(21.0305, 105.8562),
    dateOfBirth: DateTime(1992, 11, 5),
    roles: ['Benefactor'],
    isFriend: true,
  ),
  FriendModel(
    id: '5',
    name: 'Hoàng Văn Em',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    status: UserStatus.offline,
    location: const LatLng(21.0265, 105.8522),
    dateOfBirth: DateTime(1985, 7, 18),
    isFriend: false, // Stranger
  ),
  FriendModel(
    id: '6',
    name: 'Võ Thị Phương',
    avatarUrl: 'https://i.pravatar.cc/150?img=6',
    status: UserStatus.online,
    location: const LatLng(21.0315, 105.8572),
    dateOfBirth: DateTime(1993, 12, 30),
    isFriend: true,
  ),
  FriendModel(
    id: '7',
    name: 'Đỗ Văn Giang',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
    status: UserStatus.online,
    location: const LatLng(21.0255, 105.8512),
    dateOfBirth: DateTime(1987, 4, 25),
    isSosState: true,
    roles: ['Rescuer', 'Benefactor'],
    trappedCounts: 3,
    childrenNumbers: 0,
    elderlyNumbers: 2,
    hasFood: true,
    hasWater: false,
    other: 'Running out of water supplies.',
    isFriend: false, // Stranger
  ),
  FriendModel(
    id: '8',
    name: 'Bùi Thị Hạnh',
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    status: UserStatus.offline,
    location: const LatLng(21.0325, 105.8582),
    dateOfBirth: DateTime(1991, 9, 14),
    isFriend: true,
  ),
  FriendModel(
    id: '9',
    name: 'Ngô Văn Inh',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    status: UserStatus.online,
    location: const LatLng(21.0245, 105.8502),
    dateOfBirth: DateTime(1994, 6, 8),
    isFriend: false, // Stranger
  ),
  FriendModel(
    id: '10',
    name: 'Đinh Thị Kim',
    avatarUrl: 'https://i.pravatar.cc/150?img=10',
    status: UserStatus.offline,
    location: const LatLng(21.0335, 105.8592),
    dateOfBirth: DateTime(1989, 2, 19),
    isFriend: true,
  ),
];
