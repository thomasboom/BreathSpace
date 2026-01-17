import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:BreathSpace/main.dart';
import 'package:BreathSpace/data.dart';
import 'package:BreathSpace/theme_provider.dart';
import 'package:BreathSpace/settings_provider.dart';
import 'package:BreathSpace/pinned_exercises_provider.dart';

void main() {
  testWidgets('BreathSpaceApp displays correctly', (WidgetTester tester) async {
    await loadBreathingExercisesUsingSystemLocale();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => SettingsProvider()),
          ChangeNotifierProvider(
            create: (context) => PinnedExercisesProvider(),
          ),
        ],
        child: const BreathSpaceApp(seen: false),
      ),
    );

    expect(find.byType(Text), findsWidgets);
    expect(breathingExercises.length, greaterThan(0));
  });
}
