import 'package:flutter/material.dart';
import 'package:BreathSpace/widgets/kids_bubble_widget.dart';
import 'package:BreathSpace/widgets/emotion_selector_widget.dart';
import 'package:BreathSpace/kids_mode_exercise_screen.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';

enum ExerciseLength { short, normal, long }

class KidsModeSelectionScreen extends StatefulWidget {
  const KidsModeSelectionScreen({super.key});

  @override
  State<KidsModeSelectionScreen> createState() =>
      _KidsModeSelectionScreenState();
}

class _KidsModeSelectionScreenState extends State<KidsModeSelectionScreen> {
  Emotion? _selectedEmotion;
  bool _showStartButton = false;
  ExerciseLength _selectedLength = ExerciseLength.normal;

  void _onEmotionSelected(Emotion emotion) {
    setState(() {
      _selectedEmotion = emotion;
      _showStartButton = true;
    });
  }

  void _onStartPressed() {
    if (_selectedEmotion != null) {
      final totalCycles = switch (_selectedLength) {
        ExerciseLength.short => 10,
        ExerciseLength.normal => 15,
        ExerciseLength.long => 25,
      };

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              KidsModeExerciseScreen(
                emotion: _selectedEmotion!,
                totalCycles: totalCycles,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _onExitKidsMode() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    await settingsProvider.setKidsMode(false);

    if (!mounted) return;

    // Navigate back to main screen by replacing the current route
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showLanguageSelector() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLanguageOption(
                          '🇺🇸',
                          'English',
                          LanguagePreference.en,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇳🇱',
                          'Nederlands',
                          LanguagePreference.nl,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇩🇪',
                          'Deutsch',
                          LanguagePreference.de,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇪🇸',
                          'Español',
                          LanguagePreference.es,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇫🇷',
                          'Français',
                          LanguagePreference.fr,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇮🇹',
                          'Italiano',
                          LanguagePreference.it,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇵🇹',
                          'Português',
                          LanguagePreference.pt,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇸🇦',
                          'العربية',
                          LanguagePreference.ar,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇧🇬',
                          'Български',
                          LanguagePreference.bg,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇯🇵',
                          '日本語',
                          LanguagePreference.ja,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇷🇺',
                          'Русский',
                          LanguagePreference.ru,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇨🇳',
                          '中文',
                          LanguagePreference.zh,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇮🇳',
                          'हिंदी',
                          LanguagePreference.hi,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇰🇷',
                          '한국어',
                          LanguagePreference.ko,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇵🇱',
                          'Polski',
                          LanguagePreference.pl,
                          settingsProvider,
                        ),
                        _buildLanguageOption(
                          '🇹🇷',
                          'Türkçe',
                          LanguagePreference.tr,
                          settingsProvider,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String flag,
    String name,
    LanguagePreference preference,
    SettingsProvider settingsProvider,
  ) {
    final isSelected = settingsProvider.languagePreference == preference;

    return GestureDetector(
      onTap: () async {
        await settingsProvider.setLanguagePreference(preference);
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.purple.shade700
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWelcomeText() {
    final l10n = AppLocalizations.of(context);
    if (_selectedEmotion == null) {
      return l10n.kidsWelcome;
    } else {
      return l10n.kidsStartAdventure;
    }
  }

  Widget _buildLengthOption(ExerciseLength length) {
    final l10n = AppLocalizations.of(context);
    final isSelected = _selectedLength == length;

    final label = switch (length) {
      ExerciseLength.short => l10n.kidsShort,
      ExerciseLength.normal => l10n.kidsNormal,
      ExerciseLength.long => l10n.kidsLong,
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLength = length;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.shade100
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade100, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with language switcher and exit kids mode button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Language switcher button
                    GestureDetector(
                      onTap: _showLanguageSelector,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Colors.purple.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Exit kids mode button
                    GestureDetector(
                      onTap: _onExitKidsMode,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.purple.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 40),

                // Breathing buddy with speech
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KidsBubbleWidget(
                        speechText: _getWelcomeText(),
                        size: 160,
                        bubbleColor: Colors.purple,
                        isAnimating: false,
                        showFace: true,
                      ),

                      const SizedBox(height: 40),

                      // Either emotion selector or start button
                      if (!_showStartButton)
                        Expanded(
                          child: EmotionSelectorWidget(
                            onEmotionSelected: _onEmotionSelected,
                            constrainWidth: false,
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                AppLocalizations.of(context).kidsChooseLength,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLengthOption(ExerciseLength.short),
                                  const SizedBox(width: 15),
                                  _buildLengthOption(ExerciseLength.normal),
                                  const SizedBox(width: 15),
                                  _buildLengthOption(ExerciseLength.long),
                                ],
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: _onStartPressed,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 80,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedEmotion!.color.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).kidsStart,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Allow re-selection
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showStartButton = false;
                                    _selectedEmotion = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).kidsChooseDifferentFeeling,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
