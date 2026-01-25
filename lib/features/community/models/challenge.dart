import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int participantCount;
  final bool isWomenOnly;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.participantCount = 0,
    this.isWomenOnly = false,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🌙',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalDays: data['totalDays'] ?? 30,
      participantCount: data['participantCount'] ?? 0,
      isWomenOnly: data['isWomenOnly'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalDays': totalDays,
      'participantCount': participantCount,
      'isWomenOnly': isWomenOnly,
    };
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
