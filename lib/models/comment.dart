import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String? parentCommentId; // For nested replies
  final String userId; // Hidden - for moderation only
  final String content;
  final DateTime createdAt;
  final int likes;
  final int replyCount;

  Comment({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.replyCount = 0,
  });

  // Check if this is a reply
  bool get isReply => parentCommentId != null;

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      parentCommentId: map['parentCommentId'],
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      replyCount: map['replyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'parentCommentId': parentCommentId,
      'userId': userId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'replyCount': replyCount,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? parentCommentId,
    String? userId,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? replyCount,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}