import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    late List<SharedPreferences> prefsInstances;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsInstances = [prefs];
      RateLimiter.resetOperationQueue();
    });

    tearDown(() {
      prefsInstances.clear();
      RateLimiter.resetOperationQueue();
    });

    group('resetOperationQueue', () {
      test('resets the operation queue', () async {
        RateLimiter.resetOperationQueue();
        expect(() => RateLimiter.resetOperationQueue(), returnsNormally);
      });
    });

    group('getRequestStats', () {
      test('returns correct stats when count is 0', () async {
        final stats = await RateLimiter.getRequestStats();
        expect(stats['current'], 0);
        expect(stats['remaining'], 10);
        expect(stats['max'], 10);
      });

      test('resets counter on new day', () async {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('gemini_request_count', 10);
        await prefs.setString('gemini_last_reset_date', yesterday);
        RateLimiter.resetOperationQueue();

        final stats = await RateLimiter.getRequestStats();
        expect(stats['current'], 0);
        expect(stats['remaining'], 10);
      });
    });

    group('reset', () {
      test('resets request count', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('gemini_request_count', 8);
        await prefs.setString('gemini_last_reset_date', '2020-01-01');
        RateLimiter.resetOperationQueue();

        await RateLimiter.reset();

        final newCount = prefs.getInt('gemini_request_count');
        expect(newCount, 0);
      });

      test('returns true on success', () async {
        final result = await RateLimiter.reset();
        expect(result, true);
      });
    });

    group('incrementRequestCount', () {
      test('returns true on success in debug mode', () async {
        final result = await RateLimiter.incrementRequestCount();
        expect(result, true);
      });
    });

    group('isRateLimited', () {
      test('returns false in debug mode', () async {
        final result = await RateLimiter.isRateLimited();
        expect(result, false);
      });
    });
  });
}
