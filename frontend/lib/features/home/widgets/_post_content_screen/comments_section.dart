import 'package:flutter/material.dart';
import '../../../../common/models/post_model.dart';
import 'comment_item.dart';

class CommentsSection extends StatelessWidget {
  final List<PostComment> comments;

  const CommentsSection({
    super.key,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No comments yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...comments.map((comment) => CommentItem(comment: comment)),
      ],
    );
  }
}
