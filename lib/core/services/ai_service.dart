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
  String? _apiKey;
  String _region = 'us-east-1';
  String _modelId = 'amazon.nova-pro-v1:0';
  
  bool get _isConfigured => 
      (_accessKeyId != null && _accessKeyId!.isNotEmpty && _secretAccessKey != null && _secretAccessKey!.isNotEmpty) || 
      (_apiKey != null && _apiKey!.isNotEmpty);

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
    String? accessKeyId, 
    String? secretAccessKey, 
    String? apiKey,
    required String region,
  }) {
    _accessKeyId = accessKeyId;
    _secretAccessKey = secretAccessKey;
    _apiKey = apiKey;
    _region = region;
  }

  /// Send a message to AWS Bedrock
  Future<String> sendMessage(String message) async {
    if (!_isConfigured) {
      // Demo Mode Response
      await Future.delayed(const Duration(seconds: 1));
      return "✨ **Demo Mode**\n\nAI settings are not configured. In a real environment, I would answer: \"$message\" using authenticated Islamic knowledge.\n\nTo enable real AI:\n1. Get AWS Access Keys or Bedrock API Key\n2. Add them to your build configuration.";
    }

    try {
      final endpoint = 'https://bedrock-runtime.$_region.amazonaws.com/model/$_modelId/invoke';
      
      // Amazon Nova Lite Payload Structure
      final payload = jsonEncode({
        "system": [
          { "text": _systemPrompt }
        ],
        "messages": [
          {
            "role": "user",
            "content": [
              { "text": message }
            ]
          }
        ],
        "inferenceConfig": {
          "max_new_tokens": 1000,
          "temperature": 0.7,
          "top_p": 0.9
        }
      });

      // USE API KEY IF AVAILABLE (Simpler, works with "ABSK..." keys)
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        final response = await _dio.post(
          endpoint,
          data: payload,
          options: Options(
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
          ),
        );
        return _parseResponse(response.data);
      }

      // FALLBACK TO SIGV4 (IAM Access Keys)
      final request = AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: Uri.parse(endpoint),
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: utf8.encode(payload),
      );

      final signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(
            _accessKeyId ?? '',
            _secretAccessKey ?? '',
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

      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: signedRequest.headers,
          responseType: ResponseType.json,
        ),
      );
      
      return _parseResponse(response.data);
    } catch (e) {
      print('AI Service Error: $e');
      if (e is DioException) {
         if (e.response != null) {
           print('Bedrock Error Body: ${e.response?.data}');
           if (e.response?.statusCode == 403) {
             return "⚠️ **Access Denied**\n\nThe security token is invalid or expired. Please check your AWS credentials.";
           }
           return 'AWS Error (${e.response?.statusCode})';
         }
      }
      return "Sorry, I couldn't process your request.";
    }
  }

  /// Synthesize Speech using Amazon Polly
  Future<Stream<List<int>>?> synthesizeSpeech(String text) async {
    if (!_isConfigured || _accessKeyId == null || _secretAccessKey == null) return null;

    try {
      final endpoint = 'https://polly.$_region.amazonaws.com/v1/speech';
      final payload = jsonEncode({
        'OutputFormat': 'mp3',
        'Text': text,
        'VoiceId': 'Joanna', // A clear, knowledgeable female voice
        'Engine': 'neural',
      });

      final request = AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: Uri.parse(endpoint),
        headers: {
          'content-type': 'application/json',
        },
        body: utf8.encode(payload),
      );

      final signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(_accessKeyId!, _secretAccessKey!),
        ),
      );

      final scope = AWSCredentialScope(
        region: _region,
        service: AWSService.polly,
      );

      final signedRequest = await signer.sign(
        request,
        credentialScope: scope,
      );

      final response = await _dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: signedRequest.headers,
          responseType: ResponseType.stream,
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as ResponseBody).stream;
      }
    } catch (e) {
      print('Polly TTS Error: $e');
    }
    return null;
  }

  String _parseResponse(dynamic data) {
    try {
      // Parsing logic for Amazon Nova Lite
      // Response format: { "output": { "message": { "content": [ { "text": "..." } ] } } }
      if (data is Map<String, dynamic>) {
        if (data.containsKey('output')) {
          final output = data['output'];
          if (output is Map<String, dynamic> && output.containsKey('message')) {
            final message = output['message'];
            if (message is Map<String, dynamic> && message.containsKey('content')) {
              final content = message['content'] as List;
              if (content.isNotEmpty) {
                return content[0]['text'].toString();
              }
            }
          }
        }
        // Fallback for Claude format (if switching back remains an option)
        if (data.containsKey('content') && data['content'] is List) {
           return (data['content'] as List)[0]['text'].toString();
        }
      }
    } catch (e) {
      print('Parsing Error: $e');
    }
    return "I received a response but couldn't understand it.";
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
