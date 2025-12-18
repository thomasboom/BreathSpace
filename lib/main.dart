import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:BreathSpace/exercise_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart'; // Import the new settings screen
import 'package:provider/provider.dart';
import 'package:BreathSpace/theme_provider.dart';
import 'package:BreathSpace/data.dart'; // Import the data file

import 'package:BreathSpace/settings_provider.dart'; // Import the new settings provider
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:BreathSpace/pinned_exercises_provider.dart';

import 'intro_screen.dart';
import 'package:BreathSpace/gemini_exercise_screen.dart';
import 'package:BreathSpace/quiz_exercise_screen.dart';
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
      child: BreathSpaceApp(seen: seen),
    ),
  );
}

class BreathSpaceApp extends StatelessWidget {
  final bool seen;
  const BreathSpaceApp({super.key, required this.seen});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      primaryColor: const Color(0xFF1A1A1A),
      fontFamily: 'GFS Didot',
      cardColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A1A1A),
        secondary: Color(0xFF2A2A2A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1A1A1A),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      primaryColor: const Color(0xFFF5F5F5),
      fontFamily: 'GFS Didot',
      cardColor: const Color(0xFF1A1A1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF5F5F5),
        secondary: Color(0xFFE0E0E0),
        surface: Color(0xFF1A1A1A),
        onSurface: Color(0xFFF5F5F5),
        onPrimary: Color(0xFF0F0F0F),
        onSecondary: Color(0xFF0F0F0F),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
          ? settingsProvider.viewMode == ViewMode.list
              ? const BreathingExerciseScreen()
              : settingsProvider.viewMode == ViewMode.ai
                  ? const GeminiExerciseScreen()
                  : const QuizExerciseScreen()
          : const IntroScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/exercise/') == true) {
          final exerciseId = settings.name?.substring('/exercise/'.length);
          if (exerciseId != null && exerciseId.isNotEmpty) {
            final exercise = breathingExercises.firstWhere(
              (exercise) => exercise.id == exerciseId,
              orElse: () => breathingExercises.first,
            );
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ExerciseDetailScreen(exercise: exercise),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            );
          }
        }
        return null; // Let the framework handle other routes
      },
    );
  }
}

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<BreathingExercise> _filteredExercises = [];
  List<BreathingExercise> _pinnedExercises = [];
  VoidCallback? _settingsListener;
  late final PinnedExercisesProvider _pinnedExercisesProvider;
  late final SettingsProvider _settingsProvider;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer

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

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Auto-select search bar if setting is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _settingsProvider.autoSelectSearchBar) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
      // Start fade animation after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fadeController.dispose();

    _pinnedExercisesProvider.removeListener(_updatePinnedExercises);
    if (_settingsListener != null) {
      _settingsProvider.removeListener(_settingsListener!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes to prevent unresponsiveness
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Pause animation when app goes to background
        if (_fadeController.isAnimating) {
          _fadeController.stop();
        }
        break;
      case AppLifecycleState.resumed:
        // Resume animation when app comes back to foreground
        if (!_fadeController.isAnimating && _fadeController.value < 1.0) {
          _fadeController.forward();
        }
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
    }
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
      case LanguagePreference.ar:
        await loadBreathingExercisesForLanguageCode('ar');
        break;
      case LanguagePreference.bg:
        await loadBreathingExercisesForLanguageCode('bg');
        break;
      case LanguagePreference.de:
        await loadBreathingExercisesForLanguageCode('de');
        break;
      case LanguagePreference.en:
        await loadBreathingExercisesForLanguageCode('en');
        break;
      case LanguagePreference.es:
        await loadBreathingExercisesForLanguageCode('es');
        break;
      case LanguagePreference.fr:
        await loadBreathingExercisesForLanguageCode('fr');
        break;
      case LanguagePreference.hi:
        await loadBreathingExercisesForLanguageCode('hi');
        break;
      case LanguagePreference.it:
        await loadBreathingExercisesForLanguageCode('it');
        break;
      case LanguagePreference.ja:
        await loadBreathingExercisesForLanguageCode('ja');
        break;
      case LanguagePreference.ko:
        await loadBreathingExercisesForLanguageCode('ko');
        break;
      case LanguagePreference.nl:
        await loadBreathingExercisesForLanguageCode('nl');
        break;
      case LanguagePreference.pl:
        await loadBreathingExercisesForLanguageCode('pl');
        break;
      case LanguagePreference.pt:
        await loadBreathingExercisesForLanguageCode('pt');
        break;
      case LanguagePreference.ru:
        await loadBreathingExercisesForLanguageCode('ru');
        break;
      case LanguagePreference.tr:
        await loadBreathingExercisesForLanguageCode('tr');
        break;
      case LanguagePreference.zh:
        await loadBreathingExercisesForLanguageCode('zh');
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

  String _getTotalDuration(BreathingExercise exercise) {
    if (!exercise.hasStages) {
      return exercise.duration;
    }
    int totalSeconds = 0;
    for (var stage in exercise.stages!) {
      totalSeconds += stage.duration;
    }
    return '${(totalSeconds / 60).ceil()} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              cursorWidth: 2,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Add spacing between search bar and content only when there are pinned exercises
            if (_pinnedExercises.isNotEmpty && _searchController.text.isEmpty)
              const SizedBox(height: 16), // Spacing when pinned exercises are shown
            if (_pinnedExercises.isNotEmpty && _searchController.text.isEmpty)
            SizedBox(
              height: 160,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final availableWidth = screenWidth - 32; // Subtract horizontal padding (16 + 16)
                  final totalMargin = (_pinnedExercises.length - 1) * 8; // Margin between items (4 + 4 per gap)
                  final itemWidth = (availableWidth - totalMargin) / _pinnedExercises.length;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _pinnedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _pinnedExercises[index];
                      return Dismissible(
                        key: Key('pinned_${exercise.title}'),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4.0,
                            right: index == _pinnedExercises.length - 1 ? 0 : 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Icon(
                            Icons.push_pin_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        secondaryBackground: Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4.0,
                            right: index == _pinnedExercises.length - 1 ? 0 : 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.push_pin_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          _pinnedExercisesProvider.togglePin(exercise.title);
                          return false; // Don't actually dismiss the item
                        },
                        child: Container(
                          width: itemWidth, // Divide space equally among all pinned exercises
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4.0,
                            right: index == _pinnedExercises.length - 1 ? 0 : 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.spa_outlined,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: Text(
                                    exercise.title,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  exercise.hasStages ? _getTotalDuration(exercise) : exercise.duration,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExerciseDetailScreen(exercise: exercise),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context).start,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.search_off_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context).noExercisesFound,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search terms',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Dismissible(
                        key: Key(exercise.title),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Icon(
                            _pinnedExercisesProvider.isPinned(exercise.title) ? Icons.push_pin : Icons.push_pin_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(
                            _pinnedExercisesProvider.isPinned(exercise.title) ? Icons.push_pin : Icons.push_pin_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          _pinnedExercisesProvider.togglePin(exercise.title);
                          return false; // Don't actually dismiss the item
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(20.0),
                            title: Text(
                              exercise.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  exercise.hasStages
                                      ? '${AppLocalizations.of(context).progressive} • ${_getTotalDuration(exercise)}'
                                      : '${exercise.pattern} • ${exercise.duration}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  exercise.intro,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
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
      ),
    );
  }
}
