import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/medicine_model.dart';
import 'package:flutter/foundation.dart';

class AIAssistantService {
  final Dio _dio = Dio();
  String? _apiKey;
  final List<Map<String, String>> _chatHistory = [];
  String _systemPrompt = '';

  AIAssistantService() {
    _apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      debugPrint(
          'AIAssistantService: WARNING - OPENROUTER_API_KEY not found in .env');
      _apiKey = null;
    } else {
      debugPrint(
          'AIAssistantService: OpenRouter API Key loaded successfully (length: ${_apiKey!.length})');
    }
  }

  void initializeChatContext(List<MedicineModel> userMedicines) {
    _chatHistory.clear();

    String activeMedsContext = userMedicines
        .map((m) =>
            "- ${m.medicineName} (Expires: ${m.expiryDate.year}-${m.expiryDate.month.toString().padLeft(2, '0')}-${m.expiryDate.day.toString().padLeft(2, '0')})")
        .join('\n');

    if (activeMedsContext.isEmpty) {
      activeMedsContext =
          "The user currently has no medicines logged in their inventory.";
    }

    _systemPrompt = '''
You are the MediTrack Assistant, a helpful AI health companion. Your primary goal is to help the user understand the medicines currently in their inventory.
Here is the user's current active medicine inventory:
$activeMedsContext

CRITICAL RULES YOU MUST FOLLOW:
1. DO NOT provide medical diagnoses. If the user describes symptoms (e.g., "I have a headache"), you MUST reply: "I cannot diagnose symptoms. Please consult a licensed healthcare professional or doctor immediately."
2. You may explain the general purpose, common side effects, and standard intake instructions for the specific medicines in their inventory.
3. If they ask about a medicine NOT in their inventory, you may provide standard information but remind them they do not currently have it logged in MediTrack.
4. Always end your responses with a generic disclaimer: "Note: Always consult your doctor before changing your medication routine."
5. Be concise and format your response using Markdown (bullet points, bold text).
''';

    debugPrint(
        'AIAssistantService: Chat context initialized with ${userMedicines.length} medicines');
  }

  Future<String> sendMessage(String userMessage) async {
    if (_apiKey == null) {
      return "API Key is missing. Please add your OpenRouter API key to the .env file as OPENROUTER_API_KEY and restart the app.";
    }

    // Add user message to history
    _chatHistory.add({'role': 'user', 'content': userMessage});

    // Build messages array with system prompt + chat history
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ..._chatHistory,
    ];

    try {
      debugPrint('AIAssistantService: Sending message to OpenRouter...');

      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
            'HTTP-Referer': 'https://meditrack.app',
            'X-Title': 'MediTrack Assistant',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
        data: {
          'model': 'google/gemini-2.0-flash-001',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      debugPrint(
          'AIAssistantService: Response received (status: ${response.statusCode})');

      if (response.statusCode == 200 && response.data != null) {
        final choices = response.data['choices'];
        if (choices != null && choices.isNotEmpty) {
          final text = choices[0]['message']['content'] ?? '';

          // Add model response to history for context continuity
          _chatHistory.add({'role': 'assistant', 'content': text});

          return text;
        }
        return "I received an empty response. Please try again.";
      } else {
        debugPrint(
            'AIAssistantService: Unexpected status: ${response.statusCode}');
        _chatHistory.removeLast();
        return "Received an unexpected response (Status: ${response.statusCode}). Please try again.";
      }
    } on DioException catch (e) {
      debugPrint('AIAssistantService: DioException: ${e.type} - ${e.message}');
      if (e.response != null) {
        debugPrint('AIAssistantService: Error Response: ${e.response?.data}');
      }
      _chatHistory.removeLast();

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "The request timed out. Please check your internet connection and try again.";
      } else if (e.response?.statusCode == 401) {
        return "Invalid API key. Please check your OpenRouter API key in the .env file.";
      } else if (e.response?.statusCode == 429) {
        return "Rate limit exceeded. Please wait a moment and try again.";
      }
      return "Connection error: ${e.message ?? 'Unknown error'}. Please check your internet and try again.";
    } catch (e) {
      debugPrint('AIAssistantService: General Error: $e');
      _chatHistory.removeLast();
      return "An unexpected error occurred: $e";
    }
  }
}
