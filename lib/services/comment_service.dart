import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add comment
  Future<String?> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final comment = Comment(
        id: '',
        postId: postId,
        parentCommentId: parentCommentId,
        userId: user.uid,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore.collection('comments').add(comment.toMap());

      // Increment post comment count
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      // If this is a reply, increment parent comment reply count
      if (parentCommentId != null) {
        await _firestore.collection('comments').doc(parentCommentId).update({
          'replyCount': FieldValue.increment(1),
        });
      }

      // Update user comment count
      await _firestore.collection('users').doc(user.uid).update({
        'commentCount': FieldValue.increment(1),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to add comment: $e';
    }
  }

  // Get comments for a post (top-level only) - FIXED
  Stream<List<Comment>> getPostComments(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) {
      // Filter top-level comments (no parent) and sort in Dart
      final comments = snapshot.docs
          .map((doc) => Comment.fromMap(doc.data(), doc.id))
          .where((comment) => comment.parentCommentId == null)
          .toList();
      
      // Sort by createdAt (oldest first)
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return comments;
    });
  }

  // Get replies to a comment - FIXED
  Stream<List<Comment>> getCommentReplies(String commentId) {
    return _firestore
        .collection('comments')
        .where('parentCommentId', isEqualTo: commentId)
        .snapshots()
        .map((snapshot) {
      final replies = snapshot.docs
          .map((doc) => Comment.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by createdAt (oldest first)
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return replies;
    });
  }

  // Like comment
  Future<String?> likeComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'likes': FieldValue.increment(1),
      });
      return null; // Success
    } catch (e) {
      return 'Failed to like comment: $e';
    }
  }

  // Delete comment
  Future<String?> deleteComment(String commentId, String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final doc = await _firestore.collection('comments').doc(commentId).get();
      if (!doc.exists) return 'Comment not found';

      final comment = Comment.fromMap(doc.data()!, doc.id);

      // Check if user owns the comment
      if (comment.userId != user.uid) {
        return 'You can only delete your own comments';
      }

      // Delete the comment
      await _firestore.collection('comments').doc(commentId).delete();

      // Decrement post comment count
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });

      // If this is a reply, decrement parent comment reply count
      if (comment.parentCommentId != null) {
        await _firestore
            .collection('comments')
            .doc(comment.parentCommentId!)
            .update({
          'replyCount': FieldValue.increment(-1),
        });
      }

      // Delete all replies to this comment
      final replies = await _firestore
          .collection('comments')
          .where('parentCommentId', isEqualTo: commentId)
          .get();

      for (var reply in replies.docs) {
        await reply.reference.delete();
      }

      return null; // Success
    } catch (e) {
      return 'Failed to delete comment: $e';
    }
  }
}