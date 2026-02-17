import 'package:flutter/material.dart';
import '../../core/common/models/post_model.dart';
import '../widgets/_post_content_screen/post_header.dart';
import '../widgets/_post_content_screen/post_actions.dart';
import '../widgets/_post_content_screen/comments_section.dart';
import '../widgets/_post_content_screen/comment_input.dart';

class PostContentScreen extends StatefulWidget {
  final PostModel post;

  const PostContentScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostContentScreen> createState() => _PostContentScreenState();
}

class _PostContentScreenState extends State<PostContentScreen> {
  late List<PostComment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.comments);
  }

  void _addComment(String content) {
    final newComment = PostComment(
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
            userName: widget.post.createdBy,
            avatarUrl: widget.post.createdByAvatar,
            createdAt: widget.post.createdAt,
          ),
          
          // Post Caption
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.post.caption,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          
          // Post Image
          Image.network(
            widget.post.imageUrl,
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
          PostActions(initialLikesCount: widget.post.likesCount),
          
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
