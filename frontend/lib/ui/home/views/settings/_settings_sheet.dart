import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/_settings_sheet/display_widget.dart';
import '../../widgets/_settings_sheet/location_widget.dart';
import '../../widgets/_settings_sheet/modification_widget.dart';
import '../../view_models/home_view_model.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({
    super.key,
  });

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late LocationVisibility _locationVisibility;

  @override
  void initState() {
    super.initState();
    final visibilityStr = ref.read(homeViewModelProvider).locationVisibility;
    _locationVisibility = _fromString(visibilityStr);
  }

  LocationVisibility _fromString(String value) {
    switch (value) {
      case 'PUBLIC':
        return LocationVisibility.public;
      case 'NO_ONE':
        return LocationVisibility.noOne;
      default:
        return LocationVisibility.justFriends;
    }
  }

  String _toString(LocationVisibility v) {
    switch (v) {
      case LocationVisibility.public:
        return 'PUBLIC';
      case LocationVisibility.noOne:
        return 'NO_ONE';
      case LocationVisibility.justFriends:
        return 'JUST_FRIEND';
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DisplayWidget(
              showStrangerLocation: homeState.showStrangerLocation,
              showPostLocation: homeState.showPostLocation,
              onShowStrangerLocationChanged: viewModel.setShowStrangerLocation,
              onShowPostLocationChanged: viewModel.setShowPostLocation,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocationWidget(
                    initialVisibility: _locationVisibility,
                    onVisibilityChanged: (visibility) {
                      setState(() {
                        _locationVisibility = visibility;
                      });
                      // Persist to backend
                      viewModel.updateLocationVisibility(_toString(visibility));
                    },
                  ),
                  if (_locationVisibility == LocationVisibility.justFriends) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const ModificationWidget(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
