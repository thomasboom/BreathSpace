// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenBreath';

  @override
  String get searchHint => 'Search exercises...';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get autoSelectSearchBar => 'Auto-select search bar';

  @override
  String get start => 'Start';

  @override
  String get noExercisesFound => 'No exercises found.';

  @override
  String get inhale => 'Inhale';

  @override
  String get exhale => 'Exhale';

  @override
  String get hold => 'Hold';

  @override
  String get close => 'Close';

  @override
  String get exerciseInvalid => 'Exercise not found or invalid pattern.';

  @override
  String get progressiveExercise => 'Progressive Exercise';

  @override
  String get pattern => 'Pattern';
}
