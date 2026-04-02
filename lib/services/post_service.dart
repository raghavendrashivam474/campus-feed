import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../utils/constants.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new post
  Future<String?> createPost({
    required String content,
    required String category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      // Check daily post limit
      final canPost = await _canUserPost(user.uid);
      if (!canPost) {
        return 'You have reached the daily post limit (${AppConstants.maxPostsPerDay} posts)';
      }

      final post = Post(
        id: '',
        content: content.trim(),
        userId: user.uid,
        category: category,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('posts').add(post.toMap());

      // Update user post count
      await _firestore.collection('users').doc(user.uid).update({
        'postCount': FieldValue.increment(1),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to create post: $e';
    }
  }

  // Check if user can post (rate limiting)
  Future<bool> _canUserPost(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();

      return snapshot.docs.length < AppConstants.maxPostsPerDay;
    } catch (e) {
      return true; // Allow posting if check fails
    }
  }

  // Get latest posts (paginated)
  Stream<List<Post>> getLatestPosts({int limit = 15}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get trending posts
  Stream<List<Post>> getTrendingPosts() {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore
        .collection('posts')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .where((post) => post.shouldBeTrending())
          .toList();

      // Sort by trending score
      posts.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));

      return posts.take(20).toList();
    });
  }

  // Get posts by category
  Stream<List<Post>> getPostsByCategory(String category) {
    return _firestore
        .collection('posts')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add reaction to post
  Future<String?> addReaction(String postId, String emoji) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'reactions.$emoji': FieldValue.increment(1),
      });

      // Update trending score
      await _updateTrendingScore(postId);

      return null; // Success
    } catch (e) {
      return 'Failed to add reaction: $e';
    }
  }

  // Update trending score
  Future<void> _updateTrendingScore(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return;

      final post = Post.fromMap(doc.data()!, doc.id);
      final newScore = post.calculateTrendingScore();

      await _firestore.collection('posts').doc(postId).update({
        'trendingScore': newScore,
        'isTrending': post.shouldBeTrending(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Delete post (user can only delete their own)
  Future<String?> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return 'Post not found';

      final post = Post.fromMap(doc.data()!, doc.id);

      // Check if user owns the post
      if (post.userId != user.uid) {
        return 'You can only delete your own posts';
      }

      // Delete the post
      await _firestore.collection('posts').doc(postId).delete();

      // Delete all comments on the post
      final comments = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();

      for (var comment in comments.docs) {
        await comment.reference.delete();
      }

      // Update user post count
      await _firestore.collection('users').doc(user.uid).update({
        'postCount': FieldValue.increment(-1),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to delete post: $e';
    }
  }

  // Report post
  Future<String?> reportPost(String postId, String reason) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      await _firestore.collection('reports').add({
        'postId': postId,
        'reportedBy': user.uid,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return null; // Success
    } catch (e) {
      return 'Failed to report post: $e';
    }
  }

  // Get single post
  Future<Post?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return Post.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }
}