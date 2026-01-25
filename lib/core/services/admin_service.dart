import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dua_audio.dart';
import '../../features/community/models/challenge.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _dailyContentCollection => _firestore.collection('daily_content');
  CollectionReference get _audioCollection => _firestore.collection('audio_content');
  CollectionReference get _challengesCollection => _firestore.collection('challenges');

  /// Set the daily verse for a specific date (YYYY-MM-DD)
  Future<void> setDailyVerse({
    required String dateId,
    required String verseKey,
    required String textArabic,
    required String translation,
    String? topic,
  }) async {
    await _dailyContentCollection.doc(dateId).set({
      'verseKey': verseKey,
      'textArabic': textArabic,
      'translation': translation,
      'topic': topic,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Add new audio content (Dhikr/Dua)
  Future<void> addAudioContent(DuaAudio audio) async {
    await _audioCollection.add(audio.toMap());
  }

  /// Add a new community challenge
  Future<void> addChallenge(Challenge challenge) async {
    await _challengesCollection.add(challenge.toMap());
  }

  /// Grant or Revoke Admin Status (for development/bootstrap)
  Future<void> setAdminStatus(String uid, bool isAdmin) async {
    await _usersCollection.doc(uid).update({'isAdmin': isAdmin});
  }
  
  /// Delete content (Generic)
  Future<void> deleteContent(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Initial Seed for New Environment
  Future<void> seedInitialData() async {
    // 1. Seed Daily Verse (Today)
    final today = DateTime.now();
    final dateId = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await setDailyVerse(
      dateId: dateId,
      verseKey: '2:255',
      textArabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence.',
      topic: 'Tawhid',
    );

    // 2. Seed Audio Content
    final morningDhikr = DuaAudio(
      id: '',
      name: 'Morning Adhkar (Featured)',
      nameArabic: 'أذكار الصباح',
      category: 'morning',
      audioUrl: 'https://archive.org/download/morning-dhikr-featured/morning_dhikr.mp3',
      duration: const Duration(minutes: 5),
    );
    await addAudioContent(morningDhikr);

    // 3. Seed Challenges
    final ramadanChallenge = Challenge(
      id: '',
      title: 'Ramadan Preparation',
      description: 'Prepare your heart for the holy month with daily prayers.',
      icon: '🌙',
      startDate: today,
      endDate: today.add(const Duration(days: 30)),
      totalDays: 30,
    );
    await addChallenge(ramadanChallenge);
    
    print('AdminService: Initial seeding complete!');
  }
}
