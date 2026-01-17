import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';
import 'package:BreathSpace/logger.dart';

enum ExerciseVersion { short, normal, long }

class PhaseInstruction {
  final String instructionKey;
  final int? startOffset;
  final int? endOffset;

  const PhaseInstruction({
    required this.instructionKey,
    this.startOffset,
    this.endOffset,
  });

  factory PhaseInstruction.fromJson(Map<String, dynamic> json) {
    return PhaseInstruction(
      instructionKey: json['instruction_key'] as String,
      startOffset: json['start_offset'] as int?,
      endOffset: json['end_offset'] as int?,
    );
  }

  bool isActive(int elapsedSecondsInPhase) {
    final start = startOffset ?? 0;
    final end = endOffset ?? 999999; // Large number instead of infinity
    return elapsedSecondsInPhase >= start && elapsedSecondsInPhase < end;
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction_key': instructionKey,
      'start_offset': startOffset,
      'end_offset': endOffset,
    };
  }
}

class ExerciseVersionData {
  final String? duration;
  final String? pattern;
  final List<BreathingStage>? stages;
  final List<int>? stageDurations;

  const ExerciseVersionData({
    this.duration,
    this.pattern,
    this.stages,
    this.stageDurations,
  });

  factory ExerciseVersionData.fromJson(
    Map<String, dynamic> json,
    List<BreathingStage>? baseStages,
  ) {
    List<BreathingStage>? versionStages;

    if (json['stage_durations'] != null && baseStages != null) {
      final durations = (json['stage_durations'] as List).cast<int>();
      versionStages = [];
      for (int i = 0; i < baseStages.length && i < durations.length; i++) {
        versionStages.add(baseStages[i].copyWith(duration: durations[i]));
      }
    } else if (json['stages'] != null) {
      versionStages = (json['stages'] as List)
          .map((stage) => BreathingStage._fromJson(stage))
          .toList();
    }

    return ExerciseVersionData(
      duration: json['duration'] as String?,
      pattern: json['pattern'] as String?,
      stages: versionStages,
      stageDurations: json['stage_durations'] != null
          ? (json['stage_durations'] as List).cast<int>()
          : null,
    );
  }
}

class BreathingStage {
  final String title;
  final String? titleKey;
  final String pattern;
  final int duration;
  final String? inhaleMethod;
  final String? exhaleMethod;
  final Map<String, List<PhaseInstruction>>? phaseInstructions;

  const BreathingStage({
    required this.title,
    this.titleKey,
    required this.pattern,
    required this.duration,
    this.inhaleMethod,
    this.exhaleMethod,
    this.phaseInstructions,
  });

  static Map<String, List<PhaseInstruction>>? _parsePhaseInstructions(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return null;
    final Map<String, List<PhaseInstruction>> result = {};
    for (final entry in json.entries) {
      final List<dynamic> instructionsJson = entry.value as List<dynamic>;
      result[entry.key] = instructionsJson
          .map(
            (inst) => PhaseInstruction.fromJson(inst as Map<String, dynamic>),
          )
          .toList();
    }
    return result;
  }

  factory BreathingStage.fromJson(
    Map<String, dynamic> json,
    String? languageCode,
  ) {
    String titleText;
    String? titleKey;

    if (json['title_key'] != null) {
      titleKey = json['title_key'] as String;
      titleText = titleKey;
    } else if (json['title'] is String) {
      titleText = json['title'] as String;
    } else if (json['title'] is Map<String, dynamic>) {
      String lang = languageCode ?? 'en';
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
      titleKey: titleKey,
      pattern: json['pattern'] as String,
      duration: json['duration'] as int,
      inhaleMethod: json['inhale_method'] as String?,
      exhaleMethod: json['exhale_method'] as String?,
      phaseInstructions: _parsePhaseInstructions(
        json['phase_instructions'] as Map<String, dynamic>?,
      ),
    );
  }

