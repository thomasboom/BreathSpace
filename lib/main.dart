import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:OpenBreath/exercise_screen.dart';
import 'package:OpenBreath/exercise_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart'; // Import the new settings screen
import 'package:provider/provider.dart';
import 'package:OpenBreath/theme_provider.dart';
import 'package:OpenBreath/data.dart'; // Import the data file

import 'package:OpenBreath/settings_provider.dart'; // Import the new settings provider
import 'package:OpenBreath/l10n/app_localizations.dart';
import 'package:OpenBreath/pinned_exercises_provider.dart';

import 'intro_screen.dart';
import 'package:OpenBreath/gemini_exercise_screen.dart';
import 'package:OpenBreath/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load .env file
  await loadBreathingExercisesUsingSystemLocale(); // Load exercises before app starts
  final prefs = await SharedPreferences.getInstance();
  final bool seen = prefs.getBool('seen') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => PinnedExercisesProvider()),
      ],
      child: OpenBreathApp(seen: seen),
    ),
  );
}

class OpenBreathApp extends StatelessWidget {
  final bool seen;
  const OpenBreathApp({super.key, required this.seen});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.black,
      fontFamily: 'GFS Didot',
      cardColor: Colors.grey[200], // Card color for light mode
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.black, // A color for the bubble in light mode
        onSurface: Colors.black,
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      fontFamily: 'GFS Didot',
      cardColor: Colors.grey[900], // Card color for dark mode
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white, // A color for the bubble in dark mode
        onSurface: Colors.white,
      ),
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: settingsProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: seen
          ? const GeminiExerciseScreen()
          : const IntroScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<BreathingExercise> _filteredExercises = [];
  List<BreathingExercise> _pinnedExercises = [];
  VoidCallback? _settingsListener;
  late final PinnedExercisesProvider _pinnedExercisesProvider;
  late final SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);

    _pinnedExercisesProvider = Provider.of<PinnedExercisesProvider>(context, listen: false);
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    _pinnedExercisesProvider.addListener(_updatePinnedExercises);
    _updatePinnedExercises(); // Initial load of pinned exercises

    // Initial load of exercises based on language
    _loadExercisesForCurrentLanguage();

    // Reload exercises when language changes
    _settingsListener = () {
      _loadExercisesForCurrentLanguage();
    };
    _settingsProvider.addListener(_settingsListener!);

    // Auto-select search bar if setting is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _settingsProvider.autoSelectSearchBar) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    
    _pinnedExercisesProvider.removeListener(_updatePinnedExercises);
    if (_settingsListener != null) {
      _settingsProvider.removeListener(_settingsListener!);
    }
    super.dispose();
  }

  

  void _updatePinnedExercises() {
    if (!mounted) return;
    setState(() {
      _pinnedExercises = breathingExercises
          .where((exercise) => _pinnedExercisesProvider.isPinned(exercise.title))
          .toList();
      _performSearch(); // Re-filter exercises after pinned list changes
    });
  }

  Future<void> _loadExercisesForCurrentLanguage() async {
    if (!mounted) return;
    switch (_settingsProvider.languagePreference) {
      case LanguagePreference.system:
        await loadBreathingExercisesUsingSystemLocale();
        break;
      case LanguagePreference.en:
        await loadBreathingExercisesForLanguageCode('en');
        break;
      case LanguagePreference.nl:
        await loadBreathingExercisesForLanguageCode('nl');
        break;
    }
    // Update pinned and filter after loading
    _updatePinnedExercises();
  }


  void _performSearch() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredExercises = breathingExercises.where((exercise) {
        return exercise.title.toLowerCase().contains(query) ||
            exercise.pattern.toLowerCase().contains(query) ||
            exercise.intro.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // Remove default title spacing
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Keep scaffold background for app bar itself
        title: Column(
          children: [
            const SizedBox(height: 8.0), // Add space at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Apply card-like margin
              child: Card(
                margin: EdgeInsets.zero, // Card will handle its own internal padding
                elevation: 0, // Remove card elevation if not desired for search bar
                color: Theme.of(context).cardColor, // Match card background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Apply rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Internal padding for text field
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchHint,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round())),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.settings_outlined, size: 24, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ), // Closing parenthesis for Card
            ), // Closing parenthesis for Padding
          ], // Closing bracket for children list
        ), // Closing parenthesis for Column
      ),
      body: Column(
        children: [
          if (_pinnedExercises.isNotEmpty && _searchController.text.isEmpty)
            SizedBox(
              height: 150, // Height for the pinned exercises row
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pinnedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _pinnedExercises[index];
                  return GestureDetector(
                    onLongPress: () {
                      _pinnedExercisesProvider.togglePin(exercise.title);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      color: Theme.of(context).cardColor,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / (_pinnedExercises.length > 0 ? _pinnedExercises.length : 1) - 32, // Divide available width by number of pinned exercises
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                exercise.title,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.pattern,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(), // Pushes content to top and button to bottom
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailScreen(exercise: exercise),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary, // Button background color
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary, // Button text color
                                ),
                                child: Text(AppLocalizations.of(context).start),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _filteredExercises.isEmpty && _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ':-',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context).noExercisesFound,
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return GestureDetector(
                        onLongPress: () {
                          _pinnedExercisesProvider.togglePin(exercise.title);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            title: Text(exercise.title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                            subtitle: Text(
                              '${exercise.pattern} - ${exercise.duration}\n${exercise.intro}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(exercise: exercise),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
