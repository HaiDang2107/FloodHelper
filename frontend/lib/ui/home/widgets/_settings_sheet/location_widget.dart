import 'package:flutter/material.dart';

enum LocationVisibility { public, justFriends, noOne }

class LocationWidget extends StatefulWidget {
  final Function(LocationVisibility) onVisibilityChanged;

  const LocationWidget({super.key, required this.onVisibilityChanged});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  LocationVisibility _selectedVisibility = LocationVisibility.public;
  LocationVisibility _initialVisibility = LocationVisibility.public;
  bool get _hasChanges => _selectedVisibility != _initialVisibility;

  void _saveChanges() {
    setState(() {
      _initialVisibility = _selectedVisibility;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Location visibility saved!')));
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
            if (_hasChanges)
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        RadioListTile<LocationVisibility>(
          value: LocationVisibility.public,
          groupValue: _selectedVisibility,
          activeColor: const Color(0xFF0F62FE),
          onChanged: (value) {
            setState(() {
              _selectedVisibility = value!;
            });
            widget.onVisibilityChanged(value!);
          },
          title: const Text('Public', style: TextStyle(color: Colors.black87)),
          subtitle: const Text(
            'Everyone can see your location',
            style: TextStyle(color: Colors.black54),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<LocationVisibility>(
          value: LocationVisibility.justFriends,
          groupValue: _selectedVisibility,
          activeColor: const Color(0xFF0F62FE),
          onChanged: (value) {
            setState(() {
              _selectedVisibility = value!;
            });
            widget.onVisibilityChanged(value!);
          },
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
          groupValue: _selectedVisibility,
          activeColor: const Color(0xFF0F62FE),
          onChanged: (value) {
            setState(() {
              _selectedVisibility = value!;
            });
            widget.onVisibilityChanged(value!);
          },
          title: const Text('No One', style: TextStyle(color: Colors.black87)),
          subtitle: const Text(
            'Your location is hidden',
            style: TextStyle(color: Colors.black54),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
