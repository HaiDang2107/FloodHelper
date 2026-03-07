import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:latlong2/latlong.dart';
import '../view_models/home_view_model.dart';
import '../view_models/friend_view_model.dart';
import '../widgets/home_top_actions.dart';
import '../widgets/home_bottom_actions.dart';
import '../widgets/segmented_button.dart';
import '../widgets/home_map_actions_fab.dart';
import '../widgets/user_pin.dart';
import '../../core/common/widgets/bottom_sheet.dart';
import '../../core/common/constants/user_state.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../data/services/firebase_messaging_service.dart';
import '../../../data/providers/auth_provider.dart';
import 'settings/_settings_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    // Note: FCM token is registered in SignInViewModel after successful login
    // Here we only setup message handlers

    // Handle foreground messages
    _messagingService.onForegroundMessage((RemoteMessage message) {
      final data = message.data;
      if (data['type'] == 'FRIEND_REQUEST') {
        // A new friend request received - reload received requests
        ref.read(friendViewModelProvider.notifier).loadRequests();

        // Show a snackbar notification
        if (mounted) {
          final senderName = data['senderName'] ?? 'Someone';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$senderName sent you a friend request'),
              backgroundColor: const Color(0xFF0F62FE),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  // Could navigate to friend requests sheet
                },
              ),
            ),
          );
        }
      } else if (data['type'] == 'FRIEND_REQUEST_ACCEPTED') {
        // Friend request was accepted - reload friends
        ref.read(homeViewModelProvider.notifier).loadFriends();
        ref.read(friendViewModelProvider.notifier).loadRequests();
      }
    });

    // Handle notification taps
    _messagingService.onMessageOpenedApp((RemoteMessage message) {
      // Could navigate to friend requests screen
    });
  }

  void _showBottomSheet(String title, Widget content, {Color? backgroundColor}) {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final state = ref.read(homeViewModelProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomBottomSheet(
              title: title,
              backgroundColor: backgroundColor,
              child: title == 'Settings'
                  ? SettingsSheet(
                      showStrangerLocation: state.showStrangerLocation,
                      showPostLocation: state.showPostLocation,
                      onShowStrangerLocationChanged: (value) {
                        viewModel.setShowStrangerLocation(value);
                        setModalState(() {});
                      },
                      onShowPostLocationChanged: (value) {
                        viewModel.setShowPostLocation(value);
                        setModalState(() {});
                      },
                    )
                  : content,
            );
          },
        );
      },
    );
  }

  void _handleSosBroadcast(Map<String, dynamic> data) {
    ref.read(homeViewModelProvider.notifier).broadcastSos(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Distress signal is now broadcasting'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleSosRevoke() {
    ref.read(homeViewModelProvider.notifier).revokeSos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Distress signal has been revoked'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  Future<void> _takePicture() async {
    final photo = await ref.read(homeViewModelProvider.notifier).takePicture();
    if (photo != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture taken: ${photo.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // Listen for errors - must be inside build()
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        viewModel.clearError();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: viewModel.mapController,
            options: MapOptions(
              initialCenter: state.currentPosition ?? const LatLng(21.0285, 105.8542),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: state.selectedMapType == MapType.transport
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: state.selectedMapType == MapType.weather
                    ? const ['a', 'b', 'c']
                    : const [],
                userAgentPackageName: 'com.example.antiflood',
              ),
              if (state.currentPosition != null)
                MarkerLayer(
                  markers: [
                    // Current user marker
                    Marker(
                      point: state.currentPosition!,
                      width: 60,
                      height: 81,
                      alignment: Alignment.topCenter,
                      rotate: true,
                      child: UserLocationPin(
                        size: 60,
                        imageUrl: ref.watch(currentUserProvider)?.avatarUrl ?? '',
                        color: UserStatus.online.color,
                        roles: const [],
                      ),
                    ),
                    // TODO: Add real friend/nearby user markers here
                    // TODO: Add real post markers here
                  ],
                ),
            ],
          ),

          // Map Actions FAB
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0, right: 16.0),
                child: HomeMapActionsFab(mapType: state.selectedMapType),
              ),
            ),
          ),

          // Top Actions
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
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  isSosBroadcasting: state.isSosBroadcasting,
                  sosData: state.sosData,
                  onSosBroadcast: _handleSosBroadcast,
                  onSosRevoke: _handleSosRevoke,
                ),
              ),
            ),
          ),

          // Map Type Switch
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HomeMapTypeSwitch(
                  selectedMapType: state.selectedMapType,
                  onMapTypeChanged: viewModel.setMapType,
                ),
              ),
            ),
          ),

          // Bottom Actions
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
                  onGetCurrentLocation: viewModel.recenterMap,
                  onShowBottomSheet: _showBottomSheet,
                  onLocateFriend: viewModel.moveCameraToLocation,
                ),
              ),
            ),
          ),

          // Loading indicator
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
