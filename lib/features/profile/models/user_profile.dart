import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? bio;
  final DateTime joinedAt;
  final int versesSharedCount;
  final int likesReceivedCount;

  UserProfile({
    required this.uid,
    this.displayName,
    this.bio,
    required this.joinedAt,
    this.versesSharedCount = 0,
    this.likesReceivedCount = 0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'],
      bio: data['bio'],
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      versesSharedCount: data['versesSharedCount'] ?? 0,
      likesReceivedCount: data['likesReceivedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'bio': bio,
      'joinedAt': joinedAt, // Usually not updated, but include for creation
      'versesSharedCount': versesSharedCount,
      'likesReceivedCount': likesReceivedCount,
    };
  }
  
  // Create a copyWith for optimistic updates
  UserProfile copyWith({
    String? displayName,
    String? bio,
    int? versesSharedCount,
    int? likesReceivedCount,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      joinedAt: joinedAt,
      versesSharedCount: versesSharedCount ?? this.versesSharedCount,
      likesReceivedCount: likesReceivedCount ?? this.likesReceivedCount,
    );
  }
}
