
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OpenBreath/l10n/app_localizations.dart';

import 'main.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).welcomeTitle,
              style: const TextStyle(fontSize: 34),
            ),
            Text(
              AppLocalizations.of(context).welcomeSubtitle,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen', true);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const BreathingExerciseScreen()),
                );
              },
              child: Text(AppLocalizations.of(context).getStarted),
            ),
          ],
        ),
      ),
    );
  }
}
