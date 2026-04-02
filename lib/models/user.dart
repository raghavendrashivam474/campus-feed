import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String? profilePicUrl;
  final DateTime createdAt;
  final bool isAdmin;
  final int postCount;
  final int commentCount;
  final bool isVerified;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicUrl,
    required this.createdAt,
    this.isAdmin = false,
    this.postCount = 0,
    this.commentCount = 0,
    this.isVerified = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePicUrl: map['profilePicUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isAdmin: map['isAdmin'] ?? false,
      postCount: map['postCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
      'postCount': postCount,
      'commentCount': commentCount,
      'isVerified': isVerified,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    String? profilePicUrl,
    DateTime? createdAt,
    bool? isAdmin,
    int? postCount,
    int? commentCount,
    bool? isVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}