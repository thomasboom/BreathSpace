import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:BreathSpace/data.dart'; // Assuming data.dart contains BreathingExercise
import 'package:BreathSpace/prompt_cache_service.dart'; // Import the prompt cache service

class GeminiService {
  // API key is loaded from environment variables (.env file)
  // It's recommended to use environment variables or a secure method for API keys in production.
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String?> recommendExercise(String userInput, List<BreathingExercise> exercises) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      return null;
    }

    final exerciseDescriptions = exercises.map((e) =>
      "- ID: ${e.id}, Title: ${e.title}, Intro: ${e.intro}"
    ).join('\n');

    final prompt = """
The user is looking for a breathing exercise. Their current state or goal is: "$userInput".
Here is a list of available breathing exercises. Each exercise has an ID, Title, and a brief Intro:
$exerciseDescriptions

Based on the user's input, please recommend the ID of the single most relevant breathing exercise from the list above.
Prioritize matching the user's goal/state with the exercise's Intro and Title.
If the user's input is general (e.g., "relax", "focus"), recommend a suitable general exercise like 'box-breathing' or 'equal-breathing'.
Respond ONLY with the 'id' of the recommended exercise. Do NOT include any other text, explanation, or punctuation.
If the user's request is completely unrelated to breathing exercises, respond with "none".
""";

    // Check if we have a cached response for this prompt
    final cachedResponse = await PromptCacheService.getCachedResponse(prompt);
    if (cachedResponse != null) {
      return cachedResponse;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String? recommendedId = jsonResponse['candidates']?[0]['content']?['parts']?[0]?['text'];
        final result = recommendedId?.trim();
        
        // Cache the response for future use
        if (result != null) {
          await PromptCacheService.cacheResponse(prompt, result);
        }
        
        return result;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}