  factory BreathingStage._fromJson(Map<String, dynamic> json) {
    String titleText;
    String? titleKey;

    if (json['title_key'] != null) {
      titleKey = json['title_key'] as String;
      titleText = titleKey;
    } else if (json['title'] is String) {
      titleText = json['title'] as String;
    } else if (json['title'] is Map<String, dynamic>) {
      titleText =
          (json['title'] as Map<String, dynamic>)['en'] as String? ??
          'Untitled';
    } else {
      titleText = 'Untitled';
    }

    return BreathingStage(
      title: titleText,
      titleKey: titleKey,
      pattern: json['pattern'] as String,
      duration: json['duration'] as int,
      inhaleMethod: json['inhale_method'] as String?,
      exhaleMethod: json['exhale_method'] as String?,
      phaseInstructions: _parsePhaseInstructions(
        json['phase_instructions'] as Map<String, dynamic>?,
      ),
    );
  }

  BreathingStage copyWith({
    String? title,
    String? titleKey,
    String? pattern,
    int? duration,
    String? inhaleMethod,
    String? exhaleMethod,
    Map<String, List<PhaseInstruction>>? phaseInstructions,
  }) {
    return BreathingStage(
      title: title ?? this.title,
      titleKey: titleKey ?? this.titleKey,
      pattern: pattern ?? this.pattern,
      duration: duration ?? this.duration,
      inhaleMethod: inhaleMethod ?? this.inhaleMethod,
      exhaleMethod: exhaleMethod ?? this.exhaleMethod,
      phaseInstructions: phaseInstructions ?? this.phaseInstructions,
    );
  }

  String getLocalizedTitle(AppLocalizations l10n) {
    if (titleKey == null) return title;
    return _resolveTranslationKey(l10n, titleKey!) ?? title;
  }

  String? getPhaseInstructionKey(String phase, int elapsedSecondsInPhase) {
    final instructions = phaseInstructions?[phase];
    if (instructions == null) return null;
    for (final instruction in instructions) {
      if (instruction.isActive(elapsedSecondsInPhase)) {
        return instruction.instructionKey;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'title_key': titleKey,
      'pattern': pattern,
      'duration': duration,
      'inhale_method': inhaleMethod,
      'exhale_method': exhaleMethod,
      'phase_instructions': phaseInstructions?.map(
        (key, value) =>
            MapEntry(key, value.map((inst) => inst.toJson()).toList()),
      ),
    };
  }
}

class BreathingExercise {
  final String id;
  final String title;
  final String? titleKey;
  final String pattern;
  final String duration;
  final String intro;
  final String? introKey;
  final String? type;
  final List<BreathingStage>? stages;
  final String? inhaleMethod;
  final String? exhaleMethod;
  final Map<ExerciseVersion, ExerciseVersionData>? versions;

  const BreathingExercise({
    required this.id,
    required this.title,
    this.titleKey,
    required this.pattern,
    required this.duration,
    required this.intro,
    this.introKey,
    this.type,
    this.stages,
    this.inhaleMethod,
    this.exhaleMethod,
    this.versions,
  });

