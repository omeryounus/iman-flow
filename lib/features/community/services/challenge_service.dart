import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _challengesCollection => _firestore.collection('challenges');

  /// Get stream of active challenges
  Stream<List<Challenge>> getActiveChallenges({bool womenOnly = false}) {
    final now = DateTime.now();
    Query query = _challengesCollection
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endDate');

    if (womenOnly) {
      query = query.where('isWomenOnly', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    });
  }

  /// Join a challenge (increments participant count)
  Future<void> joinChallenge(String challengeId) async {
    await _challengesCollection.doc(challengeId).update({
      'participantCount': FieldValue.increment(1),
    });
    
    // Note: In a full implementation, we would also add the challenge ID 
    // to the user's "joinedChallenges" list in their profile.
  }
}
