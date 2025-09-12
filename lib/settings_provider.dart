import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguagePreference { system, en, nl }
enum MusicMode { off, nature, lofi }

class SettingsProvider extends ChangeNotifier {
  bool _autoSelectSearchBar = false;
  LanguagePreference _languagePreference = LanguagePreference.system;
  bool _soundEffectsEnabled = true;
  MusicMode _musicMode = MusicMode.off;

  bool get autoSelectSearchBar => _autoSelectSearchBar;
  LanguagePreference get languagePreference => _languagePreference;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  MusicMode get musicMode => _musicMode;

  Locale? get locale {
    switch (_languagePreference) {
      case LanguagePreference.system:
        return null; // Follow system
      case LanguagePreference.en:
        return const Locale('en');
      case LanguagePreference.nl:
        return const Locale('nl');
    }
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoSelectSearchBar = prefs.getBool('autoSelectSearchBar') ?? false;
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    final langString = prefs.getString('languagePreference');
    if (langString != null) {
      switch (langString) {
        case 'en':
          _languagePreference = LanguagePreference.en;
          break;
        case 'nl':
          _languagePreference = LanguagePreference.nl;
          break;
        default:
          _languagePreference = LanguagePreference.system;
      }
    }
    final musicModeString = prefs.getString('musicMode');
    if (musicModeString != null) {
      switch (musicModeString) {
        case 'nature':
          _musicMode = MusicMode.nature;
          break;
        case 'lofi':
          _musicMode = MusicMode.lofi;
          break;
        default:
          _musicMode = MusicMode.off;
      }
    }
    notifyListeners();
  }

  Future<void> setAutoSelectSearchBar(bool value) async {
    _autoSelectSearchBar = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSelectSearchBar', value);
  }

  Future<void> setLanguagePreference(LanguagePreference preference) async {
    _languagePreference = preference;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (preference) {
      case LanguagePreference.system:
        await prefs.setString('languagePreference', 'system');
        break;
      case LanguagePreference.en:
        await prefs.setString('languagePreference', 'en');
        break;
      case LanguagePreference.nl:
        await prefs.setString('languagePreference', 'nl');
        break;
    }
  }

  Future<void> setSoundEffectsEnabled(bool value) async {
    _soundEffectsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', value);
  }

  Future<void> setMusicMode(MusicMode mode) async {
    _musicMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case MusicMode.off:
        await prefs.setString('musicMode', 'off');
        break;
      case MusicMode.nature:
        await prefs.setString('musicMode', 'nature');
        break;
      case MusicMode.lofi:
        await prefs.setString('musicMode', 'lofi');
        break;
    }
  }
}