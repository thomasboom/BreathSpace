import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

enum ExerciseVersion {
  short,
  normal,
  long,
}


class ExerciseVersionData {
  final String? duration; // For simple exercises
  final String? pattern; // For simple exercises
  final List<BreathingStage>? stages; // For multi-stage exercises

  const ExerciseVersionData({
    this.duration,
    this.pattern,
    this.stages,
  });

  factory ExerciseVersionData.fromJson(Map<String, dynamic> json) {
    List<BreathingStage>? versionStages;
    if (json['stages'] != null) {
      versionStages = (json['stages'] as List)
          .map((stage) => BreathingStage._fromJson(stage))
          .toList();
    }

    return ExerciseVersionData(
      duration: json['duration'] as String?,
      pattern: json['pattern'] as String?,
      stages: versionStages,
    );
  }
}

class BreathingStage {
  final String title;
  final String pattern;
  final int duration; // in seconds
  final String? inhaleMethod; // New field for inhale method (nose/mouth)
  final String? exhaleMethod; // New field for exhale method (nose/mouth)

  const BreathingStage({
    required this.title,
    required this.pattern,
    required this.duration,
    this.inhaleMethod,
    this.exhaleMethod,
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
      inhaleMethod: json['inhale_method'] as String?, // Parse inhale method
      exhaleMethod: json['exhale_method'] as String?, // Parse exhale method
    );
  }

  factory BreathingStage._fromJson(Map<String, dynamic> json) {
    String titleText;
    if (json['title'] is String) {
      titleText = json['title'] as String;
    } else if (json['title'] is Map<String, dynamic>) {
      titleText = (json['title'] as Map<String, dynamic>)['en'] as String? ?? 'Untitled';
    } else {
      titleText = 'Untitled';
    }

    return BreathingStage(
      title: titleText,
      pattern: json['pattern'] as String,
      duration: json['duration'] as int,
      inhaleMethod: json['inhale_method'] as String?,
      exhaleMethod: json['exhale_method'] as String?,
    );
  }

  BreathingStage copyWith({
    String? title,
    String? pattern,
    int? duration,
    String? inhaleMethod,
    String? exhaleMethod,
  }) {
    return BreathingStage(
      title: title ?? this.title,
      pattern: pattern ?? this.pattern,
      duration: duration ?? this.duration,
      inhaleMethod: inhaleMethod ?? this.inhaleMethod,
      exhaleMethod: exhaleMethod ?? this.exhaleMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pattern': pattern,
      'duration': duration,
      'inhale_method': inhaleMethod,
      'exhale_method': exhaleMethod,
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
   final String? inhaleMethod; // New field for inhale method (nose/mouth)
   final String? exhaleMethod; // New field for exhale method (nose/mouth)
   final Map<ExerciseVersion, ExerciseVersionData>? versions; // Version-specific data

   const BreathingExercise({
     required this.id,
     required this.title,
     required this.pattern,
     required this.duration,
     required this.intro,
     this.stages,
     this.inhaleMethod,
     this.exhaleMethod,
     this.versions,
   });

  factory BreathingExercise.fromJson(Map<String, dynamic> json, String? languageCode) {
    List<BreathingStage>? stages;
    if (json['stages'] != null) {
      stages = (json['stages'] as List)
          .map((stage) => BreathingStage.fromJson(stage, languageCode))
          .toList();
    }

    // Parse versions data
    Map<ExerciseVersion, ExerciseVersionData>? versions;
    if (json['versions'] != null) {
      final versionsJson = json['versions'] as Map<String, dynamic>;
      versions = {};

      if (versionsJson['short'] != null) {
        versions[ExerciseVersion.short] = ExerciseVersionData.fromJson(versionsJson['short']);
      }
      if (versionsJson['normal'] != null) {
        versions[ExerciseVersion.normal] = ExerciseVersionData.fromJson(versionsJson['normal']);
      }
      if (versionsJson['long'] != null) {
        versions[ExerciseVersion.long] = ExerciseVersionData.fromJson(versionsJson['long']);
      }
    }

    String lang = languageCode ?? 'en';
    if (json['title'] is Map && json['title'][lang] == null) {
      lang = 'en';
    }

    return BreathingExercise(
      id: json['id'] as String,
      title: (json['title'] is Map) ? json['title'][lang] as String : json['title'] as String,
      pattern: json['pattern'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intro: (json['intro'] is Map) ? json['intro'][lang] as String : json['intro'] as String,
      stages: stages,
      inhaleMethod: json['inhale_method'] as String?, // Parse inhale method
      exhaleMethod: json['exhale_method'] as String?, // Parse exhale method
      versions: versions,
    );
  }

  bool get hasStages => stages != null && stages!.isNotEmpty;

  bool get hasVersions => versions != null && versions!.isNotEmpty;

  /// Get the exercise data for a specific version
  ExerciseVersionData? getVersionData(ExerciseVersion version) {
    return versions?[version];
  }

  /// Get the pattern for a specific version
  String getPatternForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.pattern ?? pattern;
  }

  /// Get the duration for a specific version
  String getDurationForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.duration ?? duration;
  }

  /// Get the stages for a specific version
  List<BreathingStage>? getStagesForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.stages ?? stages;
  }
}

List<BreathingExercise> breathingExercises = [];

Future<void> loadBreathingExercisesForLanguageCode(String? languageCode) async {
  const assetPath = 'assets/exercises.json';
  final String response = await rootBundle.loadString(assetPath);
  final List<dynamic> data = json.decode(response);
  breathingExercises =
      data.map((json) => BreathingExercise.fromJson(json, languageCode)).toList();

  if (kReleaseMode) {
    breathingExercises.removeWhere((exercise) => exercise.id == 'test-5-0-5-0');
  }
}

Future<void> loadBreathingExercisesUsingSystemLocale() async {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  await loadBreathingExercisesForLanguageCode(code);
}
