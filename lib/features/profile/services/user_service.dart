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

  Future<void> createOrUpdateProfile({
    String? displayName,
    String? email,
    String? photoURL,
    String? bio,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('UserService: Cannot create profile, no user logged in');
        return;
      }

      print('UserService: Syncing profile for ${user.uid}...');
      final docRef = _usersCollection.doc(user.uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        print('UserService: Creating new profile in Firestore...');
        final profile = UserProfile(
          uid: user.uid,
          displayName: displayName ?? user.displayName ?? (user.isAnonymous ? 'Guest User' : 'User'),
          email: email ?? user.email,
          photoURL: photoURL ?? user.photoURL,
          bio: bio ?? '',
          joinedAt: DateTime.now(),
        );
        await docRef.set(profile.toMap());
        print('UserService: New profile created successfully');
      } else {
        print('UserService: Updating existing profile...');
        final updates = <String, dynamic>{};
        if (displayName != null) updates['displayName'] = displayName;
        if (email != null) updates['email'] = email;
        if (photoURL != null) updates['photoURL'] = photoURL;
        if (bio != null) updates['bio'] = bio;
        
        if (updates.isNotEmpty) {
          await docRef.update(updates);
          print('UserService: Profile updated successfully');
        }
      }
    } catch (e) {
      print('UserService: CRUD Error: $e');
    }
  }

  Future<void> syncPushNotificationData({
    String? fcmToken,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{
        'lastActiveDate': DateTime.now(),
      };
      
      if (fcmToken != null) updates['fcmToken'] = fcmToken;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      await _usersCollection.doc(user.uid).set(updates, SetOptions(merge: true));
      print('UserService: Push notification data synced for ${user.uid}');
    } catch (e) {
      print('UserService: Sync Error: $e');
    }
  }

  Future<void> incrementVersesShared() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _usersCollection.doc(user.uid).update({
      'versesSharedCount': FieldValue.increment(1),
    });
  }
  Future<void> updateStreaks({
    required int prayerStreak,
    required int quranStreak,
    required int dhikrStreak,
    DateTime? lastActiveDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = {
      'prayerStreak': prayerStreak,
      'quranStreak': quranStreak,
      'dhikrStreak': dhikrStreak,
      'lastActiveDate': lastActiveDate ?? DateTime.now(),
    };

    await _usersCollection.doc(user.uid).update(updates).catchError((e) {
      // Fire and forget, or log error
      print('Error syncing streaks: $e');
    });
  }
}

extension StreamSwitchMap<T> on Stream<T> {
  Stream<R> switchMap<R>(Stream<R> Function(T event) mapper) {
    return asyncMap(mapper).asyncExpand((stream) => stream);
  }
}
