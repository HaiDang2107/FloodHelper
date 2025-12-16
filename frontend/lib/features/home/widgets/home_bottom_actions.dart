import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../screens/_search_friend_sheet.dart';
import '../screens/_messages_sheet.dart';

class HomeBottomActions extends StatelessWidget {
  final VoidCallback onTakePicture;
  final VoidCallback onGetCurrentLocation;
  final Function(String, Widget) onShowBottomSheet;
  final Function(LatLng) onLocateFriend;

  const HomeBottomActions({
    super.key,
    required this.onTakePicture,
    required this.onGetCurrentLocation,
    required this.onShowBottomSheet,
    required this.onLocateFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMapIcon(Icons.camera_alt, onTakePicture),
        _buildMapIcon(Icons.my_location, onGetCurrentLocation),
        _buildMapIcon(Icons.person_search, () => onShowBottomSheet('Search Friend', SearchFriendSheet(onLocateFriend: onLocateFriend))),
        _buildMapIcon(Icons.message, () => onShowBottomSheet('Messages', const MessagesSheet())),
      ],
    );
  }

  Widget _buildMapIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF0F62FE)),
        onPressed: onPressed,
      ),
    );
  }
}
