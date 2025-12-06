
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';

import 'main.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
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
                final context = this.context;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen', true);
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const BreathingExerciseScreen()),
                  );
                }
              },
              child: Text(AppLocalizations.of(context).getStarted),
            ),
          ],
        ),
      ),
    );
  }
}
