import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus { lost, found, claimed }

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final ItemStatus status;
  final String category; // e.g., "Phone", "Wallet", "Keys"
  final String? location; // Where it was lost/found
  final DateTime createdAt;
  final String userId; // Hidden - for contact purposes
  final String? imageUrl;
  final bool isClaimed;

  LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    this.location,
    required this.createdAt,
    required this.userId,
    this.imageUrl,
    this.isClaimed = false,
  });

  factory LostFoundItem.fromMap(Map<String, dynamic> map, String id) {
    return LostFoundItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: ItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ItemStatus.lost,
      ),
      category: map['category'] ?? '',
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'],
      isClaimed: map['isClaimed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'category': category,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'imageUrl': imageUrl,
      'isClaimed': isClaimed,
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? title,
    String? description,
    ItemStatus? status,
    String? category,
    String? location,
    DateTime? createdAt,
    String? userId,
    String? imageUrl,
    bool? isClaimed,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}