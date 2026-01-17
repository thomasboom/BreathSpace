import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/logger.dart';

/// A service for caching AI prompts and their responses on-device
class PromptCacheService {
  static const String _cacheKey = 'prompt_cache';
  static const int _maxCacheSize = 50; // Maximum number of cached entries

  /// Get a cached response for a given prompt
  static Future<String?> getCachedResponse(String prompt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);

      if (cacheString != null) {
        final cache = Map<String, dynamic>.from(jsonDecode(cacheString));
        final entry = cache[prompt];

        if (entry != null) {
          final timestamp = entry['timestamp'] as int;
          final ttl = entry['ttl'] as int? ?? 86400000;
          final now = DateTime.now().millisecondsSinceEpoch;

          if (now - timestamp < ttl) {
            AppLogger.debug('Cache hit for prompt');
            return entry['response'] as String;
          } else {
            cache.remove(prompt);
            await prefs.setString(_cacheKey, jsonEncode(cache));
            AppLogger.debug('Cache entry expired and removed');
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error reading from prompt cache', e);
    }

    return null;
  }

  /// Cache a response for a given prompt
  static Future<bool> cacheResponse(
    String prompt,
    String response, {
    int ttl = 86400000,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);

      final cache = cacheString != null
          ? Map<String, dynamic>.from(jsonDecode(cacheString))
          : <String, dynamic>{};

      cache[prompt] = {
        'response': response,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl,
      };

      if (cache.length > _maxCacheSize) {
        final entries = cache.entries.toList()
          ..sort(
            (a, b) => (b.value['timestamp'] as int).compareTo(
              a.value['timestamp'] as int,
            ),
          );

        final trimmedEntries = entries.take(_maxCacheSize);
        cache
          ..clear()
          ..addEntries(trimmedEntries);
      }

      final success = await prefs.setString(_cacheKey, jsonEncode(cache));
      if (success) {
        AppLogger.debug(
          'Cached response for prompt (cache size: ${cache.length})',
        );
      }
      return success;
    } catch (e) {
      AppLogger.error('Error writing to prompt cache', e);
      return false;
    }
  }

  /// Clear all cached responses
  static Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_cacheKey);
    } catch (e) {
      AppLogger.error('Error clearing prompt cache', e);
      return false;
    }
  }

  /// Get the number of cached entries
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);

      if (cacheString != null) {
        final cache = Map<String, dynamic>.from(jsonDecode(cacheString));
        return cache.length;
      }
    } catch (e) {
      AppLogger.error('Error getting cache size', e);
    }

    return 0;
  }
}
