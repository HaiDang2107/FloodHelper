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
import '../widgets/pin_action_bubble.dart';
import '../../core/common/widgets/bottom_sheet.dart';
import '../../core/common/constants/user_state.dart';
import '../../profile/views/profile_screen.dart';
import '../../charity_campaign/views/existing_charity_screen.dart';
import '../../charity_campaign/widgets/charity_item.dart';
import '../widgets/campaign_pin.dart';
import '../../../data/providers/providers.dart';
import '../../../data/services/firebase_messaging_service.dart';
import 'settings/_settings_sheet.dart';
import 'rescuer/_broadcasting_signals_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  late final FirebaseMessagingService _messagingService = ref.read(
    firebaseMessagingServiceProvider,
  );
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kiểm soát trạng tháu UI
    if (!mounted) return;
    final isActive =
        state ==
        AppLifecycleState.resumed; // state == resumed ==> isActive = true
    _homeViewModel.setUiIsActive(isActive);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeViewModel.setUiIsActive(false);
    super.dispose();
  }

  void _showBottomSheet(
    String title,
    Widget content, {
    Color? backgroundColor,
  }) {
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

  Future<void> _openCampaignDetail(String campaignId) async {
    try {
      final homeVm = ref.read(homeViewModelProvider.notifier);
      final campaign = await homeVm.loadCampaignDetailFromMapPin(campaignId);
      if (!mounted) {
        return;
      }

      await CharityItem.showDetailsBottomSheet(
        context,
        campaign: campaign,
        isOwner: false,
        onLoadCampaignDetail: homeVm.loadCampaignDetailFromMapPin,
        onLoadCampaignTransactions: homeVm.loadSuccessCampaignTransactions,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open campaign detail: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final pins = viewModel.mapPins;
    final selectedBubble = viewModel.selectedBubbleData;
    final hasHandleButton = selectedBubble?.canHandle ?? false;
    final bubbleHeight = hasHandleButton ? 260.0 : 170.0;
    final bubbleLift = hasHandleButton ? 67.0 : 67.0;
    HomeMapPin? selectedPin;
    if (selectedBubble != null) {
      for (final pin in pins) {
        if (pin.userId == selectedBubble.userId) {
          selectedPin = pin;
          break;
        }
      }
    }
    final bubbleWidth = (MediaQuery.of(context).size.width - 32).clamp(
      220.0,
      320.0,
    );

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

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
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
              initialCenter:
                  state.currentPosition ?? const LatLng(21.0285, 105.8542),
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
                  markers: pins
                      .map((pin) {
                        final color = switch (pin.pinType) {
                          HomePinType.me => UserStatus.online.color,
                          HomePinType.friend => const Color(0xFF0F62FE),
                          HomePinType.victim => Colors.red,
                          HomePinType.campaign => const Color(0xFF0F62FE),
                        };

                        return Marker(
                          point: pin.position,
                          width: 60,
                          height: 81,
                          alignment: Alignment.topCenter,
                          rotate: true,
                          child: pin.pinType == HomePinType.campaign
                              ? CampaignLocationPin(
                                  imageUrl: '',
                                  onTap: () => _openCampaignDetail(pin.userId),
                                )
                              : UserLocationPin(
                                  size: 60,
                                  imageUrl: pin.avatarUrl,
                                  color: color,
                                  isSosState: pin.isSos,
                                  roles: const [],
                                  onTap: () => viewModel.selectPin(pin.userId),
                                ),
                        );
                      })
                      .toList(growable: false),
                ),
              if (selectedBubble != null && selectedPin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPin.position,
                      width: bubbleWidth,
                      height: bubbleHeight,
                      alignment: Alignment.topCenter,
                      rotate: true,
                      child: Transform.translate(
                        offset: Offset(0, -bubbleLift),
                        child: PinActionBubble(
                          width: bubbleWidth,
                          height: bubbleHeight,
                          title: selectedBubble.title,
                          userId: selectedBubble.userId,
                          fullname: selectedBubble.fullname,
                          pinType: selectedBubble.pinType,
                          canHandle: selectedBubble.canHandle,
                          onHandle: selectedBubble.canHandle
                              ? () {
                                  viewModel.handleVictimDistress(
                                    selectedBubble.userId,
                                  );
                                  viewModel.selectPin(null);
                                }
                              : null,
                          onClose: () => viewModel.selectPin(null),
                        ),
                      ),
                    ),
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
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  onRescuerPressed: () {
                    _showBottomSheet(
                      'Broadcasting Signals',
                      BroadcastingSignalsSheet(
                        onLocateVictim: (victimUserId) async {
                          final focused = viewModel.focusOnVictim(victimUserId);
                          if (!focused) {
                            return false;
                          }
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          return true;
                        },
                      ),
                    );
                  },
                  onCharityPressed: () {
                    Navigator.push<ExistingCharityFocusRequest>( // Kỳ vọng khi màn hình đóng lại sẽ nhận được ExistingCharityFocusRequest
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExistingCharityScreen(),
                      ),
                    ).then((focusRequest) async { // pop(result) ==> result được đưa vào focusRequest và có kiểu dữ liệu ExistingCharityFocusRequest 
                      if (focusRequest == null || !mounted) {
                        return;
                      }

                      final focusedOnPin = await viewModel.focusOnCampaignLocation(
                        focusRequest.campaignId,
                        latitude: focusRequest.latitude,
                        longitude: focusRequest.longitude,
                      );

                      if (!focusedOnPin && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Focused on campaign location. Turn on campaign pins in Settings to highlight the pin.',
                            ),
                          ),
                        );
                      }
                    });
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
