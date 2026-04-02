import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../utils/helpers.dart';
import '../services/comment_service.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;
  final bool isReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    this.isReply = false,
  });

  Future<void> _likeComment(BuildContext context) async {
    final service = CommentService();
    final error = await service.likeComment(comment.id);

    if (error != null && context.mounted) {
      Helpers.showSnackBar(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 40 : 0,
        top: 8,
        right: 0,
        bottom: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                radius: 16,
                child: const Text(
                  '?',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      Helpers.formatTimestamp(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 8),

          // Actions
          Row(
            children: [
              InkWell(
                onTap: () => _likeComment(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.likes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isReply && onReply != null) ...[
                const SizedBox(width: 16),
                InkWell(
                  onTap: onReply,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (comment.replyCount > 0) ...[
                const SizedBox(width: 16),
                Text(
                  '${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}