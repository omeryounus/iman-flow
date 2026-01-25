import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityDua {
  final String id;
  final String text;
  final DateTime timestamp;
  final int prayerCount;
  final String category;
  final String senderId;
  final List<String> prayedBy;

  CommunityDua({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.prayerCount,
    required this.category,
    required this.senderId,
    this.prayedBy = const [],
  });

  factory CommunityDua.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityDua(
      id: doc.id,
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      prayerCount: data['prayerCount'] ?? 0,
      category: data['category'] ?? 'General',
      senderId: data['senderId'] ?? '',
      prayedBy: List<String>.from(data['prayedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'prayerCount': prayerCount,
      'category': category,
      'senderId': senderId,
      'prayedBy': prayedBy,
    };
  }
}

class CommunityDuaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _duaCollection => _firestore.collection('community_duas');

  Stream<List<CommunityDua>> getDuasStream() {
    return _duaCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => CommunityDua.fromFirestore(doc)).toList();
        });
  }

  Future<void> addDua(String text, String category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _duaCollection.add({
      'text': text,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
      'prayerCount': 0,
      'senderId': user.uid,
      'prayedBy': [],
    });
  }

  Future<void> prayForDua(String duaId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.runTransaction((transaction) async {
      final docRef = _duaCollection.doc(duaId);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final prayedBy = List<String>.from(data['prayedBy'] ?? []);
      
      if (!prayedBy.contains(user.uid)) {
        prayedBy.add(user.uid);
        transaction.update(docRef, {
          'prayedBy': prayedBy,
          'prayerCount': FieldValue.increment(1),
        });
      }
    });
  }
}
