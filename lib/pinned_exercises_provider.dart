import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedExercisesProvider with ChangeNotifier {
  static const String _pinnedExercisesKey = 'pinnedExercises';
  List<String> _pinnedExerciseTitles = [];

  List<String> get pinnedExerciseTitles => _pinnedExerciseTitles;

  PinnedExercisesProvider() {
    _loadPinnedExercises();
  }

  Future<void> _loadPinnedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    _pinnedExerciseTitles = prefs.getStringList(_pinnedExercisesKey) ?? [];
    notifyListeners();
  }

  Future<void> _savePinnedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedExercisesKey, _pinnedExerciseTitles);
  }

  void togglePin(String exerciseTitle) {
    if (_pinnedExerciseTitles.contains(exerciseTitle)) {
      _pinnedExerciseTitles.remove(exerciseTitle);
    } else {
      if (_pinnedExerciseTitles.length < 4) { // Limit to 4 pinned exercises
        _pinnedExerciseTitles.add(exerciseTitle);
      } else {
        // Optionally, you could notify the user that they can only pin up to 4 exercises.
        // For now, we'll just prevent adding more than 4.
      }
    }
    _savePinnedExercises();
    notifyListeners();
  }

  bool isPinned(String exerciseTitle) {
    return _pinnedExerciseTitles.contains(exerciseTitle);
  }
}
