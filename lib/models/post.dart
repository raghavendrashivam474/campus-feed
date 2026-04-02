import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String content;
  final String userId; // Hidden - for moderation only
  final String category;
  final DateTime createdAt;
  final Map<String, int> reactions; // {'😂': 5, '👍': 3}
  final int commentCount;
  final bool isPinned;
  final bool isTrending;
  final double trendingScore;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    required this.category,
    required this.createdAt,
    this.reactions = const {},
    this.commentCount = 0,
    this.isPinned = false,
    this.isTrending = false,
    this.trendingScore = 0,
  });

  // Calculate trending score
  double calculateTrendingScore() {
    final hoursSincePost = DateTime.now().difference(createdAt).inHours + 1;
    final totalReactions = reactions.values.fold(0, (a, b) => a + b);
    return (totalReactions + commentCount * 2) / hoursSincePost;
  }

  // Check if should be trending
  bool shouldBeTrending() {
    final totalEngagement = reactions.values.fold(0, (a, b) => a + b) + commentCount;
    final isRecent = DateTime.now().difference(createdAt).inHours <= 24;
    return totalEngagement >= 10 && isRecent;
  }

  // Get total engagement
  int get totalEngagement {
    return reactions.values.fold(0, (a, b) => a + b) + commentCount;
  }

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '💬 General',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      commentCount: map['commentCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      isTrending: map['isTrending'] ?? false,
      trendingScore: (map['trendingScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'userId': userId,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactions': reactions,
      'commentCount': commentCount,
      'isPinned': isPinned,
      'isTrending': isTrending,
      'trendingScore': calculateTrendingScore(),
    };
  }

  Post copyWith({
    String? id,
    String? content,
    String? userId,
    String? category,
    DateTime? createdAt,
    Map<String, int>? reactions,
    int? commentCount,
    bool? isPinned,
    bool? isTrending,
    double? trendingScore,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      isTrending: isTrending ?? this.isTrending,
      trendingScore: trendingScore ?? this.trendingScore,
    );
  }
}