  factory BreathingExercise.fromJson(
    Map<String, dynamic> json,
    String? languageCode,
  ) {
    List<BreathingStage>? stages;
    if (json['stages'] != null) {
      stages = (json['stages'] as List)
          .map((stage) => BreathingStage.fromJson(stage, languageCode))
          .toList();
    }

    Map<ExerciseVersion, ExerciseVersionData>? versions;
    if (json['versions'] != null) {
      final versionsJson = json['versions'] as Map<String, dynamic>;
      versions = {};

      if (versionsJson['short'] != null) {
        versions[ExerciseVersion.short] = ExerciseVersionData.fromJson(
          versionsJson['short'],
          stages,
        );
      }
      if (versionsJson['normal'] != null) {
        versions[ExerciseVersion.normal] = ExerciseVersionData.fromJson(
          versionsJson['normal'],
          stages,
        );
      }
      if (versionsJson['long'] != null) {
        versions[ExerciseVersion.long] = ExerciseVersionData.fromJson(
          versionsJson['long'],
          stages,
        );
      }
    }

    String titleText;
    String? titleKey;
    if (json['title_key'] != null) {
      titleKey = json['title_key'] as String;
      titleText = titleKey;
    } else if (json['title'] is Map) {
      String lang = languageCode ?? 'en';
      if (json['title'][lang] == null) lang = 'en';
      titleText = json['title'][lang] as String;
    } else {
      titleText = json['title'] as String? ?? '';
    }

    String introText;
    String? introKey;
    if (json['intro_key'] != null) {
      introKey = json['intro_key'] as String;
      introText = introKey;
    } else if (json['intro'] is Map) {
      String lang = languageCode ?? 'en';
      if (json['intro'][lang] == null) lang = 'en';
      introText = json['intro'][lang] as String;
    } else {
      introText = json['intro'] as String? ?? '';
    }

    return BreathingExercise(
      id: json['id'] as String,
      title: titleText,
      titleKey: titleKey,
      pattern: json['pattern'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      intro: introText,
      introKey: introKey,
      type: json['type'] as String?,
      stages: stages,
      inhaleMethod: json['inhale_method'] as String?,
      exhaleMethod: json['exhale_method'] as String?,
      versions: versions,
    );
  }

  bool get hasStages => stages != null && stages!.isNotEmpty;

  bool get hasVersions => versions != null && versions!.isNotEmpty;

  bool get isStretchingExercise => type == 'stretching';

  bool get isProgressiveExercise =>
      type == 'progressive' || (hasStages && type == null);

  String get exerciseType {
    if (isStretchingExercise) return 'stretching';
    if (isProgressiveExercise) return 'progressive';
    return 'normal';
  }

  ExerciseVersionData? getVersionData(ExerciseVersion version) {
    return versions?[version];
  }

  String getPatternForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.pattern ?? pattern;
  }

  String getDurationForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.duration ?? duration;
  }

  List<BreathingStage>? getStagesForVersion(ExerciseVersion version) {
    final versionData = getVersionData(version);
    return versionData?.stages ?? stages;
  }

  String getLocalizedTitle(AppLocalizations l10n) {
    if (titleKey == null) return title;
    return _resolveTranslationKey(l10n, titleKey!) ?? title;
  }

  String getLocalizedIntro(AppLocalizations l10n) {
    if (introKey == null) return intro;
    return _resolveTranslationKey(l10n, introKey!) ?? intro;
  }
}

