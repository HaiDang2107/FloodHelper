import 'package:flutter/material.dart';
import '../../widgets/_add_friend_sheet/add_friend_widget.dart';
import '../../widgets/_add_friend_sheet/pending_widget.dart';

class AddFriendSheet extends StatelessWidget {
  const AddFriendSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddFriendWidget(),
            SizedBox(height: 16),
            PendingWidget(),
          ],
        ),
      ),
    );
  }
}
