import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'settings_screen.dart'; // Import the new settings screen
import 'package:provider/provider.dart';
import 'package:OpenBreath/theme_provider.dart';
import 'package:OpenBreath/data.dart'; // Import the data file

import 'package:OpenBreath/settings_provider.dart'; // Import the new settings provider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const OpenBreathApp(),
    ),
  );
}

class OpenBreathApp extends StatelessWidget {
  const OpenBreathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      title: 'OpenBreath',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const BreathingExerciseScreen(),
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

  @override
  void initState() {
    super.initState();
    _filteredExercises = breathingExercises; // Initially show all exercises
    _searchController.addListener(_performSearch);

    // Auto-select search bar if setting is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.autoSelectSearchBar) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, size: 30, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Apply card-like margin
          child: Card(
            margin: EdgeInsets.zero, // Card will handle its own internal padding
            elevation: 0, // Remove card elevation if not desired for search bar
            color: Theme.of(context).cardColor, // Match card background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Apply rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Internal padding for text field
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round())),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                cursorColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = _filteredExercises[index];
          return Card(
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
                    builder: (context) => ExerciseScreen(pattern: exercise.pattern),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
