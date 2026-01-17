import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/theme_provider.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:BreathSpace/pinned_exercises_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;
    late List<SharedPreferences> prefsInstances;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsInstances = [prefs];
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      prefsInstances.clear();
    });

    test('initial themeMode is system when no saved value', () async {
      expect(themeProvider.themeMode, AppThemeMode.system);
    });

    test('setThemeMode updates themeMode', () async {
      themeProvider.setThemeMode(AppThemeMode.dark);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(themeProvider.themeMode, AppThemeMode.dark);
    });

    test('setThemeMode saves to SharedPreferences', () async {
      themeProvider.setThemeMode(AppThemeMode.oled);
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'oled');
    });
  });

  group('SettingsProvider', () {
    late SettingsProvider settingsProvider;
    late List<SharedPreferences> prefsInstances;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsInstances = [prefs];
      settingsProvider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      prefsInstances.clear();
    });

    test('initial soundEffectsEnabled is true', () {
      expect(settingsProvider.soundEffectsEnabled, true);
    });

    test('initial viewMode is list', () {
      expect(settingsProvider.viewMode, ViewMode.list);
    });

    test('initial voiceGuideMode is off', () {
      expect(settingsProvider.voiceGuideMode, VoiceGuideMode.off);
    });

    test('setLanguagePreference updates languagePreference', () async {
      await settingsProvider.setLanguagePreference(LanguagePreference.es);
      expect(settingsProvider.languagePreference, LanguagePreference.es);
    });

    test('setLanguagePreference saves to SharedPreferences', () async {
      await settingsProvider.setLanguagePreference(LanguagePreference.de);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('languagePreference'), 'de');
    });

    test('setSoundEffectsEnabled updates soundEffectsEnabled', () async {
      await settingsProvider.setSoundEffectsEnabled(false);
      expect(settingsProvider.soundEffectsEnabled, false);
    });

    test('setSoundEffectsEnabled saves to SharedPreferences', () async {
      await settingsProvider.setSoundEffectsEnabled(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('soundEffectsEnabled'), false);
    });

    test('setViewMode updates viewMode', () async {
      await settingsProvider.setViewMode(ViewMode.ai);
      expect(settingsProvider.viewMode, ViewMode.ai);
    });

    test('setViewMode saves to SharedPreferences', () async {
      await settingsProvider.setViewMode(ViewMode.quiz);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('viewMode'), 'quiz');
    });

    test('setVoiceGuideMode updates voiceGuideMode', () async {
      await settingsProvider.setVoiceGuideMode(VoiceGuideMode.thomas);
      expect(settingsProvider.voiceGuideMode, VoiceGuideMode.thomas);
    });

    test('setVoiceGuideMode saves to SharedPreferences', () async {
      await settingsProvider.setVoiceGuideMode(VoiceGuideMode.thomas);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('voiceGuideMode'), 'thomas');
    });

    test('setMusicMode updates musicMode', () async {
      await settingsProvider.setMusicMode(MusicMode.nature);
      expect(settingsProvider.musicMode, MusicMode.nature);
    });

    test('setMusicMode saves to SharedPreferences', () async {
      await settingsProvider.setMusicMode(MusicMode.lofi);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('musicMode'), 'lofi');
    });

    test('locale returns null for system preference', () async {
      await settingsProvider.setLanguagePreference(LanguagePreference.system);
      expect(settingsProvider.locale, null);
    });

    test('locale returns correct locale for Spanish', () async {
      await settingsProvider.setLanguagePreference(LanguagePreference.es);
      expect(settingsProvider.locale, const Locale('es'));
    });

    test('loads saved settings correctly', () async {
      SharedPreferences.setMockInitialValues({
        'soundEffectsEnabled': false,
        'viewMode': 'ai',
        'voiceGuideMode': 'thomas',
        'languagePreference': 'fr',
        'musicMode': 'piano',
      });

      final newProvider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(newProvider.soundEffectsEnabled, false);
      expect(newProvider.viewMode, ViewMode.ai);
      expect(newProvider.voiceGuideMode, VoiceGuideMode.thomas);
      expect(newProvider.languagePreference, LanguagePreference.fr);
      expect(newProvider.musicMode, MusicMode.piano);
    });
  });

  group('PinnedExercisesProvider', () {
    late PinnedExercisesProvider pinnedProvider;
    late List<SharedPreferences> prefsInstances;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsInstances = [prefs];
      pinnedProvider = PinnedExercisesProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      prefsInstances.clear();
    });

    test('initial pinnedExerciseTitles is empty', () {
      expect(pinnedProvider.pinnedExerciseTitles, isEmpty);
    });

    test('togglePin adds exercise when not pinned', () async {
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(pinnedProvider.pinnedExerciseTitles, ['exercise-1']);
    });

    test('togglePin removes exercise when already pinned', () async {
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 100));
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(pinnedProvider.pinnedExerciseTitles, isEmpty);
    });

    test('togglePin limits to 4 pinned exercises', () async {
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 50));
      pinnedProvider.togglePin('exercise-2');
      await Future.delayed(const Duration(milliseconds: 50));
      pinnedProvider.togglePin('exercise-3');
      await Future.delayed(const Duration(milliseconds: 50));
      pinnedProvider.togglePin('exercise-4');
      await Future.delayed(const Duration(milliseconds: 50));
      pinnedProvider.togglePin('exercise-5');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(pinnedProvider.pinnedExerciseTitles.length, 4);
      expect(pinnedProvider.pinnedExerciseTitles.contains('exercise-5'), false);
    });

    test('isPinned returns true for pinned exercise', () async {
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 100));
      expect(pinnedProvider.isPinned('exercise-1'), true);
    });

    test('isPinned returns false for unpinned exercise', () {
      expect(pinnedProvider.isPinned('exercise-1'), false);
    });

    test('saves to SharedPreferences', () async {
      pinnedProvider.togglePin('exercise-1');
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('pinnedExercises'), ['exercise-1']);
    });

    test('loads from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'pinnedExercises': ['exercise-1', 'exercise-2'],
      });

      final newProvider = PinnedExercisesProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(newProvider.pinnedExerciseTitles, ['exercise-1', 'exercise-2']);
      expect(newProvider.isPinned('exercise-1'), true);
      expect(newProvider.isPinned('exercise-2'), true);
    });
  });

  group('AppThemeMode enum', () {
    test('has correct values', () {
      expect(AppThemeMode.values.length, 4);
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
      expect(AppThemeMode.values, contains(AppThemeMode.oled));
    });
  });

  group('LanguagePreference enum', () {
    test('has correct values', () {
      expect(LanguagePreference.values.length, 17);
      expect(LanguagePreference.values, contains(LanguagePreference.system));
      expect(LanguagePreference.values, contains(LanguagePreference.en));
      expect(LanguagePreference.values, contains(LanguagePreference.es));
    });
  });

  group('MusicMode enum', () {
    test('has correct values', () {
      expect(MusicMode.values.length, 4);
      expect(MusicMode.values, contains(MusicMode.off));
      expect(MusicMode.values, contains(MusicMode.nature));
      expect(MusicMode.values, contains(MusicMode.lofi));
      expect(MusicMode.values, contains(MusicMode.piano));
    });
  });

  group('VoiceGuideMode enum', () {
    test('has correct values', () {
      expect(VoiceGuideMode.values.length, 2);
      expect(VoiceGuideMode.values, contains(VoiceGuideMode.off));
      expect(VoiceGuideMode.values, contains(VoiceGuideMode.thomas));
    });
  });

  group('ViewMode enum', () {
    test('has correct values', () {
      expect(ViewMode.values.length, 3);
      expect(ViewMode.values, contains(ViewMode.list));
      expect(ViewMode.values, contains(ViewMode.ai));
      expect(ViewMode.values, contains(ViewMode.quiz));
    });
  });
}
