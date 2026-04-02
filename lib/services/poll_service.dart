import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';

class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create poll
  Future<String?> createPoll({
    required String question,
    required List<String> options,
    DateTime? expiresAt,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      if (options.length < 2) {
        return 'Poll must have at least 2 options';
      }

      final pollOptions = options
          .map((text) => PollOption(text: text))
          .toList();

      final poll = Poll(
        id: '',
        question: question,
        options: pollOptions,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        createdBy: user.uid,
      );

      await _firestore.collection('polls').add(poll.toMap());

      return null; // Success
    } catch (e) {
      return 'Failed to create poll: $e';
    }
  }

  // Get active polls
  Stream<List<Poll>> getActivePolls() {
    return _firestore
        .collection('polls')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Poll.fromMap(doc.data(), doc.id))
          .where((poll) => !poll.isExpired)
          .toList();
    });
  }

  // Vote on poll
  Future<String?> vote(String pollId, int optionIndex) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      // Check if user already voted
      final voteDoc = await _firestore
          .collection('poll_votes')
          .where('pollId', isEqualTo: pollId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (voteDoc.docs.isNotEmpty) {
        return 'You have already voted on this poll';
      }

      // Record vote
      await _firestore.collection('poll_votes').add({
        'pollId': pollId,
        'userId': user.uid,
        'optionIndex': optionIndex,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment vote count
      await _firestore.collection('polls').doc(pollId).update({
        'options.$optionIndex.votes': FieldValue.increment(1),
        'totalVotes': FieldValue.increment(1),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to vote: $e';
    }
  }

  // Check if user voted
  Future<bool> hasUserVoted(String pollId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final voteDoc = await _firestore
          .collection('poll_votes')
          .where('pollId', isEqualTo: pollId)
          .where('userId', isEqualTo: user.uid)
          .get();

      return voteDoc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get single poll
  Future<Poll?> getPoll(String pollId) async {
    try {
      final doc = await _firestore.collection('polls').doc(pollId).get();
      if (!doc.exists) return null;
      return Poll.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }
}