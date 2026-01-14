import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  Stream<UserProfile?> get currentUserProfileStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(null);
      }
      return _usersCollection
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
    });
  }

  Future<void> createOrUpdateProfile({String? displayName, String? bio}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _usersCollection.doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // Create new
      final profile = UserProfile(
        uid: user.uid,
        displayName: displayName ?? user.displayName ?? 'User',
        bio: bio ?? '',
        joinedAt: DateTime.now(),
      );
      await docRef.set(profile.toMap());
    } else {
      // Update existing
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      
      if (updates.isNotEmpty) {
        await docRef.update(updates);
      }
    }
  }

  Future<void> incrementVersesShared() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _usersCollection.doc(user.uid).update({
      'versesSharedCount': FieldValue.increment(1),
    });
  }
}

extension StreamSwitchMap<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R> Function(T event) mapper) {
    return asyncMap(mapper).asyncExpand((stream) => stream);
  }
}
