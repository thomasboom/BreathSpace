import 'package:shared_preferences/shared_preferences.dart';
import 'logger.dart';
import 'dart:async';

/// Service to manage API request rate limiting
class RateLimiter {
  static const String _requestCountKey = 'gemini_request_count';
  static const String _lastResetDateKey = 'gemini_last_reset_date';
  static const int _maxDailyRequests = 10;

  // Queue to handle async operations sequentially and prevent race conditions
  static Future<void> _operationQueue = Future.value();

  /// Reset the operation queue - primarily for testing
  static void resetOperationQueue() {
    _operationQueue = Future.value();
  }

  /// Check if the user has exceeded the daily rate limit
  static Future<bool> isRateLimited() async {
    // In debug mode, don't apply rate limiting
    if (_isDebugMode()) {
      return false;
    }

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Queue the operation to prevent race conditions
      final isLimited = await _queueOperation(() async {
        final prefs = await SharedPreferences.getInstance();
        final lastResetDate = prefs.getString(_lastResetDateKey);

        // Check if we need to reset the counter (new day)
        if (lastResetDate != today) {
          await prefs.setInt(_requestCountKey, 0);
          await prefs.setString(_lastResetDateKey, today);
        }

        // Get current count
        final currentCount = prefs.getInt(_requestCountKey) ?? 0;

        // Check if limit is exceeded
        return currentCount >= _maxDailyRequests;
      });
      return isLimited;
    } catch (e) {
      AppLogger.error('Error checking rate limit', e);
      // If there's an error, don't rate limit to avoid blocking users
      return false;
    }
  }

  /// Increment the request count
  static Future<bool> incrementRequestCount() async {
    // In debug mode, don't increment the counter
    if (_isDebugMode()) {
      return true;
    }

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Queue the operation to prevent race conditions
      await _queueOperation(() async {
        final prefs = await SharedPreferences.getInstance();
        final lastResetDate = prefs.getString(_lastResetDateKey);

        // Check if we need to reset the counter (new day)
        if (lastResetDate != today) {
          await prefs.setInt(_requestCountKey, 0);
          await prefs.setString(_lastResetDateKey, today);
        }

        // Get current count and increment
        final currentCount = prefs.getInt(_requestCountKey) ?? 0;
        final newCount = currentCount + 1;

        await prefs.setInt(_requestCountKey, newCount);
      });
      return true; // Indicate that the operation was successful
    } catch (e) {
      AppLogger.error('Error incrementing request count', e);
      return false;
    }
  }

  /// Get the current request count and remaining requests
  static Future<Map<String, int>> getRequestStats() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Queue the operation to prevent race conditions
      final stats = await _queueOperation(() async {
        final prefs = await SharedPreferences.getInstance();
        final lastResetDate = prefs.getString(_lastResetDateKey);

        // If it's a new day, reset the counter
        if (lastResetDate != today) {
          await prefs.setInt(_requestCountKey, 0);
          await prefs.setString(_lastResetDateKey, today);
        }

        final currentCount = prefs.getInt(_requestCountKey) ?? 0;
        final remaining = _maxDailyRequests - currentCount;

        return {
          'current': currentCount,
          'remaining': remaining > 0 ? remaining : 0,
          'max': _maxDailyRequests,
        };
      });
      return stats;
    } catch (e) {
      AppLogger.error('Error getting request stats', e);
      return {
        'current': 0,
        'remaining': _maxDailyRequests,
        'max': _maxDailyRequests,
      };
    }
  }

  /// Queue an operation to execute sequentially to prevent race conditions
  static Future<T> _queueOperation<T>(Future<T> Function() operation) async {
    // This ensures operations execute sequentially, preventing race conditions
    final completer = Completer<T>();
    _operationQueue = _operationQueue.then((_) async {
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }
  
  /// Reset the rate limiter (for testing purposes)
  static Future<bool> reset() async {
    try {
      // Queue the operation to prevent race conditions
      await _queueOperation(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_requestCountKey, 0);
        await prefs.setString(_lastResetDateKey, DateTime.now().toIso8601String().split('T')[0]);
      });
      return true;
    } catch (e) {
      AppLogger.error('Error resetting rate limiter', e);
      return false;
    }
  }
  
  /// Check if we're in debug mode
  static bool _isDebugMode() {
    return !const bool.fromEnvironment("dart.vm.product");
  }
}