import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/prompt_cache_service.dart';
import 'package:BreathSpace/rate_limiter.dart';
import 'package:BreathSpace/logger.dart';

class GeminiService {
  // API key is loaded from environment variables (.env file)
  // It's recommended to use environment variables or a secure method for API keys in production.
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  Future<String?> recommendExercise(
    String userInput,
    List<BreathingExercise> exercises,
  ) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      AppLogger.warning('Gemini API key not configured');
      return null;
    }

    AppLogger.debug('Getting recommendation for: $userInput');

    final isLimited = await RateLimiter.isRateLimited();
    if (isLimited) {
      AppLogger.warning('Rate limit exceeded');
      return null;
    }

    final exerciseDescriptions = exercises
        .map((e) => "- ID: ${e.id}, Title: ${e.title}, Intro: ${e.intro}")
        .join('\n');

    final prompt =
        """
The user is looking for a breathing exercise. Their current state or goal is: "$userInput".
Here is a list of available breathing exercises. Each exercise has an ID, Title, and a brief Intro:
$exerciseDescriptions

Based on the user's input, please recommend the ID of the single most relevant breathing exercise from the list above.
Prioritize matching the user's goal/state with the exercise's Intro and Title.
If the user's input is general (e.g., "relax", "focus"), recommend a suitable general exercise like 'box-breathing' or 'equal-breathing'.
Respond ONLY with the 'id' of the recommended exercise. Do NOT include any other text, explanation, or punctuation.
If the user's request is completely unrelated to breathing exercises, respond with "none".
""";

    final cachedResponse = await PromptCacheService.getCachedResponse(prompt);
    if (cachedResponse != null) {
      AppLogger.debug('Cache hit for prompt');
      return cachedResponse;
    }

    try {
      AppLogger.debug('Making Gemini API call');
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String? recommendedId =
            jsonResponse['candidates']?[0]['content']?['parts']?[0]?['text'];
        final result = recommendedId?.trim();

        if (result != null) {
          await PromptCacheService.cacheResponse(prompt, result);
          await RateLimiter.incrementRequestCount();
          AppLogger.info('Gemini API call successful, recommended: $result');
        }

        return result;
      } else {
        await RateLimiter.incrementRequestCount();
        AppLogger.warning('Gemini API returned status ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      await RateLimiter.incrementRequestCount();
      AppLogger.error('Gemini API call failed', e, stack);
      return null;
    }
  }
}