String? _resolveTranslationKey(AppLocalizations l10n, String key) {
  switch (key) {
    case 'exerciseTitle_relaxingBreath':
      return l10n.exerciseTitle_relaxingBreath;
    case 'exerciseIntro_relaxingBreath':
      return l10n.exerciseIntro_relaxingBreath;
    case 'exerciseTitle_boxBreathingNavySeals':
      return l10n.exerciseTitle_boxBreathingNavySeals;
    case 'exerciseIntro_boxBreathingNavySeals':
      return l10n.exerciseIntro_boxBreathingNavySeals;
    case 'exerciseTitle_twoOneRatio':
      return l10n.exerciseTitle_twoOneRatio;
    case 'exerciseIntro_twoOneRatio':
      return l10n.exerciseIntro_twoOneRatio;
    case 'exerciseTitle_equalBreathing':
      return l10n.exerciseTitle_equalBreathing;
    case 'exerciseIntro_equalBreathing':
      return l10n.exerciseIntro_equalBreathing;
    case 'exerciseTitle_modified478':
      return l10n.exerciseTitle_modified478;
    case 'exerciseIntro_modified478':
      return l10n.exerciseIntro_modified478;
    case 'exerciseTitle_coherentBreathing':
      return l10n.exerciseTitle_coherentBreathing;
    case 'exerciseIntro_coherentBreathing':
      return l10n.exerciseIntro_coherentBreathing;
    case 'exerciseTitle_extendedExhale':
      return l10n.exerciseTitle_extendedExhale;
    case 'exerciseIntro_extendedExhale':
      return l10n.exerciseIntro_extendedExhale;
    case 'exerciseTitle_miniBox':
      return l10n.exerciseTitle_miniBox;
    case 'exerciseIntro_miniBox':
      return l10n.exerciseIntro_miniBox;
    case 'exerciseTitle_samaVritti':
      return l10n.exerciseTitle_samaVritti;
    case 'exerciseIntro_samaVritti':
      return l10n.exerciseIntro_samaVritti;
    case 'exerciseTitle_deepEqual':
      return l10n.exerciseTitle_deepEqual;
    case 'exerciseIntro_deepEqual':
      return l10n.exerciseIntro_deepEqual;
    case 'exerciseTitle_squareBreathing':
      return l10n.exerciseTitle_squareBreathing;
    case 'exerciseIntro_squareBreathing':
      return l10n.exerciseIntro_squareBreathing;
    case 'exerciseTitle_quickFocus':
      return l10n.exerciseTitle_quickFocus;
    case 'exerciseIntro_quickFocus':
      return l10n.exerciseIntro_quickFocus;
    case 'exerciseTitle_ujjayiModified':
      return l10n.exerciseTitle_ujjayiModified;
    case 'exerciseIntro_ujjayiModified':
      return l10n.exerciseIntro_ujjayiModified;
    case 'exerciseTitle_extendedBox':
      return l10n.exerciseTitle_extendedBox;
    case 'exerciseIntro_extendedBox':
      return l10n.exerciseIntro_extendedBox;
    case 'exerciseTitle_trianglePlus':
      return l10n.exerciseTitle_trianglePlus;
    case 'exerciseIntro_trianglePlus':
      return l10n.exerciseIntro_trianglePlus;
    case 'exerciseTitle_oneTwoExtended':
      return l10n.exerciseTitle_oneTwoExtended;
    case 'exerciseIntro_oneTwoExtended':
      return l10n.exerciseIntro_oneTwoExtended;
    case 'exerciseTitle_gentleHold':
      return l10n.exerciseTitle_gentleHold;
    case 'exerciseIntro_gentleHold':
      return l10n.exerciseIntro_gentleHold;
    case 'exerciseTitle_longBreath':
      return l10n.exerciseTitle_longBreath;
    case 'exerciseIntro_longBreath':
      return l10n.exerciseIntro_longBreath;
    case 'exerciseTitle_classic478Extended':
      return l10n.exerciseTitle_classic478Extended;
    case 'exerciseIntro_classic478Extended':
      return l10n.exerciseIntro_classic478Extended;
    case 'exerciseTitle_goldenRatio':
      return l10n.exerciseTitle_goldenRatio;
    case 'exerciseIntro_goldenRatio':
      return l10n.exerciseIntro_goldenRatio;
    case 'exerciseTitle_sleepPreparationProtocol':
      return l10n.exerciseTitle_sleepPreparationProtocol;
    case 'exerciseIntro_sleepPreparationProtocol':
      return l10n.exerciseIntro_sleepPreparationProtocol;
    case 'exerciseTitle_anxietyRecoverySequence':
      return l10n.exerciseTitle_anxietyRecoverySequence;
    case 'exerciseIntro_anxietyRecoverySequence':
      return l10n.exerciseIntro_anxietyRecoverySequence;
    case 'exerciseTitle_morningEnergyBuilder':
      return l10n.exerciseTitle_morningEnergyBuilder;
    case 'exerciseIntro_morningEnergyBuilder':
      return l10n.exerciseIntro_morningEnergyBuilder;
    case 'exerciseTitle_panicAttackManagement':
      return l10n.exerciseTitle_panicAttackManagement;
    case 'exerciseIntro_panicAttackManagement':
      return l10n.exerciseIntro_panicAttackManagement;
    case 'exerciseTitle_concentrationTraining':
      return l10n.exerciseTitle_concentrationTraining;
    case 'exerciseIntro_concentrationTraining':
      return l10n.exerciseIntro_concentrationTraining;
    case 'exerciseTitle_bloodPressureReduction':
      return l10n.exerciseTitle_bloodPressureReduction;
    case 'exerciseIntro_bloodPressureReduction':
      return l10n.exerciseIntro_bloodPressureReduction;
    case 'exerciseTitle_preCompetitionProtocol':
      return l10n.exerciseTitle_preCompetitionProtocol;
    case 'exerciseIntro_preCompetitionProtocol':
      return l10n.exerciseIntro_preCompetitionProtocol;
    case 'exerciseTitle_postWorkoutRecovery':
      return l10n.exerciseTitle_postWorkoutRecovery;
    case 'exerciseIntro_postWorkoutRecovery':
      return l10n.exerciseIntro_postWorkoutRecovery;
    case 'exerciseTitle_meditationPreparation':
      return l10n.exerciseTitle_meditationPreparation;
    case 'exerciseIntro_meditationPreparation':
      return l10n.exerciseIntro_meditationPreparation;
    case 'exerciseTitle_chronicPainManagement':
      return l10n.exerciseTitle_chronicPainManagement;
    case 'exerciseIntro_chronicPainManagement':
      return l10n.exerciseIntro_chronicPainManagement;
    case 'exerciseTitle_stressReliefWave':
      return l10n.exerciseTitle_stressReliefWave;
    case 'exerciseIntro_stressReliefWave':
      return l10n.exerciseIntro_stressReliefWave;
    case 'exerciseTitle_energizingWakeUp':
      return l10n.exerciseTitle_energizingWakeUp;
    case 'exerciseIntro_energizingWakeUp':
      return l10n.exerciseIntro_energizingWakeUp;
    case 'exerciseTitle_balanceEquilibrium':
      return l10n.exerciseTitle_balanceEquilibrium;
    case 'exerciseIntro_balanceEquilibrium':
      return l10n.exerciseIntro_balanceEquilibrium;
    case 'exerciseTitle_deepRelaxationDive':
      return l10n.exerciseTitle_deepRelaxationDive;
    case 'exerciseIntro_deepRelaxationDive':
      return l10n.exerciseIntro_deepRelaxationDive;
    case 'exerciseTitle_cardioCoherence':
      return l10n.exerciseTitle_cardioCoherence;
    case 'exerciseIntro_cardioCoherence':
      return l10n.exerciseIntro_cardioCoherence;
    case 'exerciseTitle_officeBloodFlow':
      return l10n.exerciseTitle_officeBloodFlow;
    case 'exerciseIntro_officeBloodFlow':
      return l10n.exerciseIntro_officeBloodFlow;
    case 'stageTitle_nervousSystemBalance':
      return l10n.stageTitle_nervousSystemBalance;
    case 'stageTitle_deepRelaxation':
      return l10n.stageTitle_deepRelaxation;
    case 'stageTitle_sleepInduction':
      return l10n.stageTitle_sleepInduction;
    case 'stageTitle_stabilization':
      return l10n.stageTitle_stabilization;
    case 'stageTitle_grounding':
      return l10n.stageTitle_grounding;
    case 'stageTitle_parasympatheticActivation':
      return l10n.stageTitle_parasympatheticActivation;
    case 'stageTitle_awakening':
      return l10n.stageTitle_awakening;
    case 'stageTitle_energizing':
      return l10n.stageTitle_energizing;
    case 'stageTitle_focusEnhancement':
      return l10n.stageTitle_focusEnhancement;
    case 'stageTitle_immediateCalming':
      return l10n.stageTitle_immediateCalming;
    case 'stageTitle_fullRecovery':
      return l10n.stageTitle_fullRecovery;
    case 'stageTitle_foundationBuilding':
      return l10n.stageTitle_foundationBuilding;
    case 'stageTitle_complexityIncrease':
      return l10n.stageTitle_complexityIncrease;
    case 'stageTitle_sustainedFocus':
      return l10n.stageTitle_sustainedFocus;
    case 'stageTitle_baselineEstablishment':
      return l10n.stageTitle_baselineEstablishment;
    case 'stageTitle_therapeuticRatio':
      return l10n.stageTitle_therapeuticRatio;
    case 'stageTitle_maximumBenefit':
      return l10n.stageTitle_maximumBenefit;
    case 'stageTitle_coherenceBuilding':
      return l10n.stageTitle_coherenceBuilding;
    case 'stageTitle_mentalPreparation':
      return l10n.stageTitle_mentalPreparation;
    case 'stageTitle_controlledActivation':
      return l10n.stageTitle_controlledActivation;
    case 'stageTitle_heartRateNormalization':
      return l10n.stageTitle_heartRateNormalization;
    case 'stageTitle_recoveryAcceleration':
      return l10n.stageTitle_recoveryAcceleration;
    case 'stageTitle_homeostasisRestoration':
      return l10n.stageTitle_homeostasisRestoration;
    case 'stageTitle_mindSettling':
      return l10n.stageTitle_mindSettling;
    case 'stageTitle_deeperAwareness':
      return l10n.stageTitle_deeperAwareness;
    case 'stageTitle_transitionToMeditation':
      return l10n.stageTitle_transitionToMeditation;
    case 'stageTitle_gentleIntroduction':
      return l10n.stageTitle_gentleIntroduction;
    case 'stageTitle_painGateControl':
      return l10n.stageTitle_painGateControl;
    case 'stageTitle_endorphinRelease':
      return l10n.stageTitle_endorphinRelease;
    case 'stageTitle_heartRatePreparation':
      return l10n.stageTitle_heartRatePreparation;
    case 'stageTitle_peakCoherence':
      return l10n.stageTitle_peakCoherence;
    case 'stageTitle_shoulderRelease':
      return l10n.stageTitle_shoulderRelease;
    case 'stageTitle_neckStretch':
      return l10n.stageTitle_neckStretch;
    case 'phase_instruct_shouldersUp':
      return l10n.phase_instruct_shouldersUp;
    case 'phase_instruct_shouldersDown':
      return l10n.phase_instruct_shouldersDown;
    case 'phase_instruct_relaxShoulders':
      return l10n.phase_instruct_relaxShoulders;
    case 'phase_instruct_tiltRight':
      return l10n.phase_instruct_tiltRight;
    case 'phase_instruct_holdStretch':
      return l10n.phase_instruct_holdStretch;
    case 'phase_instruct_returnCenter':
      return l10n.phase_instruct_returnCenter;
    case 'phase_instruct_relaxNeck':
      return l10n.phase_instruct_relaxNeck;
    default:
      return null;
  }
}

List<BreathingExercise> breathingExercises = [];

Future<void> loadBreathingExercisesForLanguageCode(String? languageCode) async {
  AppLogger.debug('Loading exercises for language: $languageCode');
  try {
    const assetPath = 'assets/exercises.json';
    final String response = await rootBundle.loadString(assetPath);
    final List<dynamic> data = json.decode(response);
    breathingExercises = data
        .map((json) => BreathingExercise.fromJson(json, languageCode))
        .toList();

    if (kReleaseMode) {
      breathingExercises.removeWhere(
        (exercise) => exercise.id == 'test-5-0-5-0',
      );
    }

    AppLogger.info('Loaded ${breathingExercises.length} exercises');
  } catch (e, stack) {
    AppLogger.error('Failed to load exercises', e, stack);
    rethrow;
  }
}

Future<void> loadBreathingExercisesUsingSystemLocale() async {
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  await loadBreathingExercisesForLanguageCode(code);
}
