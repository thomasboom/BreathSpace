import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BreathingExercise {
  final String title;
  final String pattern;
  final String duration;
  final String intro;

  const BreathingExercise({
    required this.title,
    required this.pattern,
    required this.duration,
    required this.intro,
  });

  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    return BreathingExercise(
      title: json['title'],
      pattern: json['pattern'],
      duration: json['duration'],
      intro: json['intro'],
    );
  }
}

late List<BreathingExercise> breathingExercises;

Future<void> loadBreathingExercises() async {
  final String response = await rootBundle.loadString('assets/exercises.json');
  final List<dynamic> data = json.decode(response);
  breathingExercises = data.map((json) => BreathingExercise.fromJson(json)).toList();
}
