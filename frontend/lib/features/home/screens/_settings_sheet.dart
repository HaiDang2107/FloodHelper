import 'package:flutter/material.dart';
import '../widgets/_settings_sheet/display_widget.dart';
import '../widgets/_settings_sheet/location_widget.dart';
import '../widgets/_settings_sheet/modification_widget.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

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
            const DisplayWidget(),
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
