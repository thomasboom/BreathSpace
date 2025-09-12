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

  factory BreathingStage.fromJson(Map<String, dynamic> json, String? languageCode) {
    String lang = languageCode ?? 'en';
    String titleText;
    
    // Handle both old format (simple string) and new format (translation map)
    if (json['title'] is String) {
      titleText = json['title'] as String;
    } else if (json['title'] is Map<String, dynamic>) {
      final titleMap = json['title'] as Map<String, dynamic>;
      if (titleMap[lang] != null) {
        titleText = titleMap[lang] as String;
      } else {
        titleText = titleMap['en'] as String? ?? 'Untitled';
      }
    } else {
      titleText = 'Untitled';
    }

    return BreathingStage(
      title: titleText,
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
  final String id;
  final String title;
  final String pattern; // For backward compatibility
  final String duration; // For backward compatibility
  final String intro;
  final List<BreathingStage>? stages; // For progressive stages

  const BreathingExercise({
    required this.id,
    required this.title,
    required this.pattern,
    required this.duration,
    required this.intro,
    this.stages,
  });

  factory BreathingExercise.fromJson(Map<String, dynamic> json, String? languageCode) {
    List<BreathingStage>? stages;
    if (json['stages'] != null) {
      stages = (json['stages'] as List)
          .map((stage) => BreathingStage.fromJson(stage, languageCode))
          .toList();
    }

    String lang = languageCode ?? 'en';
    if (json['title'][lang] == null) {
      lang = 'en';
    }

    return BreathingExercise(
      id: json['id'] as String,
      title: json['title'][lang] as String,
      pattern: json['pattern'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intro: json['intro'][lang] as String,
      stages: stages,
    );
  }

  bool get hasStages => stages != null && stages!.isNotEmpty;
}

late List<BreathingExercise> breathingExercises = [];

Future<void> loadBreathingExercisesForLanguageCode(String? languageCode) async {
  const assetPath = 'assets/exercises.json';
  final String response = await rootBundle.loadString(assetPath);
  final List<dynamic> data = json.decode(response);
  breathingExercises =
      data.map((json) => BreathingExercise.fromJson(json, languageCode)).toList();
}

Future<void> loadBreathingExercisesUsingSystemLocale() async {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  await loadBreathingExercisesForLanguageCode(code);
}
