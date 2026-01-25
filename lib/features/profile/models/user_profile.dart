import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? bio;
  final DateTime joinedAt;
  final int versesSharedCount;
  final int likesReceivedCount;
  final int prayerStreak;
  final int quranStreak;
  final int dhikrStreak;
  final DateTime? lastActiveDate;

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.bio,
    required this.joinedAt,
    this.versesSharedCount = 0,
    this.likesReceivedCount = 0,
    this.prayerStreak = 0,
    this.quranStreak = 0,
    this.dhikrStreak = 0,
    this.lastActiveDate,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'],
      email: data['email'],
      photoURL: data['photoURL'],
      bio: data['bio'],
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      versesSharedCount: data['versesSharedCount'] ?? 0,
      likesReceivedCount: data['likesReceivedCount'] ?? 0,
      prayerStreak: data['prayerStreak'] ?? 0,
      quranStreak: data['quranStreak'] ?? 0,
      dhikrStreak: data['dhikrStreak'] ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'bio': bio,
      'joinedAt': joinedAt, // Usually not updated, but include for creation
      'versesSharedCount': versesSharedCount,
      'likesReceivedCount': likesReceivedCount,
      'prayerStreak': prayerStreak,
      'quranStreak': quranStreak,
      'dhikrStreak': dhikrStreak,
      'lastActiveDate': lastActiveDate,
    };
  }
  
  // Create a copyWith for optimistic updates
  UserProfile copyWith({
    String? displayName,
    String? email,
    String? photoURL,
    String? bio,
    int? versesSharedCount,
    int? likesReceivedCount,
    int? prayerStreak,
    int? quranStreak,
    int? dhikrStreak,
    DateTime? lastActiveDate,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      joinedAt: joinedAt,
      versesSharedCount: versesSharedCount ?? this.versesSharedCount,
      likesReceivedCount: likesReceivedCount ?? this.likesReceivedCount,
      prayerStreak: prayerStreak ?? this.prayerStreak,
      quranStreak: quranStreak ?? this.quranStreak,
      dhikrStreak: dhikrStreak ?? this.dhikrStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
