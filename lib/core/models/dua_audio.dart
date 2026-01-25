import 'package:cloud_firestore/cloud_firestore.dart';

class DuaAudio {
  final String id;
  final String name;
  final String nameArabic;
  final String category; // morning, evening, sleep, general
  final String audioUrl;
  final Duration duration;
  final bool isPremium;

  DuaAudio({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.category,
    required this.audioUrl,
    required this.duration,
    this.isPremium = false,
  });

  factory DuaAudio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DuaAudio(
      id: doc.id,
      name: data['name'] ?? '',
      nameArabic: data['nameArabic'] ?? '',
      category: data['category'] ?? 'general',
      audioUrl: data['audioUrl'] ?? '',
      duration: Duration(milliseconds: data['durationMs'] ?? 0),
      isPremium: data['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'category': category,
      'audioUrl': audioUrl,
      'durationMs': duration.inMilliseconds,
      'isPremium': isPremium,
    };
  }
}
