import 'package:flutter/material.dart';

enum LocationVisibility { public, justFriends, noOne }

class LocationWidget extends StatefulWidget {
  final Function(LocationVisibility) onVisibilityChanged;
  final LocationVisibility initialVisibility;

  const LocationWidget({
    super.key,
    required this.onVisibilityChanged,
    this.initialVisibility = LocationVisibility.justFriends,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  late LocationVisibility _selectedVisibility;

  @override
  void initState() {
    super.initState();
    _selectedVisibility = widget.initialVisibility;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Location Visibility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RadioGroup<LocationVisibility>(
          groupValue: _selectedVisibility,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedVisibility = value);
            widget.onVisibilityChanged(value);
          },
          child: Column(
            children: [
              RadioListTile<LocationVisibility>(
                value: LocationVisibility.public,
                activeColor: const Color(0xFF0F62FE),
                title: const Text('Public', style: TextStyle(color: Colors.black87)),
                subtitle: const Text(
                  'Everyone can see your location',
                  style: TextStyle(color: Colors.black54),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<LocationVisibility>(
                value: LocationVisibility.justFriends,
                activeColor: const Color(0xFF0F62FE),
                title: const Text(
                  'Just Friends',
                  style: TextStyle(color: Colors.black87),
                ),
                subtitle: const Text(
                  'Only selected friends can see',
                  style: TextStyle(color: Colors.black54),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<LocationVisibility>(
                value: LocationVisibility.noOne,
                activeColor: const Color(0xFF0F62FE),
                title: const Text('No One', style: TextStyle(color: Colors.black87)),
                subtitle: const Text(
                  'Your location is hidden',
                  style: TextStyle(color: Colors.black54),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
