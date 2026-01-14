import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shared_verse.dart';

class VerseShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _versesCollection =>
      _firestore.collection('community_shared_verses');

  // get verses stream
  Stream<List<SharedVerse>> getSharedVerses({bool womenMode = false}) {
    Query query = _versesCollection.orderBy('timestamp', descending: true).limit(50);

    if (womenMode) {
      query = query.where('womenOnly', isEqualTo: true);
    } 
    // Note: If womenMode is false, we might want to show ALL verses or just general ones.
    // For now, let's assume general mode shows everything including women-specific, 
    // OR we can filter out women-only. Let's show everything for now unless specific requirement.
    // If strict separation needed: query = query.where('womenOnly', isEqualTo: false);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SharedVerse.fromFirestore(doc)).toList();
    });
  }

  Future<void> shareVerse({
    required String verseKey,
    required String arabicText,
    required String translation,
    String? reflection,
    bool womenOnly = false,
  }) async {
    final user = _auth.currentUser;
    // Allow anonymous posting if not logged in? Or valid user only.
    // Assuming valid user or anonymous placeholder
    
    String senderName = 'Anonymous';
    String senderId = user?.uid ?? 'anon_${DateTime.now().millisecondsSinceEpoch}';

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        senderName = user.displayName!;
      } else if (user.email != null) {
        senderName = user.email!.split('@')[0];
      }
    }

    await _versesCollection.add({
      'verseKey': verseKey,
      'arabicText': arabicText,
      'translation': translation,
      'sharedBy': senderName,
      'senderId': senderId,
      'shareCount': 0,
      'likeCount': 0,
      'likedBy': [],
      'reflection': reflection,
      'timestamp': FieldValue.serverTimestamp(),
      'womenOnly': womenOnly,
    });
  }

  Future<void> toggleLike(String verseId) async {
    final user = _auth.currentUser;
    // For anonymous users, we might just store locally or simple +1 without user tracking
    // For MVP, if user is not logged in, we do nothing or just show a snackbar in UI
    if (user == null) return;

    final userId = user.uid;
    final docRef = _versesCollection.doc(verseId);

    // Run transaction to toggle like
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      int likeCount = data['likeCount'] ?? 0;

      if (likedBy.contains(userId)) {
        // Unlike
        likedBy.remove(userId);
        likeCount = (likeCount > 0) ? likeCount - 1 : 0;
      } else {
        // Like
        likedBy.add(userId);
        likeCount++;
      }

      transaction.update(docRef, {
        'likeCount': likeCount,
        'likedBy': likedBy,
      });

      // TODO: Update User Stats (can be done via Cloud Functions or another transaction)
    });
  }

  Future<void> incrementShare(String verseId) async {
    await _versesCollection.doc(verseId).update({
      'shareCount': FieldValue.increment(1),
    });
  }
}
