import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antiflood/ui/home/widgets/_search_friend_sheet/friend_search_item.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/models/user_model.dart';
import '../../../core/common/services/global_notification_controller.dart';
import '../../view_models/home_view_model.dart';

class SearchFriendSheet extends ConsumerWidget {
  final Function(LatLng) onLocateFriend;

  const SearchFriendSheet({
    super.key,
    required this.onLocateFriend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    // Convert FriendModel to UserModel for UI compatibility
    final friends = state.friendsWithMapMode.map((f) {
      final locationUpdate = state.friendLocations[f.userId];
      final isOnline = locationUpdate?.isOnline;
      
      return UserModel(
        id: f.userId,
        name: f.name,
        displayName: f.displayName,
        avatarUrl: f.avatarUrl ?? '',
        status: isOnline == true 
            ? 'online' 
            : (isOnline == false ? 'offline' : 'unknown'),
        latitude: locationUpdate?.latitude ?? 0,
        longitude: locationUpdate?.longitude ?? 0,
        isFriend: true,
        roles: f.roles,
      );
    }).toList();
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[200],
        indent: 76,
      ),
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendSearchItem(
          user: friend,
          onLocateTap: () {
            if (friend.latitude == 0 && friend.longitude == 0) {
              ref.read(globalNotificationControllerProvider).showNotification(
                'Cannot locate ${friend.name}: No location data received yet.',
                backgroundColor: Colors.red,
              );
              return;
            }
            Navigator.pop(context);
            onLocateFriend(friend.location);
          },
        );
      },
    );
  }
}
