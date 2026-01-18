import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'quran_service.dart';
import 'service_locator.dart';

class DailyContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final QuranService _quranService = getIt<QuranService>();

  /// Get the daily verse.
  /// 
  /// Logic:
  /// 1. Try to fetch from Firestore 'daily_content' using today's date ID (YYYY-MM-DD).
  /// 2. If valid doc exists, return it as a Verse object.
  /// 3. If missing/error, fallback to QuranService.getRandomVerse().
  Future<Verse> getDailyVerse() async {
    try {
      final dateId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final doc = await _firestore.collection('daily_content').doc(dateId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return Verse(
          verseKey: data['verseKey'] ?? '1:1',
          textArabic: data['textArabic'] ?? '',
          translation: data['translation'],
          verseNumber: int.tryParse(data['verseKey']?.split(':')[1] ?? '1') ?? 1,
          surahNumber: int.tryParse(data['verseKey']?.split(':')[0] ?? '1') ?? 1,
        );
      } else {
        // Fallback to random if no daily content scheduled
        return await _quranService.getRandomVerse();
      }
    } catch (e) {
      print('Error getting daily verse: $e');
      // Fallback on error
      return await _quranService.getRandomVerse();
    }
  }
}
