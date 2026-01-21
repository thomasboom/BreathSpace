# Testing Guide

This document provides guidelines for writing and running tests in the BreathSpace project.

## Table of Contents

- [Testing Philosophy](#testing-philosophy)
- [Test Structure](#test-structure)
- [Writing Tests](#writing-tests)
- [Running Tests](#running-tests)
- [Mocking](#mocking)
- [Coverage](#coverage)

## Testing Philosophy

We believe in writing tests that:

1. Are reliable and deterministic
2. Cover critical user flows
3. Are easy to read and understand
4. Help prevent regressions
5. Provide confidence in refactoring

## Test Structure

The `test/` directory contains all application tests:

```
test/
├── data_test.dart           # Exercise data model tests
├── providers_test.dart      # Provider state management tests
├── rate_limiter_test.dart  # Rate limiter utility tests
├── stages_test.dart        # Breathing stage tests
└── widget_test.dart        # Widget tests
```

### Test Files

- **data_test.dart**: Tests for exercise data models, JSON parsing, and data loading
- **providers_test.dart**: Tests for SettingsProvider, ThemeProvider, and PinnedExercisesProvider
- **rate_limiter_test.dart**: Tests for rate limiting utility
- **stages_test.dart**: Tests for BreathingStage model
- **widget_test.dart**: Widget tests for Flutter widgets

### File Naming

- Name test files with `_test.dart` suffix
- Match the file structure to the source code structure when applicable

Example:
```
lib/data.dart          -> test/data_test.dart
lib/rate_limiter.dart -> test/rate_limiter_test.dart
```

## Writing Tests

### General Guidelines

- Use descriptive test names that explain what is being tested
- Follow the AAA pattern: Arrange, Act, Assert
- Test one behavior per test
- Avoid testing implementation details
- Use meaningful assertions
- Load exercises with `loadBreathingExercisesUsingSystemLocale()` before widget tests

### Example Data Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/logger.dart';

void main() {
  group('BreathingExercise', () {
    test('should parse simple exercise from JSON', () async {
      // Arrange
      await loadBreathingExercisesUsingSystemLocale();

      // Act
      final exercises = breathingExercises;
      final boxBreathing = exercises.firstWhere(
        (e) => e.id == 'box-breathing',
        orElse: () => throw Exception('Exercise not found'),
      );

      // Assert
      expect(boxBreathing.id, 'box-breathing');
      expect(boxBreathing.pattern, '4-4-4-4');
      expect(boxBreathing.duration, '4 min');
    });
  });
}
```

### Example Provider Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/settings_provider.dart';

void main() {
  group('SettingsProvider', () {
    late SettingsProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = SettingsProvider();
    });

    test('should toggle sound effects', () {
      // Arrange
      final initial = provider.soundEffectsEnabled;

      // Act
      provider.toggleSoundEffects();

      // Assert
      expect(provider.soundEffectsEnabled, !initial);
    });
  });
}
```

### Example Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:BreathSpace/settings_screen.dart';
import 'package:BreathSpace/settings_provider.dart';

void main() {
  testWidgets('Settings screen displays language options', (WidgetTester tester) async {
    // Arrange
    await loadBreathingExercisesUsingSystemLocale();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: MaterialApp(home: SettingsScreen()),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
  });
}
```

### Example Utility Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:BreathSpace/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('should allow request within limit', () {
      // Arrange
      final limiter = RateLimiter(maxRequests: 5, windowMs: 1000);

      // Act
      final allowed = limiter.tryRequest();

      // Assert
      expect(allowed, true);
    });

    test('should block requests exceeding limit', () {
      // Arrange
      final limiter = RateLimiter(maxRequests: 2, windowMs: 1000);

      // Act
      limiter.tryRequest();
      limiter.tryRequest();
      final blocked = limiter.tryRequest();

      // Assert
      expect(blocked, false);
    });
  });
}
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/data_test.dart
flutter test test/providers_test.dart
flutter test test/widget_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

Coverage reports are generated in `coverage/` directory:
- `coverage/lcov.info` - Coverage data in LCOV format
- Use `genhtml` to generate HTML report:
  ```bash
  genhtml coverage/lcov.info -o coverage/html
  open coverage/html/index.html
  ```

### Run Tests with Platform Filter

```bash
# Run tests on specific platform
flutter test -d chrome    # Chrome web
flutter test -d macos     # macOS
flutter test -d linux     # Linux
```

## Mocking

### SharedPreferences Mock

For testing providers that use SharedPreferences, use mock initialization:

```dart
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'languagePreference': 'en',
      'musicMode': 'off',
    });
  });
}
```

### Mocking Services

For mocking external services (like Gemini AI), create mock classes:

```dart
class MockGeminiService implements GeminiService {
  @override
  Future<String> generateExercise(String prompt) async {
    return 'Mock exercise';
  }
}
```

## Coverage

### Current Test Files

1. **data_test.dart** - Tests for:
   - Exercise JSON parsing
   - BreathingStage model
   - ExerciseVersion functionality
   - Localization key resolution

2. **providers_test.dart** - Tests for:
   - SettingsProvider state management
   - ThemeProvider theme switching
   - PinnedExercisesProvider pin/unpin functionality

3. **rate_limiter_test.dart** - Tests for:
   - Request rate limiting
   - Time-based window expiration
   - Request counting

4. **stages_test.dart** - Tests for:
   - BreathingStage creation
   - Stage pattern parsing
   - Stage duration handling

5. **widget_test.dart** - Tests for:
   - Widget rendering
   - User interactions
   - Provider integration

### Running Coverage Report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Coverage Goals

Aim for:
- At least 80% coverage on critical paths
- Provider state management: 90%+
- Data models: 95%+
- Utility functions: 95%+

## Debugging Tests

### Verbose Output

```bash
flutter test --verbose
```

### Print Statements

Use `print()` or `debugPrint()` for debugging:

```dart
test('example test', () {
  final result = someCalculation();
  print('Result: $result');  // Shows in test output
  expect(result, equals(expected));
});
```

### Breakpoints

Run tests in debug mode to use breakpoints:

```bash
flutter test --no-pub --no-test-randomize-ordering-seed
```

### Test Organization

Group related tests using `group()`:

```dart
void main() {
  group('SettingsProvider', () {
    group('Language', () {
      test('should set language', () { ... });
      test('should save language preference', () { ... });
    });

    group('Music', () {
      test('should set music mode', () { ... });
      test('should toggle music', () { ... });
    });
  });
}
```

## Best Practices

1. **Test Setup**: Use `setUp()` to initialize objects before each test
2. **Test Teardown**: Use `tearDown()` to clean up after each test
3. **Async Tests**: Use `async`/`await` for asynchronous operations
4. **Widget Tests**: Use `pump()` and `pumpAndSettle()` for widget state updates
5. **Isolate Tests**: Each test should be independent and not depend on others
6. **Descriptive Names**: Test names should describe what is being tested and what the expected outcome is

### Loading Exercises Before Tests

For tests that need exercise data:

```dart
import 'package:BreathSpace/data.dart';

void main() {
  setUpAll(() async {
    await loadBreathingExercisesUsingSystemLocale();
  });

  test('example test', () {
    final exercises = breathingExercises;
    expect(exercises.isNotEmpty, true);
  });
}
```
