import 'package:flutter/material.dart';
import '../widgets/_settings_sheet/display_widget.dart';
import '../widgets/_settings_sheet/location_widget.dart';
import '../widgets/_settings_sheet/modification_widget.dart';

class SettingsSheet extends StatefulWidget {
  final bool showStrangerLocation;
  final bool showPostLocation;
  final Function(bool) onShowStrangerLocationChanged;
  final Function(bool) onShowPostLocationChanged;

  const SettingsSheet({
    super.key,
    required this.showStrangerLocation,
    required this.showPostLocation,
    required this.onShowStrangerLocationChanged,
    required this.onShowPostLocationChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  LocationVisibility _locationVisibility = LocationVisibility.public;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DisplayWidget(
              showStrangerLocation: widget.showStrangerLocation,
              showPostLocation: widget.showPostLocation,
              onShowStrangerLocationChanged: widget.onShowStrangerLocationChanged,
              onShowPostLocationChanged: widget.onShowPostLocationChanged,
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
                    onVisibilityChanged: (visibility) {
                      setState(() {
                        _locationVisibility = visibility;
                      });
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
