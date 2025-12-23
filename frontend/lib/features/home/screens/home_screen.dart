import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/home_service.dart';
import '../../../common/widgets/bottom_sheet.dart';
import '../widgets/home_top_actions.dart';
import '../widgets/home_bottom_actions.dart';
import '../widgets/segmented_button.dart';
import '../widgets/home_map_actions_fab.dart';
import '../widgets/user_pin.dart';
import '../widgets/post_pin.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../common/constants/user_state.dart';
import '../../../common/models/friend_model.dart';
import '../../../common/models/post_model.dart';
import '_stranger_details_sheet.dart';
import '_settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final HomeService _homeService = HomeService();
  LatLng? _currentPosition;
  bool _isLoading = true;
  MapType _selectedMapType = MapType.transport;
  bool _isSosBroadcasting = false;
  Map<String, dynamic>? _sosData;
  bool _showStrangerLocation = true;
  bool _showPostLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final position = await _homeService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentPosition!, 15.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      final photo = await _homeService.takePicture();
      if (photo != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Picture taken: ${photo.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _moveCameraToFriend(LatLng location) {
    _mapController.move(location, 17.0);
  }

  void _handleSosBroadcast(Map<String, dynamic> data) {
    setState(() {
      _isSosBroadcasting = true;
      _sosData = data;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Distress signal is now broadcasting'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleSosRevoke() {
    setState(() {
      _isSosBroadcasting = false;
      _sosData = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Distress signal has been revoked'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _showBottomSheet(String title, Widget content, {Color? backgroundColor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder( // biến một đoạn code giao diện đang tĩnh thành động ngay tại chỗ mà không cần tách class.
          builder: (context, setModalState) {
            return CustomBottomSheet(
              title: title,
              backgroundColor: backgroundColor,
              child: title == 'Settings'
                  ? SettingsSheet(
                      showStrangerLocation: _showStrangerLocation, // truyền từ home cho setting
                      showPostLocation: _showPostLocation,
                      onShowStrangerLocationChanged: (value) {
                        setState(() { // setState(): rebuild lại màn hình cha 
                        // ~ this.setState() (do extend mà có)
                          _showStrangerLocation = value; // đồng bộ trạng thái biến
                        });
                        setModalState(() {}); // Rebuild bottom sheet (tự vẽ lại chính nó)
                      },
                      onShowPostLocationChanged: (value) {
                        setState(() {
                          _showPostLocation = value;
                        });
                        setModalState(() {}); // Rebuild bottom sheet
                      },
                    )
                  : content,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition ??
                  const LatLng(21.0285, 105.8542), // Default to Hanoi
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _selectedMapType == MapType.transport
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: _selectedMapType == MapType.weather
                    ? const ['a', 'b', 'c']
                    : const [],
                userAgentPackageName: 'com.example.antiflood',
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    // Current user marker
                    Marker(
                      point: _currentPosition!,
                      width: 60, // fixed
                      height: 81, // fixed
                      alignment: Alignment.topCenter,
                      rotate:
                          true, // Giữ marker luôn đứng thẳng (ngược chiều xoay của bản đồ)
                      child: UserLocationPin(
                        size: 60,
                        imageUrl: 'https://i.pravatar.cc/300',
                        color: UserStatus.online.color,
                        roles: const [],
                      ),
                    ),
                    // Friend markers
                    ...mockFriends
                        .where((friend) =>
                            friend.isFriend || _showStrangerLocation)
                        .map(
                      (friend) => Marker(
                        point: LatLng(
                          friend.location.latitude,
                          friend.location.longitude,
                        ),
                        width: 60,
                        height: 81,
                        alignment: Alignment.topCenter,
                        rotate: true,
                        child: UserLocationPin(
                          size: 60,
                          imageUrl: friend.avatarUrl,
                          color: friend.status.color,
                          isSosState: friend.isSosState,
                          roles: friend.roles,
                          onTap: () {
                            _showBottomSheet(
                              friend.name,
                              StrangerDetailsSheet(
                                userId: friend.id,
                                fullName: friend.name,
                                dateOfBirth: friend.dateOfBirth,
                                roles: friend.roles,
                                isSosState: friend.isSosState,
                                trappedCounts: friend.trappedCounts,
                                childrenNumbers: friend.childrenNumbers,
                                elderlyNumbers: friend.elderlyNumbers,
                                hasFood: friend.hasFood,
                                hasWater: friend.hasWater,
                                other: friend.other,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Post markers
                    if (_showPostLocation)
                      ...mockPosts.map(
                        (post) => Marker(
                        point: post.location,
                        width: 60,
                        height: 81,
                        alignment: Alignment.topCenter,
                        rotate: true,
                        child: PostLocationPin(
                          size: 60,
                          imageUrl: post.imageUrl,
                          onTap: () {
                            // TODO: Show post details
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0, right: 16.0),
                child: HomeMapActionsFab(mapType: _selectedMapType),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                child: HomeTopActions(
                  onShowBottomSheet: _showBottomSheet,
                  onProfilePressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  isSosBroadcasting: _isSosBroadcasting,
                  sosData: _sosData,
                  onSosBroadcast: _handleSosBroadcast,
                  onSosRevoke: _handleSosRevoke,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HomeMapTypeSwitch(
                  selectedMapType: _selectedMapType,
                  onMapTypeChanged: (MapType newType) {
                    setState(() {
                      _selectedMapType = newType;
                    });
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  left: 48.0,
                  right: 48.0,
                ),
                child: HomeBottomActions(
                  onTakePicture: _takePicture,
                  onGetCurrentLocation: _getCurrentLocation,
                  onShowBottomSheet: _showBottomSheet,
                  onLocateFriend: _moveCameraToFriend,
                ),
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
