import 'package:dio/dio.dart';
import 'dart:convert';

/// Quran Service - Fetches Quran data from Quran.com API
class QuranService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.quran.com/api/v4',
    headers: {'Accept': 'application/json'},
  ));

  /// Get list of all Surahs
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await _dio.get('/chapters');
      final chapters = response.data['chapters'] as List;
      return chapters.map((c) => Surah.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to load Surahs: $e');
    }
  }

  /// Get a specific Surah
  Future<Surah> getSurah(int surahNumber) async {
    try {
      final response = await _dio.get('/chapters/$surahNumber');
      return Surah.fromJson(response.data['chapter']);
    } catch (e) {
      throw Exception('Failed to load Surah: $e');
    }
  }

  /// Get verses of a Surah with translation
  Future<List<Verse>> getVerses(
    int surahNumber, {
    String translation = 'en.sahih', // Sahih International
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/verses/by_chapter/$surahNumber',
        queryParameters: {
          'translations': translation,
          'page': page,
          'per_page': perPage,
          'fields': 'text_uthmani,verse_key',
        },
      );
      final verses = response.data['verses'] as List;
      return verses.map((v) => Verse.fromJson(v)).toList();
    } catch (e) {
      throw Exception('Failed to load verses: $e');
    }
  }

  /// Get a specific verse with translation
  Future<Verse> getVerse(String verseKey) async {
    try {
      final response = await _dio.get(
        '/verses/by_key/$verseKey',
        queryParameters: {
          'translations': 'en.sahih',
          'fields': 'text_uthmani,verse_key',
        },
      );
      return Verse.fromJson(response.data['verse']);
    } catch (e) {
      throw Exception('Failed to load verse: $e');
    }
  }

  /// Search Quran
  Future<List<Verse>> searchQuran(String query, {String language = 'en'}) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'size': 20,
          'language': language,
        },
      );
      final results = response.data['search']['results'] as List;
      return results.map((r) => Verse.fromSearchResult(r)).toList();
    } catch (e) {
      throw Exception('Failed to search Quran: $e');
    }
  }

  /// Get audio recitation URL
  Future<String> getRecitationUrl(String verseKey, {int reciterId = 7}) async {
    // Reciter 7 = Mishary Rashid Alafasy (popular)
    try {
      final response = await _dio.get(
        '/recitations/$reciterId/by_ayah/$verseKey',
      );
      final audioUrl = response.data['audio_files'][0]['url'];
      return 'https://verses.quran.com/$audioUrl';
    } catch (e) {
      throw Exception('Failed to get audio: $e');
    }
  }

  /// Get random verse for daily inspiration
  Future<Verse> getRandomVerse() async {
    final random = DateTime.now().millisecondsSinceEpoch % 6236 + 1; // Total verses in Quran
    // Convert to verse key (simplified - would need proper mapping)
    final surahs = await getSurahs();
    int count = 0;
    for (var surah in surahs) {
      if (count + surah.versesCount >= random) {
        final ayah = random - count;
        return getVerse('${surah.id}:$ayah');
      }
      count += surah.versesCount;
    }
    return getVerse('1:1'); // Fallback to Al-Fatiha
  }
}

/// Surah model
class Surah {
  final int id;
  final String nameArabic;
  final String nameSimple;
  final String nameTranslated;
  final String revelationPlace;
  final int versesCount;

  Surah({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameTranslated,
    required this.revelationPlace,
    required this.versesCount,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      nameArabic: json['name_arabic'] ?? '',
      nameSimple: json['name_simple'] ?? '',
      nameTranslated: json['translated_name']?['name'] ?? '',
      revelationPlace: json['revelation_place'] ?? '',
      versesCount: json['verses_count'] ?? 0,
    );
  }
}

/// Verse model
class Verse {
  final String verseKey;
  final String textArabic;
  final String? translation;
  final int verseNumber;
  final int surahNumber;

  Verse({
    required this.verseKey,
    required this.textArabic,
    this.translation,
    required this.verseNumber,
    required this.surahNumber,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as List?;
    return Verse(
      verseKey: json['verse_key'] ?? '',
      textArabic: json['text_uthmani'] ?? json['text'] ?? '',
      translation: translations?.isNotEmpty == true 
          ? translations![0]['text'] 
          : null,
      verseNumber: json['verse_number'] ?? 0,
      surahNumber: int.tryParse(json['verse_key']?.split(':')[0] ?? '1') ?? 1,
    );
  }

  factory Verse.fromSearchResult(Map<String, dynamic> json) {
    return Verse(
      verseKey: json['verse_key'] ?? '',
      textArabic: json['text'] ?? '',
      translation: json['translations']?[0]?['text'],
      verseNumber: json['verse_id'] ?? 0,
      surahNumber: int.tryParse(json['verse_key']?.split(':')[0] ?? '1') ?? 1,
    );
  }
}
