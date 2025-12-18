
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:BreathSpace/l10n/app_localizations.dart';

import 'main.dart';
import 'settings_provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  ViewMode _selectedViewMode = ViewMode.list; // Default to list view
  LanguagePreference _selectedLanguage = LanguagePreference.system; // Default to system

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getLanguageName(LanguagePreference lang, BuildContext context) {
    switch (lang) {
      case LanguagePreference.system:
        return AppLocalizations.of(context).languageSystem;
      case LanguagePreference.ar:
        return AppLocalizations.of(context).languageArabic;
      case LanguagePreference.bg:
        return AppLocalizations.of(context).languageBulgarian;
      case LanguagePreference.de:
        return AppLocalizations.of(context).languageGerman;
      case LanguagePreference.en:
        return AppLocalizations.of(context).languageEnglish;
      case LanguagePreference.es:
        return AppLocalizations.of(context).languageSpanish;
      case LanguagePreference.fr:
        return AppLocalizations.of(context).languageFrench;
      case LanguagePreference.hi:
        return AppLocalizations.of(context).languageHindi;
      case LanguagePreference.it:
        return AppLocalizations.of(context).languageItalian;
      case LanguagePreference.ja:
        return AppLocalizations.of(context).languageJapanese;
      case LanguagePreference.ko:
        return AppLocalizations.of(context).languageKorean;
      case LanguagePreference.nl:
        return AppLocalizations.of(context).languageDutch;
      case LanguagePreference.pl:
        return AppLocalizations.of(context).languagePolish;
      case LanguagePreference.pt:
        return AppLocalizations.of(context).languagePortuguese;
      case LanguagePreference.ru:
        return AppLocalizations.of(context).languageRussian;
      case LanguagePreference.tr:
        return AppLocalizations.of(context).languageTurkish;
      case LanguagePreference.zh:
        return AppLocalizations.of(context).languageChinese;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.spa_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          AppLocalizations.of(context).welcomeTitle,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).welcomeSubtitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: AppLocalizations.of(context).termsAgreementPrefix),
                              TextSpan(
                                text: AppLocalizations.of(context).privacyPolicy,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final Uri url = Uri.parse('https://breathspace-app.vercel.app/privacy-policy.html');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      throw Exception('Could not launch $url');
                                    }
                                  },
                              ),
                              TextSpan(text: AppLocalizations.of(context).termsAgreementSuffix),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<LanguagePreference>(
                        initialValue: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).language,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: LanguagePreference.values.map((LanguagePreference lang) {
                          String langName = _getLanguageName(lang, context);
                          return DropdownMenuItem<LanguagePreference>(
                            value: lang,
                            child: Text(langName),
                          );
                        }).toList(),
                        onChanged: (LanguagePreference? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                            // Immediately update the language preference to trigger UI update
                            final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                            settingsProvider.setLanguagePreference(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<ViewMode>(
                        initialValue: _selectedViewMode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).viewMode,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: ViewMode.values.map((ViewMode mode) {
                          return DropdownMenuItem<ViewMode>(
                            value: mode,
                            child: Text(
                              mode == ViewMode.list
                                ? AppLocalizations.of(context).listView
                                : mode == ViewMode.ai
                                    ? AppLocalizations.of(context).aiMode
                                    : AppLocalizations.of(context).quizMode,
                            ),
                          );
                        }).toList(),
                        onChanged: (ViewMode? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedViewMode = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('seen', true);

                          // Save the selected view mode and language using the existing provider
                          await settingsProvider.setViewMode(_selectedViewMode);
                          await settingsProvider.setLanguagePreference(_selectedLanguage);

                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const BreathingExerciseScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          AppLocalizations.of(context).getStarted,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
