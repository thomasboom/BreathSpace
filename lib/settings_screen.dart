import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/theme_provider.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:BreathSpace/prompt_cache_service.dart'; // Import prompt cache service
import 'intro_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool fromExercise; // Flag to indicate if the settings were opened from the exercise screen
  const SettingsScreen({super.key, this.fromExercise = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return GestureDetector(
      onPanUpdate: (details) {
        // Detect left-to-right swipe to go back
        if (details.delta.dx > 0) { // Swiping right
          // Only navigate if the swipe is significant enough
          if (details.delta.dx > 5) {
            // If we came from an exercise, we should handle the navigation accordingly
            if (widget.fromExercise) {
              Navigator.of(context).pop(); // Just pop settings screen, let exercise screen handle the rest
            } else {
              Navigator.of(context).pop(); // Normal navigation for other cases
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings),
        ),
        body: ListView(
          children: [
            // Show stop exercise button only when accessed from exercise
            if (widget.fromExercise)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Return a value to indicate the exercise should be stopped
                    Navigator.of(context).pop('stop_exercise');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: Text(AppLocalizations.of(context).close),
                ),
              ),
            ListTile(
              title: Text(AppLocalizations.of(context).theme),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    themeProvider.setThemeMode(newValue);
                  }
                },
                items: <DropdownMenuItem<ThemeMode>>[
                  DropdownMenuItem<ThemeMode>(
                    value: ThemeMode.system,
                    child: Text(AppLocalizations.of(context).themeSystem),
                  ),
                  DropdownMenuItem<ThemeMode>(
                    value: ThemeMode.light,
                    child: Text(AppLocalizations.of(context).themeLight),
                  ),
                  DropdownMenuItem<ThemeMode>(
                    value: ThemeMode.dark,
                    child: Text(AppLocalizations.of(context).themeDark),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).language),
              trailing: DropdownButton<LanguagePreference>(
                value: settingsProvider.languagePreference,
                onChanged: (LanguagePreference? newValue) {
                  if (newValue != null) {
                    settingsProvider.setLanguagePreference(newValue);
                  }
                },
                items: <DropdownMenuItem<LanguagePreference>>[
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.system,
                    child: Text(AppLocalizations.of(context).languageSystem),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.ar,
                    child: Text(AppLocalizations.of(context).languageArabic),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.bg,
                    child: Text(AppLocalizations.of(context).languageBulgarian),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.de,
                    child: Text(AppLocalizations.of(context).languageGerman),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.en,
                    child: Text(AppLocalizations.of(context).languageEnglish),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.es,
                    child: Text(AppLocalizations.of(context).languageSpanish),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.fr,
                    child: Text(AppLocalizations.of(context).languageFrench),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.it,
                    child: Text(AppLocalizations.of(context).languageItalian),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.ja,
                    child: Text(AppLocalizations.of(context).languageJapanese),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.nl,
                    child: Text(AppLocalizations.of(context).languageDutch),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.pt,
                    child: Text(AppLocalizations.of(context).languagePortuguese),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.ru,
                    child: Text(AppLocalizations.of(context).languageRussian),
                  ),
                  DropdownMenuItem<LanguagePreference>(
                    value: LanguagePreference.zh,
                    child: Text(AppLocalizations.of(context).languageChinese),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context).autoSelectSearchBar),
              value: settingsProvider.autoSelectSearchBar,
              onChanged: (bool value) {
                settingsProvider.setAutoSelectSearchBar(value);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).voiceGuide),
              trailing: DropdownButton<VoiceGuideMode>(
                value: settingsProvider.voiceGuideMode,
                onChanged: (VoiceGuideMode? newValue) {
                  if (newValue != null) {
                    settingsProvider.setVoiceGuideMode(newValue);
                  }
                },
                items: <DropdownMenuItem<VoiceGuideMode>>[
                  DropdownMenuItem<VoiceGuideMode>(
                    value: VoiceGuideMode.off,
                    child: Text(AppLocalizations.of(context).voiceGuideOff),
                  ),
                  DropdownMenuItem<VoiceGuideMode>(
                    value: VoiceGuideMode.thomas,
                    child: Text(AppLocalizations.of(context).voiceGuideThomas),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("View Mode"),
              trailing: DropdownButton<ViewMode>(
                value: settingsProvider.viewMode,
                onChanged: (ViewMode? newValue) {
                  if (newValue != null) {
                    settingsProvider.setViewMode(newValue);
                  }
                },
                items: <DropdownMenuItem<ViewMode>>[
                  DropdownMenuItem<ViewMode>(
                    value: ViewMode.list,
                    child: Text("List View"),
                  ),
                  DropdownMenuItem<ViewMode>(
                    value: ViewMode.ai,
                    child: Text("AI Mode"),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).music),
              trailing: DropdownButton<MusicMode>(
                value: settingsProvider.musicMode,
                onChanged: (MusicMode? newValue) {
                  if (newValue != null) {
                    settingsProvider.setMusicMode(newValue);
                  }
                },
                items: <DropdownMenuItem<MusicMode>>[
                  DropdownMenuItem<MusicMode>(
                    value: MusicMode.off,
                    child: Text(AppLocalizations.of(context).musicOff),
                  ),
                  DropdownMenuItem<MusicMode>(
                    value: MusicMode.nature,
                    child: Text(AppLocalizations.of(context).musicNature),
                  ),
                  DropdownMenuItem<MusicMode>(
                    value: MusicMode.lofi,
                    child: Text(AppLocalizations.of(context).musicLofi),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).replayIntro),
              onTap: () async {
                final context = this.context;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen', false);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const IntroScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            // Prompt Cache Management Section
            FutureBuilder<int>(
              future: PromptCacheService.getCacheSize(),
              builder: (context, snapshot) {
                final cacheSize = snapshot.data ?? 0;
                return ListTile(
                  title: Text(AppLocalizations.of(context).promptCacheTitle),
                  subtitle: Text('${AppLocalizations.of(context).promptCacheSubtitle} ($cacheSize ${AppLocalizations.of(context).promptCacheEntries})'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await PromptCacheService.clearCache();
                      // Show a snackbar to confirm
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).promptCacheCleared)),
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context).promptCacheClear),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
