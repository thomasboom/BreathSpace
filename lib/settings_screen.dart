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
          title: Text(
            AppLocalizations.of(context).settings,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.98),
              ],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: [
                // Show stop exercise button only when accessed from exercise
                if (widget.fromExercise) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        // Return a value to indicate the exercise should be stopped
                        Navigator.of(context).pop('stop_exercise');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).close,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
                // Appearance Section
                _buildSectionHeader('Appearance'),
                const SizedBox(height: 8),
                _buildSettingsCard(
                  title: AppLocalizations.of(context).theme,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeProvider.setThemeMode(newValue);
                        }
                      },
                      underline: const SizedBox(),
                      items: <DropdownMenuItem<ThemeMode>>[
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.system,
                          child: Text(
                            AppLocalizations.of(context).themeSystem,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.light,
                          child: Text(
                            AppLocalizations.of(context).themeLight,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<ThemeMode>(
                          value: ThemeMode.dark,
                          child: Text(
                            AppLocalizations.of(context).themeDark,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  title: AppLocalizations.of(context).language,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<LanguagePreference>(
                      value: settingsProvider.languagePreference,
                      onChanged: (LanguagePreference? newValue) {
                        if (newValue != null) {
                          settingsProvider.setLanguagePreference(newValue);
                        }
                      },
                      underline: const SizedBox(),
                      items: <DropdownMenuItem<LanguagePreference>>[
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.system,
                          child: Text(
                            AppLocalizations.of(context).languageSystem,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.ar,
                          child: Text(
                            AppLocalizations.of(context).languageArabic,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.bg,
                          child: Text(
                            AppLocalizations.of(context).languageBulgarian,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.de,
                          child: Text(
                            AppLocalizations.of(context).languageGerman,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.en,
                          child: Text(
                            AppLocalizations.of(context).languageEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.es,
                          child: Text(
                            AppLocalizations.of(context).languageSpanish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.fr,
                          child: Text(
                            AppLocalizations.of(context).languageFrench,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.it,
                          child: Text(
                            AppLocalizations.of(context).languageItalian,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.ja,
                          child: Text(
                            AppLocalizations.of(context).languageJapanese,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.nl,
                          child: Text(
                            AppLocalizations.of(context).languageDutch,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.pt,
                          child: Text(
                            AppLocalizations.of(context).languagePortuguese,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.ru,
                          child: Text(
                            AppLocalizations.of(context).languageRussian,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.zh,
                          child: Text(
                            AppLocalizations.of(context).languageChinese,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.hi,
                          child: Text(
                            AppLocalizations.of(context).languageHindi,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.ko,
                          child: Text(
                            AppLocalizations.of(context).languageKorean,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.pl,
                          child: Text(
                            AppLocalizations.of(context).languagePolish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<LanguagePreference>(
                          value: LanguagePreference.tr,
                          child: Text(
                            AppLocalizations.of(context).languageTurkish,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Behavior Section
                _buildSectionHeader('Behavior'),
                const SizedBox(height: 8),
                _buildSettingsCard(
                  title: AppLocalizations.of(context).autoSelectSearchBar,
                  trailing: Switch(
                    value: settingsProvider.autoSelectSearchBar,
                    onChanged: (bool value) {
                      settingsProvider.setAutoSelectSearchBar(value);
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  title: AppLocalizations.of(context).voiceGuide,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<VoiceGuideMode>(
                      value: settingsProvider.voiceGuideMode,
                      onChanged: (VoiceGuideMode? newValue) {
                        if (newValue != null) {
                          settingsProvider.setVoiceGuideMode(newValue);
                        }
                      },
                      underline: const SizedBox(),
                      items: <DropdownMenuItem<VoiceGuideMode>>[
                        DropdownMenuItem<VoiceGuideMode>(
                          value: VoiceGuideMode.off,
                          child: Text(
                            AppLocalizations.of(context).voiceGuideOff,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<VoiceGuideMode>(
                          value: VoiceGuideMode.thomas,
                          child: Text(
                            AppLocalizations.of(context).voiceGuideThomas,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  title: "View Mode",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<ViewMode>(
                      value: settingsProvider.viewMode,
                      onChanged: (ViewMode? newValue) {
                        if (newValue != null) {
                          settingsProvider.setViewMode(newValue);
                        }
                      },
                      underline: const SizedBox(),
                      items: <DropdownMenuItem<ViewMode>>[
                        DropdownMenuItem<ViewMode>(
                          value: ViewMode.list,
                          child: Text(
                            "List View",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<ViewMode>(
                          value: ViewMode.ai,
                          child: Text(
                            "AI Mode",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  title: AppLocalizations.of(context).music,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<MusicMode>(
                      value: settingsProvider.musicMode,
                      onChanged: (MusicMode? newValue) {
                        if (newValue != null) {
                          settingsProvider.setMusicMode(newValue);
                        }
                      },
                      underline: const SizedBox(),
                      items: <DropdownMenuItem<MusicMode>>[
                        DropdownMenuItem<MusicMode>(
                          value: MusicMode.off,
                          child: Text(
                            AppLocalizations.of(context).musicOff,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<MusicMode>(
                          value: MusicMode.nature,
                          child: Text(
                            AppLocalizations.of(context).musicNature,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DropdownMenuItem<MusicMode>(
                          value: MusicMode.lofi,
                          child: Text(
                            AppLocalizations.of(context).musicLofi,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Section
                _buildSectionHeader('Actions'),
                const SizedBox(height: 8),
                GestureDetector(
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
                  child: _buildSettingsCard(
                    title: AppLocalizations.of(context).replayIntro,
                    trailing: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Cache Management Section
                _buildSectionHeader('Cache'),
                const SizedBox(height: 8),
                FutureBuilder<int>(
                  future: PromptCacheService.getCacheSize(),
                  builder: (context, snapshot) {
                    final cacheSize = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).promptCacheTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppLocalizations.of(context).promptCacheSubtitle} ($cacheSize ${AppLocalizations.of(context).promptCacheEntries})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () async {
                                await PromptCacheService.clearCache();
                                // Show a snackbar to confirm
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context).promptCacheCleared),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                                setState(() {}); // Refresh the cache size
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).promptCacheClear,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
