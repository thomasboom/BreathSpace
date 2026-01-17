import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/logger.dart';

class PinnedExercisesProvider with ChangeNotifier {
  static const String _pinnedExercisesKey = 'pinnedExercises';
  List<String> _pinnedExerciseTitles = [];

  List<String> get pinnedExerciseTitles => _pinnedExerciseTitles;

  PinnedExercisesProvider() {
    _loadPinnedExercises();
  }

  Future<void> _loadPinnedExercises() async {
    AppLogger.debug('Loading pinned exercises');
    try {
      final prefs = await SharedPreferences.getInstance();
      _pinnedExerciseTitles = prefs.getStringList(_pinnedExercisesKey) ?? [];
      notifyListeners();
      AppLogger.info('Loaded ${_pinnedExerciseTitles.length} pinned exercises');
    } catch (e, stack) {
      AppLogger.error('Failed to load pinned exercises', e, stack);
    }
  }

  Future<void> _savePinnedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedExercisesKey, _pinnedExerciseTitles);
  }

  void togglePin(String exerciseTitle) {
    final isPinned = _pinnedExerciseTitles.contains(exerciseTitle);
    if (isPinned) {
      _pinnedExerciseTitles.remove(exerciseTitle);
      AppLogger.debug('Unpinned exercise: $exerciseTitle');
    } else {
      if (_pinnedExerciseTitles.length < 4) {
        _pinnedExerciseTitles.add(exerciseTitle);
        AppLogger.debug('Pinned exercise: $exerciseTitle');
      } else {
        AppLogger.warning('Cannot pin more than 4 exercises');
        return;
      }
    }
    _savePinnedExercises();
    notifyListeners();
  }

  bool isPinned(String exerciseTitle) {
    return _pinnedExerciseTitles.contains(exerciseTitle);
  }
}
