# Style Guide

This document outlines the coding conventions and style guidelines for the BreathSpace project.

## Table of Contents

- [Dart Code Style](#dart-code-style)
- [File Naming](#file-naming)
- [Imports](#imports)
- [Naming Conventions](#naming-conventions)
- [Documentation](#documentation)
- [Widget Structure](#widget-structure)
- [State Management](#state-management)
- [Types](#types)
- [Error Handling](#error-handling)
- [Logging](#logging)

## Dart Code Style

We follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) with some project-specific additions:

- Use 2 spaces for indentation (no tabs)
- Lines should not exceed 80 characters when practical
- Use trailing commas for better formatting
- Prefer single quotes for strings

## File Naming

- Use `lowercase_with_underscores.dart` for file names
- Use descriptive names that clearly indicate the file's purpose
- Match file names to the main class/widget they contain when possible

Examples:

```
exercise_detail_screen.dart
settings_provider.dart
rate_limiter.dart
```

## Imports

- Use `package:` imports for files within the project from `lib/`
- Use relative imports within same directory when appropriate
- Use specific imports with `show` or `hide` when only a few members are needed
- Group imports in the following order:
  1. Dart SDK imports
  2. Flutter imports
  3. Package imports

- Separate each group with a blank line
- Sort imports alphabetically within each group

Example:

```dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/settings_provider.dart';
```

## Naming Conventions

### Classes and Types

- Use `UpperCamelCase` for class names
- Use `UpperCamelCase` for enums
- Use `UpperCamelCase` for typedefs
- Use `UpperCamelCase` for extensions

```dart
class ExerciseScreen extends StatelessWidget {}

enum ExerciseVersion { short, normal, long }

typedef ExerciseCallback = void Function(Exercise exercise);

extension StringExtensions on String {}
```

### Variables and Functions

- Use `lowerCamelCase` for variable names
- Use `lowerCamelCase` for function and method names
- Use `lowerCamelCase` for library prefixes

```dart
final currentUser = User();
void startExercise() {}

import 'exercise_screen.dart' as screen;
```

### Constants

- Use `lowerCamelCase` for constant variables

```dart
const defaultDuration = 300;
const maxPinnedExercises = 4;
```

### Private Members

- Use `_lowerCamelCase` (underscore prefix) for private class members
- Private members are only accessible within the same library

```dart
class ExerciseProvider {
  List<Exercise> _exercises = [];
  void _loadData() {}
}
```

## Documentation

### Comments

- Use `//` for inline comments
- Use `///` for documentation comments (DartDoc)
- Place comments above the code they refer to
- Write clear, concise comments that explain why, not what

### DartDoc

- Document all public APIs
- Start with a brief, single-sentence summary
- Use markdown for formatting
- Reference parameters with square brackets
- Provide examples when helpful

```dart
/// A breathing exercise with a specific pattern and duration.
///
/// The [pattern] defines the inhale-hold-exhale-hold timing.
/// The [duration] specifies how long the exercise should last in seconds.
class BreathingExercise {
  /// Creates an exercise with the given [pattern] and [duration].
  ///
  /// The [duration] must be positive.
  BreathingExercise(this.pattern, this.duration) : assert(duration > 0);
}
```

## Widget Structure

### Build Methods

- Keep build methods clean and readable
- Extract complex widgets into separate methods or classes
- Use meaningful names for extracted methods

```dart
class BreathingExerciseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(title: Text('Breathing Exercise'));
  }

  Widget _buildBody() {
    return Center(child: BreathingAnimation());
  }
}
```

### Widget Composition

- Prefer composition over deep nesting
- Extract reusable components into separate widgets
- Use private widgets for implementation details
- Prefer `const` constructors where possible

### StatefulWidget Lifecycle

```dart
@override
void initState() {
  super.initState();
  controller.addListener(_listener);
}

@override
void dispose() {
  controller.removeListener(_listener);
  controller.dispose();
  super.dispose();
}
```

## State Management

- Use Provider for application state management
- Keep providers focused and specific
- Use `ChangeNotifier` for simple state objects
- Separate business logic from UI logic
- Follow the single responsibility principle
- Always remove listeners in `dispose()` methods

### Provider Usage

```dart
class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
```

### Consuming State

```dart
// Using Consumer
Consumer<SettingsProvider>(
  builder: (context, settings, child) {
    return Text(settings.languagePreference.toString());
  },
)

// Using context.watch()
final settings = context.watch<SettingsProvider>();

// Using Provider.of (non-UI)
final settings = Provider.of<SettingsProvider>(context, listen: false);
```

## Types

- Use `const` constructors where possible
- Use `?` suffix for nullable types
- Use `final` for immutable variables
- Provide explicit type annotations for clarity in public APIs

```dart
const maxDuration = 600;

class Exercise {
  final String? id;
  final String pattern;
  final int duration;

  const Exercise({this.id, required this.pattern, required this.duration});
}
```

## Error Handling

- Use try-catch for async operations that may fail
- Use `??` operator for default values on nullable types
- Use `AppLogger` for logging
- Return defaults or throw meaningful exceptions

```dart
Future<String> loadExerciseData() async {
  try {
    final jsonString = await rootBundle.loadString('assets/exercises.json');
    return jsonString;
  } catch (e, stack) {
    AppLogger.error('Failed to load exercise data', e, stack);
    return '';
  }
}

String getExerciseTitle(Exercise? exercise) {
  return exercise?.title ?? 'Unknown Exercise';
}
```

## Logging

Use `AppLogger` for all logging needs:

```dart
import 'package:BreathSpace/logger.dart';

AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', exception, stackTrace);
```

### When to Use Each Level

- `debug()`: Development and debugging information
- `info()`: General information about app state
- `warning()`: Unexpected but recoverable situations
- `error()`: Errors that prevent normal operation

### Example Error Handling with Logging

```dart
Future<void> saveSettings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', 'dark');
    AppLogger.info('Settings saved successfully');
  } catch (e, stack) {
    AppLogger.error('Failed to save settings', e, stack);
  }
}
```

## Async Operations

- Use `async`/`await` for asynchronous code
- Use `Future<T>` return type for async functions
- Handle errors in async operations
- Use `WidgetsFlutterBinding.ensureInitialized()` before async operations in `main()`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadBreathingExercisesUsingSystemLocale();
  runApp(MyApp());
}

Future<void> loadExercises() async {
  try {
    final data = await loadExerciseData();
    AppLogger.info('Exercises loaded');
  } catch (e) {
    AppLogger.error('Failed to load exercises', e, null);
  }
}
```

## Localization

- Use `AppLocalizations.of(context)!.key` for UI strings
- After modifying ARB files, run `flutter gen-l10n`
- ARB template: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations.dart`

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.exerciseTitle_relaxingBreath)
```

## Formatting

Run the formatter before committing:

```bash
flutter format .
```

## Analysis

Run static analysis to check for issues:

```bash
flutter analyze
```

Fix analysis issues before committing changes.
