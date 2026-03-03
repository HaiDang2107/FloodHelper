import 'package:flutter/material.dart';
import '../../../../data/models/post_model.dart';
import '../../widgets/_post_content_screen/post_header.dart';
import '../../widgets/_post_content_screen/post_actions.dart';
import '../../widgets/_post_content_screen/comments_section.dart';
import '../../widgets/_post_content_screen/comment_input.dart';

class PostContentSheet extends StatefulWidget {
  final PostModel postModel;

  const PostContentSheet({
    super.key,
    required this.postModel,
  });

  @override
  State<PostContentSheet> createState() => _PostContentSheetState();
}

class _PostContentSheetState extends State<PostContentSheet> {
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.postModel.comments);
  }

  void _addComment(String content) {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user_current',
      userName: 'You',
      avatarUrl: 'https://i.pravatar.cc/150?img=99',
      content: content,
      createdAt: DateTime.now(),
    );
    setState(() {
      _comments.add(newComment);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (User info + time)
          PostHeader(
            userName: widget.postModel.createdBy,
            avatarUrl: widget.postModel.createdByAvatar,
            createdAt: widget.postModel.createdAt,
          ),
          
          // Post Caption
          if (widget.postModel.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.postModel.caption,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          
          // Post Image
          if (widget.postModel.imageUrl.isNotEmpty)
            Image.network(
              widget.postModel.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 8),
          
          // Post Actions (Like, Comment, Share)
          PostActions(initialLikesCount: widget.postModel.likesCount),
          
          const SizedBox(height: 8),
          
          // Comments Section
          CommentsSection(comments: _comments),
          
          const SizedBox(height: 16),
          
          // Comment Input
          CommentInput(
            onSubmit: _addComment,
          ),
        ],
      ),
    );
  }
}
