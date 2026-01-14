import 'package:cloud_firestore/cloud_firestore.dart';

class SharedVerse {
  final String id;
  final String verseKey;
  final String arabicText;
  final String translation;
  final String sharedBy;
  final String senderId; // To identify own posts
  final int likeCount;
  final List<String> likedBy; // List of user IDs who liked this verse
  final int shareCount;
  final String? reflection;
  final DateTime timestamp;
  final bool womenOnly; // Use this for "Women Mode" filtering

  SharedVerse({
    required this.id,
    required this.verseKey,
    required this.arabicText,
    required this.translation,
    required this.sharedBy,
    required this.senderId,
    this.shareCount = 0,
    this.likeCount = 0,
    this.likedBy = const [],
    this.reflection,
    required this.timestamp,
    this.womenOnly = false,
  });

  factory SharedVerse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedVerse(
      id: doc.id,
      verseKey: data['verseKey'] ?? '',
      arabicText: data['arabicText'] ?? '',
      translation: data['translation'] ?? '',
      sharedBy: data['sharedBy'] ?? 'Anonymous',
      senderId: data['senderId'] ?? '',
      shareCount: data['shareCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      reflection: data['reflection'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      womenOnly: data['womenOnly'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verseKey': verseKey,
      'arabicText': arabicText,
      'translation': translation,
      'sharedBy': sharedBy,
      'senderId': senderId,
      'shareCount': shareCount,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'reflection': reflection,
      'timestamp': FieldValue.serverTimestamp(),
      'womenOnly': womenOnly,
    };
  }
}
