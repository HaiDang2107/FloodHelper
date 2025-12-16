import 'package:antiflood/common/constants/user_state.dart';
import 'package:latlong2/latlong.dart';

class FriendModel {
  final String id;
  final String name;
  final String avatarUrl;
  final UserStatus status;
  final LatLng location;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.location,
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
  ),
  FriendModel(
    id: '2',
    name: 'Trần Thị Bình',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    status: UserStatus.online,
    location: const LatLng(21.0295, 105.8552),
  ),
  FriendModel(
    id: '3',
    name: 'Lê Văn Cường',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    status: UserStatus.offline,
    location: const LatLng(21.0275, 105.8532),
  ),
  FriendModel(
    id: '4',
    name: 'Phạm Thị Dung',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
    status: UserStatus.online,
    location: const LatLng(21.0305, 105.8562),
  ),
  FriendModel(
    id: '5',
    name: 'Hoàng Văn Em',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    status: UserStatus.offline,
    location: const LatLng(21.0265, 105.8522),
  ),
  FriendModel(
    id: '6',
    name: 'Võ Thị Phương',
    avatarUrl: 'https://i.pravatar.cc/150?img=6',
    status: UserStatus.online,
    location: const LatLng(21.0315, 105.8572),
  ),
  FriendModel(
    id: '7',
    name: 'Đỗ Văn Giang',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
    status: UserStatus.online,
    location: const LatLng(21.0255, 105.8512),
  ),
  FriendModel(
    id: '8',
    name: 'Bùi Thị Hạnh',
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    status: UserStatus.offline,
    location: const LatLng(21.0325, 105.8582),
  ),
  FriendModel(
    id: '9',
    name: 'Ngô Văn Inh',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    status: UserStatus.online,
    location: const LatLng(21.0245, 105.8502),
  ),
  FriendModel(
    id: '10',
    name: 'Đinh Thị Kim',
    avatarUrl: 'https://i.pravatar.cc/150?img=10',
    status: UserStatus.offline,
    location: const LatLng(21.0335, 105.8592),
  ),
];
