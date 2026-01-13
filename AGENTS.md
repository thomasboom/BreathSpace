# AGENTS.md

## Project Overview

BreathSpace is a Flutter breathing exercises and meditation app using Provider for state management, multi-language support (16 languages), and progressive exercises.

## Commands

### Development
```bash
flutter pub get              # Install dependencies
flutter gen-l10n            # Generate localization files (required after l10n changes)
flutter run                 # Run app
flutter run -d <device_id>  # Run on specific device
```

### Testing
```bash
flutter test                              # Run all tests
flutter test test/widget_test.dart         # Run specific test file
flutter test --coverage                    # Run tests with coverage
```

### Code Quality
```bash
flutter analyze            # Static analysis (enforced by analysis_options.yaml)
flutter format .          # Format code
```

### Building
```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build linux        # Linux
flutter build windows      # Windows
flutter build macos        # macOS
```

## Code Style

### Formatting
- 2 spaces for indentation
- Lines under 80 characters when practical
- Use trailing commas for better formatting
- Prefer single quotes for strings (commented in analysis_options.yaml but not enforced)

### Naming Conventions
- **Files**: `lowercase_with_underscores.dart`
- **Classes**: `UpperCamelCase`
- **Enums**: `UpperCamelCase`
- **Variables/Functions**: `lowerCamelCase`
- **Constants**: `lowerCamelCase`
- **Private members**: `_camelCase` (underscore prefix)
- **StatelessWidgets**: `WidgetName` (private subclass: `_WidgetName`)

### Imports
```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Show specific imports
import 'package:BreathSpace/relative/path.dart'; // Package imports from lib/
import 'relative_file.dart'; // Relative imports within same directory
```

### Types
- Use `const` constructors where possible
- Nullable types with `?` suffix
- Use `final` for immutable variables
- Explicit type annotations for clarity in public APIs

### Error Handling
- Use try-catch for async operations that may fail
- Use `??` operator for default values on nullable types
- Use `AppLogger.debug()`, `.info()`, `.warning()`, `.error()` for logging
- Return defaults or throw meaningful exceptions

### State Management
- Extend `ChangeNotifier` for providers
- Call `notifyListeners()` after state changes
- Use `Provider.of<T>(context, listen: false)` for non-UI logic
- Use `Consumer<T>` widget for UI that reacts to state changes
- Initialize providers in `main.dart` with `MultiProvider`
- Always remove listeners in `dispose()` methods

### Widgets
- Prefer `const` constructors
- Use `final` for widget properties
- Implement `build()` with early returns for clarity
- Use `setState()` with `mounted` check for async state updates

### Testing
- Use `testWidgets()` for widget tests
- Use `test()` for unit tests
- Call `await tester.pumpWidget()` to build widget
- Use `expect()` with finders (`find.byType()`, `find.text()`)
- Load exercises with `loadBreathingExercisesUsingSystemLocale()` before widget tests

### Localization
- UI strings: Use `AppLocalizations.of(context).key`
- After modifying ARB files: Run `flutter gen-l10n`
- ARB template: `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations.dart`

### Data Models
- Use `fromJson()` factory constructors for JSON parsing
- Use `const` constructors for immutable models
- Provide getter methods (e.g., `hasStages`, `hasVersions`)
- Support versioning with enum-based variant selection

## Key Patterns

### Async Initialization
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadBreathingExercisesUsingSystemLocale();
  runApp(...);
}
```

### Provider Usage in Widgets
```dart
final provider = Provider.of<MyProvider>(context, listen: false);
final provider = context.watch<MyProvider>();
```

### Lifecycle Management
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
