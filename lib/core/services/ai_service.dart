import 'package:dio/dio.dart';

/// AI Service for Islamic Q&A with RAG pipeline
class AIService {
  final Dio _dio = Dio();
  
  // Configure your AI provider here
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _openaiApiUrl = 'https://api.openai.com/v1/chat/completions';
  
  String? _apiKey;
  String _provider = 'groq'; // 'groq' or 'openai'
  
  /// System prompt for scholar-validated responses
  static const String _systemPrompt = '''
You are an Islamic knowledge assistant named "Iman Flow AI". Your purpose is to help Muslims learn about their faith with accurate, authentic information.

GUIDELINES:
1. Always cite Quran verses (format: Surah Name X:Y) and authentic Hadith (prefer Sahih Bukhari and Sahih Muslim)
2. Acknowledge when there are scholarly differences of opinion (ikhtilaf)
3. For personal rulings (fatwa), recommend consulting a local scholar
4. Never fabricate sources - if unsure, say "I don't have verified information on this"
5. Be respectful and encouraging in your responses
6. For Tafsir questions, reference classical scholars like Ibn Kathir, Al-Qurtubi, or contemporary scholars
7. Respond in the user's language (English, Arabic, or Urdu supported)

RESPONSE FORMAT:
- Keep responses concise but complete
- Use markdown formatting for readability
- Include relevant Quran verses in Arabic with translation when applicable
- End with a brief beneficial reminder or dua when appropriate
''';

  void configure({required String apiKey, String provider = 'groq'}) {
    _apiKey = apiKey;
    _provider = provider;
  }

  /// Send a message to the AI
  Future<String> sendMessage(String userMessage, {List<Map<String, String>>? context}) async {
    if (_apiKey == null) {
      return 'Please configure the AI service with an API key.';
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      if (context != null) ...context,
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _dio.post(
        _provider == 'groq' ? _groqApiUrl : _openaiApiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _provider == 'groq' ? 'llama-3.1-70b-versatile' : 'gpt-4-turbo-preview',
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return content ?? 'No response received.';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'Invalid API key. Please check your configuration.';
      }
      return 'Error connecting to AI service: ${e.message}';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  /// Generate personalized Dua based on user's situation
  Future<String> generatePersonalizedDua(String situation) async {
    final prompt = '''
Based on the following situation, suggest an appropriate authentic Dua from the Sunnah:

Situation: $situation

Please provide:
1. The Dua in Arabic
2. Transliteration
3. English translation
4. When/how to recite it
5. Source (Hadith reference if available)
''';
    return sendMessage(prompt);
  }

  /// Get Tafsir explanation for a verse
  Future<String> getTafsir(String surah, int ayah) async {
    final prompt = '''
Provide a Tafsir (explanation) for Surah $surah, Ayah $ayah.

Include:
1. The verse in Arabic
2. Translation
3. Context of revelation (if known)
4. Key lessons and meanings from classical Tafsir
5. How to apply this verse in daily life
''';
    return sendMessage(prompt);
  }

  /// Answer "What does Islam say about X?" questions
  Future<String> askAboutIslam(String topic) async {
    final prompt = '''
What does Islam teach about: $topic

Please provide a balanced answer citing:
1. Relevant Quran verses
2. Authentic Hadith
3. Scholarly opinions (if there are differences)
4. Practical guidance
''';
    return sendMessage(prompt);
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
