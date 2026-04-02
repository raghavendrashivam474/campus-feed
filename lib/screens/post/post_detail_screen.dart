import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentService = CommentService();
  final _postService = PostService();
  bool _isSubmitting = false;
  String? _replyingToCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addReaction(String emoji) async {
    final error = await _postService.addReaction(widget.post.id, emoji);
    if (error != null && mounted) {
      Helpers.showSnackBar(context, error, isError: true);
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final error = Validators.validateComment(content);
    if (error != null) {
      Helpers.showSnackBar(context, error, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final submitError = await _commentService.addComment(
      postId: widget.post.id,
      content: content,
      parentCommentId: _replyingToCommentId,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _replyingToCommentId = null;
    });

    if (submitError != null) {
      Helpers.showSnackBar(context, submitError, isError: true);
    } else {
      _commentController.clear();
      Helpers.showSnackBar(context, 'Comment added! 💬');
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                // Post Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppConstants.getCategoryColor(widget.post.category),
                            child: const Text('?', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Anonymous',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  Helpers.formatTimestamp(widget.post.createdAt),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(widget.post.category),
                            backgroundColor: AppConstants.getCategoryColor(widget.post.category)
                                .withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Text(
                        widget.post.content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // Reactions
                      Wrap(
                        spacing: 8,
                        children: AppConstants.reactions.map((emoji) {
                          final count = widget.post.reactions[emoji] ?? 0;
                          return InkWell(
                            onTap: () => _addReaction(emoji),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 16)),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Text('$count'),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Comments Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Comments (${widget.post.commentCount})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Comments List
                StreamBuilder<List<Comment>>(
                  stream: _commentService.getPostComments(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyState(
                        icon: Icons.comment_outlined,
                        title: 'No Comments Yet',
                        message: 'Be the first to comment!',
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data![index];
                        return Column(
                          children: [
                            CommentTile(
                              comment: comment,
                              onReply: () {
                                setState(() {
                                  _replyingToCommentId = comment.id;
                                });
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                            ),
                            // Replies
                            StreamBuilder<List<Comment>>(
                              stream: _commentService.getCommentReplies(comment.id),
                              builder: (context, replySnapshot) {
                                if (!replySnapshot.hasData ||
                                    replySnapshot.data!.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: replySnapshot.data!.length,
                                  itemBuilder: (context, replyIndex) {
                                    return CommentTile(
                                      comment: replySnapshot.data![replyIndex],
                                      isReply: true,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingToCommentId != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.reply, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Replying to comment',
                            style: TextStyle(color: Colors.blue),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() => _replyingToCommentId = null);
                            },
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLength: AppConstants.maxCommentLength,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _submitComment,
                              color: Colors.deepPurple,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}