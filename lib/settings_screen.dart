import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OpenBreath/theme_provider.dart';
import 'package:OpenBreath/settings_provider.dart';
import 'package:OpenBreath/l10n/app_localizations.dart';
import 'package:OpenBreath/prompt_cache_service.dart'; // Import prompt cache service
import 'intro_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: ListView(
        children: [
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
                  value: LanguagePreference.en,
                  child: Text(AppLocalizations.of(context).languageEnglish),
                ),
                DropdownMenuItem<LanguagePreference>(
                  value: LanguagePreference.nl,
                  child: Text(AppLocalizations.of(context).languageDutch),
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
          SwitchListTile(
            title: Text(AppLocalizations.of(context).soundEffects),
            value: settingsProvider.soundEffectsEnabled,
            onChanged: (bool value) {
              settingsProvider.setSoundEffectsEnabled(value);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).useListView),
            value: settingsProvider.useListView,
            onChanged: (bool value) {
              settingsProvider.setUseListView(value);
            },
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seen', false);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const IntroScreen()),
                (route) => false,
              );
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
    );
  }
}
