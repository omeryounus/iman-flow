import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart';

/// AI Service for Islamic Q&A using AWS Bedrock
class AIService {
  final Dio _dio = Dio();
  
  // AWS Configuration
  String? _accessKeyId;
  String? _secretAccessKey;
  String _region = 'us-east-1';
  String _modelId = 'anthropic.claude-3-haiku-20240307-v1:0';
  
  bool get _isConfigured => _accessKeyId != null && _secretAccessKey != null;

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

  void configure({
    required String accessKeyId, 
    required String secretAccessKey, 
    String region = 'us-east-1',
  }) {
    _accessKeyId = accessKeyId;
    _secretAccessKey = secretAccessKey;
    _region = region;
  }

  /// Send a message to AWS Bedrock
  Future<String> sendMessage(String userMessage, {List<Map<String, String>>? context}) async {
    if (!_isConfigured) {
      return 'Please configure the AI service with AWS credentials.';
    }

    try {
      // 1. Prepare the payload for Claude 3 (Messages API)
      final messages = [
        if (context != null)
          ...context.map((m) => {
            'role': m['role'] == 'user' ? 'user' : 'assistant',
            'content': m['content'],
          }),
        {'role': 'user', 'content': userMessage}
      ];

      final body = jsonEncode({
        'anthropic_version': 'bedrock-2023-05-31',
        'max_tokens': 1024,
        'system': _systemPrompt,
        'messages': messages,
        'temperature': 0.7,
      });

      // 2. Create the request
      final endpoint = Uri.parse('https://bedrock-runtime.$_region.amazonaws.com/model/$_modelId/invoke');
      final request = AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: endpoint,
        headers: const {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: utf8.encode(body),
      );

      // 3. Sign the request
      final signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(
            _accessKeyId!,
            _secretAccessKey!,
          ),
        ),
      );

      final scope = AWSCredentialScope(
        region: _region,
        service: AWSService.bedrock,
      );

      final signedRequest = await signer.sign(
        request,
        credentialScope: scope,
      );

      // 4. Send using Dio (converting headers)
      final response = await _dio.postUri(
        endpoint,
        data: body,
        options: Options(
          headers: signedRequest.headers,
          responseType: ResponseType.json,
        ),
      );

      // 5. Parse response
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        final contentList = data['content'] as List;
        if (contentList.isNotEmpty) {
          return contentList.first['text'] as String;
        }
      }
      return 'No response received from Bedrock.';

    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return 'Access denied. Please check your AWS credentials and model access.';
      }
      return 'Error connecting to AWS Bedrock: ${e.message}';
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
