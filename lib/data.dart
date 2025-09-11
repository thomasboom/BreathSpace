import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

class BreathingPattern {
  final String pattern;
  final int duration; // in seconds

  const BreathingPattern({
    required this.pattern,
    required this.duration,
  });

  factory BreathingPattern.fromJson(Map<String, dynamic> json) {
    return BreathingPattern(
      pattern: json['pattern'] as String,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'duration': duration,
    };
  }
}

class BreathingStage {
  final String title;
  final String pattern;
  final int duration; // in seconds

  const BreathingStage({
    required this.title,
    required this.pattern,
    required this.duration,
  });

  factory BreathingStage.fromJson(Map<String, dynamic> json) {
    return BreathingStage(
      title: json['title'] as String,
      pattern: json['pattern'] as String,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pattern': pattern,
      'duration': duration,
    };
  }
}

class BreathingExercise {
  final String title;
  final String pattern; // For backward compatibility
  final String duration; // For backward compatibility
  final String intro;
  final List<BreathingStage>? stages; // For progressive stages

  const BreathingExercise({
    required this.title,
    required this.pattern,
    required this.duration,
    required this.intro,
    this.stages,
  });

  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    List<BreathingStage>? stages;
    if (json['stages'] != null) {
      stages = (json['stages'] as List)
          .map((stage) => BreathingStage.fromJson(stage))
          .toList();
    }

    return BreathingExercise(
      title: json['title'] as String,
      pattern: json['pattern'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      stages: stages,
    );
  }

  bool get hasStages => stages != null && stages!.isNotEmpty;
}

late List<BreathingExercise> breathingExercises = [];

String _assetForLanguageCode(String? languageCode) {
  switch (languageCode) {
    case 'nl':
      return 'assets/exercises-nl.json';
    case 'en':
    default:
      return 'assets/exercises-en.json';
  }
}

Future<void> loadBreathingExercisesForLanguageCode(String? languageCode) async {
  final assetPath = _assetForLanguageCode(languageCode);
  final String response = await rootBundle.loadString(assetPath);
  final List<dynamic> data = json.decode(response);
  breathingExercises = data.map((json) => BreathingExercise.fromJson(json)).toList();
}

Future<void> loadBreathingExercisesUsingSystemLocale() async {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  await loadBreathingExercisesForLanguageCode(code);
}
