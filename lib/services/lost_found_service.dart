import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lost_found_item.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Report lost/found item
  Future<String?> reportItem({
    required String title,
    required String description,
    required ItemStatus status,
    required String category,
    String? location,
    String? imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final item = LostFoundItem(
        id: '',
        title: title.trim(),
        description: description.trim(),
        status: status,
        category: category,
        location: location?.trim(),
        createdAt: DateTime.now(),
        userId: user.uid,
        imageUrl: imageUrl,
      );

      await _firestore.collection('lost_found').add(item.toMap());

      return null; // Success
    } catch (e) {
      return 'Failed to report item: $e';
    }
  }

  // Get all items
  Stream<List<LostFoundItem>> getAllItems() {
    return _firestore
        .collection('lost_found')
        .where('isClaimed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get lost items
  Stream<List<LostFoundItem>> getLostItems() {
    return _firestore
        .collection('lost_found')
        .where('status', isEqualTo: ItemStatus.lost.name)
        .where('isClaimed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get found items
  Stream<List<LostFoundItem>> getFoundItems() {
    return _firestore
        .collection('lost_found')
        .where('status', isEqualTo: ItemStatus.found.name)
        .where('isClaimed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get items by category
  Stream<List<LostFoundItem>> getItemsByCategory(String category) {
    return _firestore
        .collection('lost_found')
        .where('category', isEqualTo: category)
        .where('isClaimed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Mark item as claimed
  Future<String?> markAsClaimed(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final doc = await _firestore.collection('lost_found').doc(itemId).get();
      if (!doc.exists) return 'Item not found';

      final item = LostFoundItem.fromMap(doc.data()!, doc.id);

      // Check if user owns the item
      if (item.userId != user.uid) {
        return 'You can only mark your own items as claimed';
      }

      await _firestore.collection('lost_found').doc(itemId).update({
        'isClaimed': true,
        'status': ItemStatus.claimed.name,
      });

      return null; // Success
    } catch (e) {
      return 'Failed to mark item as claimed: $e';
    }
  }

  // Delete item
  Future<String?> deleteItem(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not logged in';

      final doc = await _firestore.collection('lost_found').doc(itemId).get();
      if (!doc.exists) return 'Item not found';

      final item = LostFoundItem.fromMap(doc.data()!, doc.id);

      // Check if user owns the item
      if (item.userId != user.uid) {
        return 'You can only delete your own items';
      }

      await _firestore.collection('lost_found').doc(itemId).delete();

      return null; // Success
    } catch (e) {
      return 'Failed to delete item: $e';
    }
  }

  // Get single item
  Future<LostFoundItem?> getItem(String itemId) async {
    try {
      final doc = await _firestore.collection('lost_found').doc(itemId).get();
      if (!doc.exists) return null;
      return LostFoundItem.fromMap(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  // Search items
  Future<List<LostFoundItem>> searchItems(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final snapshot = await _firestore
          .collection('lost_found')
          .where('isClaimed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final allItems = snapshot.docs
          .map((doc) => LostFoundItem.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by query (simple contains search)
      final lowerQuery = query.toLowerCase();
      return allItems.where((item) {
        return item.title.toLowerCase().contains(lowerQuery) ||
            item.description.toLowerCase().contains(lowerQuery) ||
            item.category.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}