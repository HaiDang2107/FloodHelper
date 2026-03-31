import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_top_actions.dart';
import '../widgets/home_bottom_actions.dart';
import '../widgets/segmented_button.dart';
import '../widgets/home_map_actions_fab.dart';
import '../widgets/user_pin.dart';
import '../../core/common/widgets/bottom_sheet.dart';
import '../../core/common/constants/user_state.dart';
import '../../profile/screens/profile_screen.dart';
import '../../charity_campaign/screens/existing_charity_screen.dart';
import '../../../data/providers/providers.dart';
import '../../../data/services/firebase_messaging_service.dart';
import 'settings/_settings_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  late final FirebaseMessagingService _messagingService = ref.read(firebaseMessagingServiceProvider);
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = ref.read(homeViewModelProvider.notifier);
    // WidgetsBinding dùng để quản lý lifecycle của app
    // addObserver(this): _HomeScreenState đăng ký nhận callback từ WidgetsBindings
    WidgetsBinding.instance.addObserver(this); 
    _homeViewModel.setupFirebaseMessaging(_messagingService);
    _homeViewModel.setUiIsActive(true); // UI isolate is online.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { // Kiểm soát trạng tháu UI
    if (!mounted) return;
    final isActive = state == AppLifecycleState.resumed; // state == resumed ==> isActive = true
    _homeViewModel.setUiIsActive(isActive);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    _homeViewModel.setUiIsActive(false);
    super.dispose();
  }

  void _showBottomSheet(String title, Widget content, {Color? backgroundColor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: title,
          backgroundColor: backgroundColor,
          child: title == 'Settings' ? const SettingsSheet() : content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    // Listen for errors - must be inside build()
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      if (next.uiEvent != null && next.uiEvent != previous?.uiEvent) {
        final color = switch (next.uiEvent!.type) {
          HomeUiEventType.success => Colors.green,
          HomeUiEventType.error => Colors.red,
          HomeUiEventType.info => const Color(0xFF0F62FE),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.uiEvent!.message),
            backgroundColor: color,
          ),
        );
        viewModel.clearUiEvent();
      }

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
                    // Friend location markers (from MQTT)
                    ...state.friendLocations.entries.map((entry) {
                      final friendId = entry.key;
                      final latLng = entry.value;
                      // Find friend info for display
                      final friendInfo = state.friendsWithMapMode
                          .where((f) => f.userId == friendId)
                          .firstOrNull;
                      return Marker(
                        point: latLng,
                        width: 60,
                        height: 81,
                        alignment: Alignment.topCenter,
                        rotate: true,
                        child: UserLocationPin(
                          size: 60,
                          imageUrl: friendInfo?.avatarUrl ?? '',
                          color: const Color(0xFF0F62FE),
                          roles: const [],
                        ),
                      );
                    }),

                    // Rescuer distress markers (from rescuer/common)
                    ...state.victimLocations.entries.map((entry) {
                      return Marker(
                        point: entry.value,
                        width: 60,
                        height: 81,
                        alignment: Alignment.topCenter,
                        rotate: true,
                        child: const UserLocationPin(
                          size: 60,
                          imageUrl: '',
                          color: Colors.red,
                          isSosState: true,
                          roles: [],
                        ),
                      );
                    }),
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
                  onRescuerPressed: () {
                    viewModel.showInfoMessage('Rescuer feature coming soon!');
                  },
                  onCharityPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExistingCharityScreen(),
                      ),
                    );
                  },
                  isSosBroadcasting: state.isSosBroadcasting,
                  sosData: state.sosData,
                  onSosBroadcast: viewModel.broadcastSos,
                  onSosRevoke: viewModel.revokeSos,
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
                  onTakePicture: viewModel.takePicture,
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
