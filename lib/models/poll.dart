import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String createdBy; // userId
  final int totalVotes;
  final bool isActive;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    this.expiresAt,
    required this.createdBy,
    this.totalVotes = 0,
    this.isActive = true,
  });

  // Check if poll has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory Poll.fromMap(Map<String, dynamic> map, String id) {
    return Poll(
      id: id,
      question: map['question'] ?? '',
      options: (map['options'] as List<dynamic>)
          .map((opt) => PollOption.fromMap(opt as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      createdBy: map['createdBy'] ?? '',
      totalVotes: map['totalVotes'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options.map((opt) => opt.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'createdBy': createdBy,
      'totalVotes': totalVotes,
      'isActive': isActive,
    };
  }
}

class PollOption {
  final String text;
  final int votes;

  PollOption({
    required this.text,
    this.votes = 0,
  });

  // Calculate percentage
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (votes / totalVotes) * 100;
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      text: map['text'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'votes': votes,
    };
  }

  PollOption copyWith({
    String? text,
    int? votes,
  }) {
    return PollOption(
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}