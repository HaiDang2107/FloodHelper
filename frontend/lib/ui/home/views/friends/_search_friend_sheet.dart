import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antiflood/ui/home/widgets/_search_friend_sheet/friend_search_item.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/models/user_model.dart';
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
    final friends = state.friendsWithMapMode.map((f) => UserModel(
      id: f.userId,
      name: f.name,
      displayName: f.displayName,
      avatarUrl: f.avatarUrl ?? '',
      status: 'online', 
      latitude: 0, // Location will be from state.friendLocations if available
      longitude: 0,
      isFriend: true,
    )).toList();
    
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
            Navigator.pop(context);
            onLocateFriend(friend.location);
          },
        );
      },
    );
  }
}
