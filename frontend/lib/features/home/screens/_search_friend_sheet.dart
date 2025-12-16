import 'package:flutter/material.dart';
import 'package:antiflood/common/models/friend_model.dart';
import 'package:antiflood/features/home/widgets/_search_friend_sheet/friend_search_item.dart';
import 'package:latlong2/latlong.dart';

class SearchFriendSheet extends StatelessWidget {
  final Function(LatLng) onLocateFriend;

  const SearchFriendSheet({
    super.key,
    required this.onLocateFriend,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockFriends.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[200],
        indent: 76,
      ),
      itemBuilder: (context, index) {
        final friend = mockFriends[index];
        return FriendSearchItem(
          friend: friend,
          onLocateTap: () {
            Navigator.pop(context);
            onLocateFriend(friend.location);
          },
        );
      },
    );
  }
}
