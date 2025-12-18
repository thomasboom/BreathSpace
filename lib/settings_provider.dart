import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguagePreference { system, ar, bg, de, en, es, fr, hi, it, ja, ko, nl, pl, pt, ru, tr, zh }
enum MusicMode { off, nature, lofi, piano }
enum VoiceGuideMode { off, thomas }
enum ViewMode { list, ai, quiz }

class SettingsProvider extends ChangeNotifier {
  bool _autoSelectSearchBar = false;
  LanguagePreference _languagePreference = LanguagePreference.system;
  bool _soundEffectsEnabled = true;
  MusicMode _musicMode = MusicMode.off;
  VoiceGuideMode _voiceGuideMode = VoiceGuideMode.off;
  ViewMode _viewMode = ViewMode.list;

  bool get autoSelectSearchBar => _autoSelectSearchBar;
  LanguagePreference get languagePreference => _languagePreference;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  MusicMode get musicMode => _musicMode;
  VoiceGuideMode get voiceGuideMode => _voiceGuideMode;
  ViewMode get viewMode => _viewMode;

  Locale? get locale {
    switch (_languagePreference) {
      case LanguagePreference.system:
        return null; // Follow system
      case LanguagePreference.ar:
        return const Locale('ar');
      case LanguagePreference.bg:
        return const Locale('bg');
      case LanguagePreference.de:
        return const Locale('de');
      case LanguagePreference.en:
        return const Locale('en');
      case LanguagePreference.es:
        return const Locale('es');
      case LanguagePreference.fr:
        return const Locale('fr');
      case LanguagePreference.hi:
        return const Locale('hi');
      case LanguagePreference.it:
        return const Locale('it');
      case LanguagePreference.ja:
        return const Locale('ja');
      case LanguagePreference.ko:
        return const Locale('ko');
      case LanguagePreference.nl:
        return const Locale('nl');
      case LanguagePreference.pl:
        return const Locale('pl');
      case LanguagePreference.pt:
        return const Locale('pt');
      case LanguagePreference.ru:
        return const Locale('ru');
      case LanguagePreference.tr:
        return const Locale('tr');
      case LanguagePreference.zh:
        return const Locale('zh');
    }
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoSelectSearchBar = prefs.getBool('autoSelectSearchBar') ?? false;
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    final viewModeString = prefs.getString('viewMode') ?? 'list';
    _viewMode = viewModeString == 'ai'
        ? ViewMode.ai
        : viewModeString == 'quiz'
            ? ViewMode.quiz
            : ViewMode.list;
    _voiceGuideMode = prefs.getString('voiceGuideMode') == 'thomas' 
        ? VoiceGuideMode.thomas 
        : VoiceGuideMode.off;
    final langString = prefs.getString('languagePreference');
    if (langString != null) {
      switch (langString) {
        case 'ar':
          _languagePreference = LanguagePreference.ar;
          break;
        case 'bg':
          _languagePreference = LanguagePreference.bg;
          break;
        case 'de':
          _languagePreference = LanguagePreference.de;
          break;
        case 'en':
          _languagePreference = LanguagePreference.en;
          break;
        case 'es':
          _languagePreference = LanguagePreference.es;
          break;
        case 'fr':
          _languagePreference = LanguagePreference.fr;
          break;
        case 'hi':
          _languagePreference = LanguagePreference.hi;
          break;
        case 'it':
          _languagePreference = LanguagePreference.it;
          break;
        case 'ja':
          _languagePreference = LanguagePreference.ja;
          break;
        case 'ko':
          _languagePreference = LanguagePreference.ko;
          break;
        case 'nl':
          _languagePreference = LanguagePreference.nl;
          break;
        case 'pl':
          _languagePreference = LanguagePreference.pl;
          break;
        case 'pt':
          _languagePreference = LanguagePreference.pt;
          break;
        case 'ru':
          _languagePreference = LanguagePreference.ru;
          break;
        case 'tr':
          _languagePreference = LanguagePreference.tr;
          break;
        case 'zh':
          _languagePreference = LanguagePreference.zh;
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
        case 'piano':
          _musicMode = MusicMode.piano;
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
      case LanguagePreference.ar:
        await prefs.setString('languagePreference', 'ar');
        break;
      case LanguagePreference.bg:
        await prefs.setString('languagePreference', 'bg');
        break;
      case LanguagePreference.de:
        await prefs.setString('languagePreference', 'de');
        break;
      case LanguagePreference.en:
        await prefs.setString('languagePreference', 'en');
        break;
      case LanguagePreference.es:
        await prefs.setString('languagePreference', 'es');
        break;
      case LanguagePreference.fr:
        await prefs.setString('languagePreference', 'fr');
        break;
      case LanguagePreference.hi:
        await prefs.setString('languagePreference', 'hi');
        break;
      case LanguagePreference.it:
        await prefs.setString('languagePreference', 'it');
        break;
      case LanguagePreference.ja:
        await prefs.setString('languagePreference', 'ja');
        break;
      case LanguagePreference.ko:
        await prefs.setString('languagePreference', 'ko');
        break;
      case LanguagePreference.nl:
        await prefs.setString('languagePreference', 'nl');
        break;
      case LanguagePreference.pl:
        await prefs.setString('languagePreference', 'pl');
        break;
      case LanguagePreference.pt:
        await prefs.setString('languagePreference', 'pt');
        break;
      case LanguagePreference.ru:
        await prefs.setString('languagePreference', 'ru');
        break;
      case LanguagePreference.tr:
        await prefs.setString('languagePreference', 'tr');
        break;
      case LanguagePreference.zh:
        await prefs.setString('languagePreference', 'zh');
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
      case MusicMode.piano:
        await prefs.setString('musicMode', 'piano');
        break;
    }
  }

  Future<void> setViewMode(ViewMode mode) async {
    _viewMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viewMode',
      mode == ViewMode.ai ? 'ai' :
      mode == ViewMode.quiz ? 'quiz' : 'list'
    );
  }

  Future<void> setVoiceGuideMode(VoiceGuideMode mode) async {
    _voiceGuideMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case VoiceGuideMode.off:
        await prefs.setString('voiceGuideMode', 'off');
        break;
      case VoiceGuideMode.thomas:
        await prefs.setString('voiceGuideMode', 'thomas');
        break;
    }
  }

}