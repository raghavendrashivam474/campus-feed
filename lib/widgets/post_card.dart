import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/post_service.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool showTrendingBadge;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.showTrendingBadge = false,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isReacting = false;

  Future<void> _addReaction(String emoji) async {
    if (_isReacting) return;
    
    setState(() => _isReacting = true);
    
    final service = PostService();
    final error = await service.addReaction(widget.post.id, emoji);

    if (mounted) {
      setState(() => _isReacting = false);
      
      if (error != null) {
        Helpers.showSnackBar(context, error, isError: true);
      }
    }
  }

  String _getCuriosityPrefix() {
    switch (widget.post.category) {
      case '💭 Confession':
        return '👀';
      case '😂 Funny':
        return '😆';
      case '😤 Rant':
        return '💢';
      case '📢 Lost & Found':
        return '🔍';
      case '🎉 Events':
        return '🎊';
      default:
        return '💬';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppConstants.textMuted.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppConstants.primaryPurple.withValues(alpha: 0.05),
          highlightColor: AppConstants.primaryPurple.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppConstants.getCategoryColor(widget.post.category)
                            .withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConstants.getCategoryColor(widget.post.category)
                              .withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getCuriosityPrefix(),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Anonymous',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppConstants.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (widget.showTrendingBadge) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppConstants.trendingMedium,
                                        AppConstants.trendingDark,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstants.trendingMedium
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Hot',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppConstants.textLight,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                Helpers.formatTimestamp(widget.post.createdAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppConstants.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.getCategoryColor(widget.post.category)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.post.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.getCategoryColor(widget.post.category),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ CONTENT - BIGGER & DARKER (Final Polish)
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    fontSize: 18,                   // BIGGER (was 17)
                    height: 1.65,
                    color: Color(0xFF12141A),       // DARKER (was #1A1D26)
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05,
                  ),
                ),
                const SizedBox(height: 22),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.textMuted.withValues(alpha: 0.05),
                        AppConstants.textMuted.withValues(alpha: 0.15),
                        AppConstants.textMuted.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ✅ REACTIONS - MORE SPACING & BETTER CLICKABILITY
                Wrap(
                  spacing: 12,      // INCREASED (was 10)
                  runSpacing: 12,   // INCREASED (was 10)
                  children: AppConstants.reactions.map((emoji) {
                    final count = widget.post.reactions[emoji] ?? 0;
                    final reactionColor = AppConstants.getReactionColor(emoji);
                    final isActive = count > 0;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isReacting ? null : () => _addReaction(emoji),
                          borderRadius: BorderRadius.circular(28),
                          splashColor: reactionColor.withValues(alpha: 0.25),
                          highlightColor: reactionColor.withValues(alpha: 0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              // ✅ SOFT BACKGROUND - More clickable feel
                              color: isActive
                                  ? reactionColor.withValues(alpha: 0.18)  // SOFTER
                                  : AppConstants.backgroundColor,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isActive
                                    ? reactionColor.withValues(alpha: 0.45)
                                    : AppConstants.textMuted.withValues(alpha: 0.25),
                                width: isActive ? 2 : 1.5,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: reactionColor.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 7),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: reactionColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Activity Stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.textMuted.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.whatshot_rounded,
                        size: 17,
                        color: AppConstants.trendingMedium,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.totalEngagement}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'interactions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 17,
                        color: AppConstants.primaryPurple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.commentCount}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.commentCount == 1 ? 'comment' : 'comments',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}