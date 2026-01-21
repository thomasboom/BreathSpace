# State Management

This document explains how state is managed in the BreathSpace application.

## Table of Contents

- [Overview](#overview)
- [Provider Pattern](#provider-pattern)
- [State Providers](#state-providers)
- [State Flow](#state-flow)
- [Best Practices](#best-practices)

## Overview

BreathSpace uses the Provider package for state management, which is a wrapper around InheritedWidget to make them more usable and reusable.

## Provider Pattern

We use the Provider pattern for:
- Global state management
- Dependency injection
- Rebuilding specific parts of the widget tree when state changes
- Persisting user preferences

### Basic Provider Usage

```dart
// Providing state
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadBreathingExercisesUsingSystemLocale();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PinnedExercisesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Consuming state
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Text('Language: ${settings.languagePreference}');
      },
    );
  }
}
```

## State Providers

### SettingsProvider

Manages user preferences and settings including language, music, voice guide, and view mode.

#### Properties

```dart
class SettingsProvider extends ChangeNotifier {
  LanguagePreference _languagePreference;
  bool _soundEffectsEnabled;
  MusicMode _musicMode;
  VoiceGuideMode _voiceGuideMode;
  ViewMode _viewMode;
  bool _aiKillSwitch;
}
```

#### Enums

- `LanguagePreference`: system, ar, bg, de, en, es, fr, hi, it, ja, ko, nl, pl, pt, ru, tr, zh
- `MusicMode`: off, nature, lofi, piano
- `VoiceGuideMode`: off, thomas
- `ViewMode`: list, ai, quiz

#### Methods

```dart
// Get locale based on language preference
Locale? get locale { ... }

// Set language preference
Future<void> setLanguagePreference(LanguagePreference pref) async { ... }

// Toggle sound effects
void toggleSoundEffects() { ... }

// Set music mode
Future<void> setMusicMode(MusicMode mode) async { ... }

// Set voice guide mode
Future<void> setVoiceGuideMode(VoiceGuideMode mode) async { ... }

// Set view mode
Future<void> setViewMode(ViewMode mode) async { ... }

// Toggle AI kill switch
void toggleAIKillSwitch() { ... }
```

#### Persistence

Settings are persisted using `shared_preferences`:
- `languagePreference`: String representation of enum
- `soundEffectsEnabled`: Boolean
- `musicMode`: String representation of enum
- `voiceGuideMode`: String representation of enum
- `viewMode`: String representation of enum
- `aiKillSwitch`: Boolean

### ThemeProvider

Manages theme mode preferences (system, light, dark, OLED).

#### Properties

```dart
class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode;
}
```

#### Enums

- `AppThemeMode`: system, light, dark, oled

#### Methods

```dart
// Set theme mode
Future<void> setThemeMode(AppThemeMode mode) async { ... }
```

#### Persistence

Theme mode is persisted using `shared_preferences`:
- `themeMode`: String representation ('light', 'dark', 'oled', or 'system')

#### Usage in UI

```dart
// Get MaterialThemeData based on theme mode
ThemeData getTheme(BuildContext context, bool isDarkMode) {
  switch (themeMode) {
    case AppThemeMode.light:
      return lightTheme;
    case AppThemeMode.dark:
      return darkTheme;
    case AppThemeMode.oled:
      return oledTheme;
    case AppThemeMode.system:
    default:
      return isDarkMode ? darkTheme : lightTheme;
  }
}
```

### PinnedExercisesProvider

Manages list of pinned exercises (up to 4 exercises can be pinned).

#### Properties

```dart
class PinnedExercisesProvider with ChangeNotifier {
  List<String> _pinnedExerciseTitles;
}
```

#### Methods

```dart
// Toggle pin status of an exercise
void togglePin(String exerciseTitle) { ... }

// Check if exercise is pinned
bool isPinned(String exerciseTitle) { ... }
```

#### Persistence

Pinned exercises are persisted using `shared_preferences`:
- `pinnedExercises`: List of exercise titles

#### Constraints

- Maximum 4 pinned exercises
- Duplicate pins are prevented
- Stores exercise titles (not full exercise objects)

## State Flow

1. **Initialization**: Providers are initialized at app startup in `main.dart`
2. **Loading**: Data is loaded from `shared_preferences` asynchronously
3. **User Interaction**: User actions trigger state changes through provider methods
4. **Notification**: Providers call `notifyListeners()` to notify state changes
5. **UI Update**: Widgets rebuild with new state using `Consumer` or `Provider.of()`
6. **Persistence**: State changes are saved to `shared_preferences`

### Example Flow

```dart
// 1. User selects a language
settingsProvider.setLanguagePreference(LanguagePreference.es);

// 2. UI updates to show selected language
Consumer<SettingsProvider>(
  builder: (context, provider, child) {
    return Text('Language: ${provider.languagePreference}');
  },
);

// 3. User pins an exercise
pinnedProvider.togglePin('Box Breathing');

// 4. Exercise list updates to show pinned indicator
Consumer<PinnedExercisesProvider>(
  builder: (context, pinnedProvider, child) {
    return ListTile(
      title: Text('Box Breathing'),
      trailing: pinnedProvider.isPinned('Box Breathing')
          ? Icon(Icons.push_pin)
          : null,
    );
  },
);
```

## Best Practices

1. **Keep providers focused**: Each provider should have a single responsibility
2. **Use immutable data**: Avoid mutating state directly; use methods that call `notifyListeners()`
3. **Minimize rebuilds**: Use `Consumer` widgets strategically to rebuild only necessary parts
4. **Handle async operations**: Use async/await in provider methods and update state appropriately
5. **Dispose resources**: Override `dispose()` method to clean up resources if needed
6. **Error handling**: Handle errors gracefully and log them using `AppLogger`
7. **Testing**: Write tests for provider methods to ensure correct state transitions
8. **Logging**: Use `AppLogger.debug()`, `AppLogger.info()`, `AppLogger.warning()`, `AppLogger.error()` for logging

### Example with Error Handling

```dart
class SettingsProvider extends ChangeNotifier {
  Future<void> setMusicMode(MusicMode mode) async {
    if (mode == _musicMode) return;
    AppLogger.debug('Setting music mode: ${mode.name}');
    _musicMode = mode;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('musicMode', mode.name);
      notifyListeners();
      AppLogger.info('Music mode saved: ${mode.name}');
    } catch (e, stack) {
      AppLogger.error('Failed to save music mode', e, stack);
    }
  }
}
```

### Accessing Providers

#### In build method (read-only)

```dart
final settings = context.watch<SettingsProvider>();
```

#### Outside build method

```dart
final settings = Provider.of<SettingsProvider>(context, listen: false);
```

#### Using Consumer

```dart
Consumer<SettingsProvider>(
  builder: (context, settings, child) {
    return Text(settings.languagePreference.toString());
  },
)
```

### Async Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadBreathingExercisesUsingSystemLocale();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PinnedExercisesProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

## Timer Management

Note that timer state is managed locally in `exercise_screen.dart` using `Ticker` and `AnimationController`, not through a separate TimerProvider. This keeps timer logic close to the UI that displays it and reduces the number of global providers.

### Local Timer State

```dart
class ExerciseScreenState extends State<ExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
}
```

### Advantages of Local Timer State

- Simplifies provider architecture
- Reduces cross-screen dependencies
- Timer is only needed when exercise is running
- State is naturally cleaned up when screen is disposed
