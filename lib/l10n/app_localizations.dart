import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sw'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BreathSpace'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchHint;

  /// No description provided for @progressive.
  ///
  /// In en, this message translates to:
  /// **'Progressive'**
  String get progressive;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get languageBulgarian;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @useListView.
  ///
  /// In en, this message translates to:
  /// **'Use List View'**
  String get useListView;

  /// No description provided for @viewMode.
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @aiMode.
  ///
  /// In en, this message translates to:
  /// **'AI Mode'**
  String get aiMode;

  /// No description provided for @quizMode.
  ///
  /// In en, this message translates to:
  /// **'Quiz Mode'**
  String get quizMode;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found.'**
  String get noExercisesFound;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold calmly'**
  String get hold;

  /// No description provided for @throughNose.
  ///
  /// In en, this message translates to:
  /// **'through nose'**
  String get throughNose;

  /// No description provided for @throughMouth.
  ///
  /// In en, this message translates to:
  /// **'through mouth'**
  String get throughMouth;

  /// No description provided for @whileHoldingBreath.
  ///
  /// In en, this message translates to:
  /// **'while holding breath'**
  String get whileHoldingBreath;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @exerciseInvalid.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found or invalid pattern.'**
  String get exerciseInvalid;

  /// No description provided for @progressiveExercise.
  ///
  /// In en, this message translates to:
  /// **'Progressive Exercise'**
  String get progressiveExercise;

  /// No description provided for @pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get pattern;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice Guide'**
  String get voiceGuide;

  /// No description provided for @voiceGuideOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get voiceGuideOff;

  /// No description provided for @voiceGuideThomas.
  ///
  /// In en, this message translates to:
  /// **'Thomas'**
  String get voiceGuideThomas;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @musicOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get musicOff;

  /// No description provided for @musicNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get musicNature;

  /// No description provided for @musicLofi.
  ///
  /// In en, this message translates to:
  /// **'LoFi'**
  String get musicLofi;

  /// No description provided for @musicPiano.
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get musicPiano;

  /// No description provided for @replayIntro.
  ///
  /// In en, this message translates to:
  /// **'Replay Intro'**
  String get replayIntro;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BreathSpace'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your space. Slow down, anytime.'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @promptCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Prompt Cache'**
  String get promptCacheTitle;

  /// No description provided for @promptCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cached responses for faster recommendations'**
  String get promptCacheSubtitle;

  /// No description provided for @promptCacheEntries.
  ///
  /// In en, this message translates to:
  /// **'entries'**
  String get promptCacheEntries;

  /// No description provided for @promptCacheClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get promptCacheClear;

  /// No description provided for @promptCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Prompt cache cleared'**
  String get promptCacheCleared;

  /// No description provided for @exerciseFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise finished'**
  String get exerciseFinishedTitle;

  /// No description provided for @exerciseFinishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I hope you feel better.'**
  String get exerciseFinishedSubtitle;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyExerciseLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Exercise Link'**
  String get copyExerciseLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @termsAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get termsAgreementPrefix;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAgreementSuffix;

  /// No description provided for @exerciseTitle_relaxingBreath.
  ///
  /// In en, this message translates to:
  /// **'Relaxing Breath'**
  String get exerciseTitle_relaxingBreath;

  /// No description provided for @exerciseIntro_relaxingBreath.
  ///
  /// In en, this message translates to:
  /// **'Promotes sleep and reduces anxiety.'**
  String get exerciseIntro_relaxingBreath;

  /// No description provided for @exerciseTitle_boxBreathingNavySeals.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get exerciseTitle_boxBreathingNavySeals;

  /// No description provided for @exerciseIntro_boxBreathingNavySeals.
  ///
  /// In en, this message translates to:
  /// **'Used by Navy SEALs for stress management.'**
  String get exerciseIntro_boxBreathingNavySeals;

  /// No description provided for @exerciseTitle_twoOneRatio.
  ///
  /// In en, this message translates to:
  /// **'2:1 Ratio Breathing'**
  String get exerciseTitle_twoOneRatio;

  /// No description provided for @exerciseIntro_twoOneRatio.
  ///
  /// In en, this message translates to:
  /// **'Simple calming technique for beginners.'**
  String get exerciseIntro_twoOneRatio;

  /// No description provided for @exerciseTitle_equalBreathing.
  ///
  /// In en, this message translates to:
  /// **'Equal Breathing'**
  String get exerciseTitle_equalBreathing;

  /// No description provided for @exerciseIntro_equalBreathing.
  ///
  /// In en, this message translates to:
  /// **'Balances nervous system activation.'**
  String get exerciseIntro_equalBreathing;

  /// No description provided for @exerciseTitle_modified478.
  ///
  /// In en, this message translates to:
  /// **'Modified 4-7-8'**
  String get exerciseTitle_modified478;

  /// No description provided for @exerciseIntro_modified478.
  ///
  /// In en, this message translates to:
  /// **'Gentler version for anxiety relief.'**
  String get exerciseIntro_modified478;

  /// No description provided for @exerciseTitle_coherentBreathing.
  ///
  /// In en, this message translates to:
  /// **'Coherent Breathing'**
  String get exerciseTitle_coherentBreathing;

  /// No description provided for @exerciseIntro_coherentBreathing.
  ///
  /// In en, this message translates to:
  /// **'Optimizes heart rate variability.'**
  String get exerciseIntro_coherentBreathing;

  /// No description provided for @exerciseTitle_extendedExhale.
  ///
  /// In en, this message translates to:
  /// **'Extended Exhale'**
  String get exerciseTitle_extendedExhale;

  /// No description provided for @exerciseIntro_extendedExhale.
  ///
  /// In en, this message translates to:
  /// **'Activates parasympathetic response.'**
  String get exerciseIntro_extendedExhale;

  /// No description provided for @exerciseTitle_miniBox.
  ///
  /// In en, this message translates to:
  /// **'Mini Box Breathing'**
  String get exerciseTitle_miniBox;

  /// No description provided for @exerciseIntro_miniBox.
  ///
  /// In en, this message translates to:
  /// **'Quick stress relief for busy moments.'**
  String get exerciseIntro_miniBox;

  /// No description provided for @exerciseTitle_samaVritti.
  ///
  /// In en, this message translates to:
  /// **'Sama Vritti'**
  String get exerciseTitle_samaVritti;

  /// No description provided for @exerciseIntro_samaVritti.
  ///
  /// In en, this message translates to:
  /// **'Improves concentration and mental clarity.'**
  String get exerciseIntro_samaVritti;

  /// No description provided for @exerciseTitle_deepEqual.
  ///
  /// In en, this message translates to:
  /// **'Deep Equal Breathing'**
  String get exerciseTitle_deepEqual;

  /// No description provided for @exerciseIntro_deepEqual.
  ///
  /// In en, this message translates to:
  /// **'Enhances focus and cognitive performance.'**
  String get exerciseIntro_deepEqual;

  /// No description provided for @exerciseTitle_squareBreathing.
  ///
  /// In en, this message translates to:
  /// **'Square Breathing'**
  String get exerciseTitle_squareBreathing;

  /// No description provided for @exerciseIntro_squareBreathing.
  ///
  /// In en, this message translates to:
  /// **'Builds mental resilience.'**
  String get exerciseIntro_squareBreathing;

  /// No description provided for @exerciseTitle_quickFocus.
  ///
  /// In en, this message translates to:
  /// **'Quick Focus'**
  String get exerciseTitle_quickFocus;

  /// No description provided for @exerciseIntro_quickFocus.
  ///
  /// In en, this message translates to:
  /// **'Rapid attention enhancement.'**
  String get exerciseIntro_quickFocus;

  /// No description provided for @exerciseTitle_ujjayiModified.
  ///
  /// In en, this message translates to:
  /// **'Modified Ujjayi'**
  String get exerciseTitle_ujjayiModified;

  /// No description provided for @exerciseIntro_ujjayiModified.
  ///
  /// In en, this message translates to:
  /// **'Builds internal heat and focus.'**
  String get exerciseIntro_ujjayiModified;

  /// No description provided for @exerciseTitle_extendedBox.
  ///
  /// In en, this message translates to:
  /// **'Extended Box Breathing'**
  String get exerciseTitle_extendedBox;

  /// No description provided for @exerciseIntro_extendedBox.
  ///
  /// In en, this message translates to:
  /// **'Advanced stress management.'**
  String get exerciseIntro_extendedBox;

  /// No description provided for @exerciseTitle_trianglePlus.
  ///
  /// In en, this message translates to:
  /// **'Triangle Plus'**
  String get exerciseTitle_trianglePlus;

  /// No description provided for @exerciseIntro_trianglePlus.
  ///
  /// In en, this message translates to:
  /// **'Complex pattern for experienced practitioners.'**
  String get exerciseIntro_trianglePlus;

  /// No description provided for @exerciseTitle_oneTwoExtended.
  ///
  /// In en, this message translates to:
  /// **'1:2 Extended Breathing'**
  String get exerciseTitle_oneTwoExtended;

  /// No description provided for @exerciseIntro_oneTwoExtended.
  ///
  /// In en, this message translates to:
  /// **'Deep relaxation and blood pressure reduction.'**
  String get exerciseIntro_oneTwoExtended;

  /// No description provided for @exerciseTitle_gentleHold.
  ///
  /// In en, this message translates to:
  /// **'Gentle Hold'**
  String get exerciseTitle_gentleHold;

  /// No description provided for @exerciseIntro_gentleHold.
  ///
  /// In en, this message translates to:
  /// **'For those with lung capacity limitations.'**
  String get exerciseIntro_gentleHold;

  /// No description provided for @exerciseTitle_longBreath.
  ///
  /// In en, this message translates to:
  /// **'Long Breath'**
  String get exerciseTitle_longBreath;

  /// No description provided for @exerciseIntro_longBreath.
  ///
  /// In en, this message translates to:
  /// **'Increases lung capacity and endurance.'**
  String get exerciseIntro_longBreath;

  /// No description provided for @exerciseTitle_classic478Extended.
  ///
  /// In en, this message translates to:
  /// **'Classic 4-7-8 Extended'**
  String get exerciseTitle_classic478Extended;

  /// No description provided for @exerciseIntro_classic478Extended.
  ///
  /// In en, this message translates to:
  /// **'Maximum relaxation response.'**
  String get exerciseIntro_classic478Extended;

  /// No description provided for @exerciseTitle_goldenRatio.
  ///
  /// In en, this message translates to:
  /// **'Golden Ratio'**
  String get exerciseTitle_goldenRatio;

  /// No description provided for @exerciseIntro_goldenRatio.
  ///
  /// In en, this message translates to:
  /// **'Based on mathematical harmony principles.'**
  String get exerciseIntro_goldenRatio;

  /// No description provided for @exerciseTitle_sleepPreparationProtocol.
  ///
  /// In en, this message translates to:
  /// **'Sleep Preparation Protocol'**
  String get exerciseTitle_sleepPreparationProtocol;

  /// No description provided for @exerciseIntro_sleepPreparationProtocol.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to prepare your body and mind for restful sleep.'**
  String get exerciseIntro_sleepPreparationProtocol;

  /// No description provided for @exerciseTitle_anxietyRecoverySequence.
  ///
  /// In en, this message translates to:
  /// **'Anxiety Recovery Sequence'**
  String get exerciseTitle_anxietyRecoverySequence;

  /// No description provided for @exerciseIntro_anxietyRecoverySequence.
  ///
  /// In en, this message translates to:
  /// **'A progressive approach to calm anxiety and restore emotional balance.'**
  String get exerciseIntro_anxietyRecoverySequence;

  /// No description provided for @exerciseTitle_morningEnergyBuilder.
  ///
  /// In en, this message translates to:
  /// **'Morning Energy Builder'**
  String get exerciseTitle_morningEnergyBuilder;

  /// No description provided for @exerciseIntro_morningEnergyBuilder.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to awaken your body and mind for the day ahead.'**
  String get exerciseIntro_morningEnergyBuilder;

  /// No description provided for @exerciseTitle_panicAttackManagement.
  ///
  /// In en, this message translates to:
  /// **'Panic Attack Management'**
  String get exerciseTitle_panicAttackManagement;

  /// No description provided for @exerciseIntro_panicAttackManagement.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to quickly calm panic attacks and restore control.'**
  String get exerciseIntro_panicAttackManagement;

  /// No description provided for @exerciseTitle_concentrationTraining.
  ///
  /// In en, this message translates to:
  /// **'Concentration Training'**
  String get exerciseTitle_concentrationTraining;

  /// No description provided for @exerciseIntro_concentrationTraining.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to develop and sustain mental focus over time.'**
  String get exerciseIntro_concentrationTraining;

  /// No description provided for @exerciseTitle_bloodPressureReduction.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure Reduction'**
  String get exerciseTitle_bloodPressureReduction;

  /// No description provided for @exerciseIntro_bloodPressureReduction.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence designed to lower blood pressure through therapeutic breathing.'**
  String get exerciseIntro_bloodPressureReduction;

  /// No description provided for @exerciseTitle_preCompetitionProtocol.
  ///
  /// In en, this message translates to:
  /// **'Pre-Competition Protocol'**
  String get exerciseTitle_preCompetitionProtocol;

  /// No description provided for @exerciseIntro_preCompetitionProtocol.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to prepare mentally and physically for peak performance.'**
  String get exerciseIntro_preCompetitionProtocol;

  /// No description provided for @exerciseTitle_postWorkoutRecovery.
  ///
  /// In en, this message translates to:
  /// **'Post-Workout Recovery'**
  String get exerciseTitle_postWorkoutRecovery;

  /// No description provided for @exerciseIntro_postWorkoutRecovery.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to normalize heart rate and accelerate recovery after exercise.'**
  String get exerciseIntro_postWorkoutRecovery;

  /// No description provided for @exerciseTitle_meditationPreparation.
  ///
  /// In en, this message translates to:
  /// **'Meditation Preparation'**
  String get exerciseTitle_meditationPreparation;

  /// No description provided for @exerciseIntro_meditationPreparation.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to settle the mind and transition into deeper meditation.'**
  String get exerciseIntro_meditationPreparation;

  /// No description provided for @exerciseTitle_chronicPainManagement.
  ///
  /// In en, this message translates to:
  /// **'Chronic Pain Management'**
  String get exerciseTitle_chronicPainManagement;

  /// No description provided for @exerciseIntro_chronicPainManagement.
  ///
  /// In en, this message translates to:
  /// **'A progressive sequence to help manage chronic pain through controlled breathing techniques.'**
  String get exerciseIntro_chronicPainManagement;

  /// No description provided for @exerciseTitle_stressReliefWave.
  ///
  /// In en, this message translates to:
  /// **'Stress Relief Wave'**
  String get exerciseTitle_stressReliefWave;

  /// No description provided for @exerciseIntro_stressReliefWave.
  ///
  /// In en, this message translates to:
  /// **'Gentle rhythm to wash away stress and tension.'**
  String get exerciseIntro_stressReliefWave;

  /// No description provided for @exerciseTitle_energizingWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Energizing Wake-Up'**
  String get exerciseTitle_energizingWakeUp;

  /// No description provided for @exerciseIntro_energizingWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Quick boost to awaken your body and energize your mind.'**
  String get exerciseIntro_energizingWakeUp;

  /// No description provided for @exerciseTitle_balanceEquilibrium.
  ///
  /// In en, this message translates to:
  /// **'Balance Equilibrium'**
  String get exerciseTitle_balanceEquilibrium;

  /// No description provided for @exerciseIntro_balanceEquilibrium.
  ///
  /// In en, this message translates to:
  /// **'Restores equilibrium between mind and body.'**
  String get exerciseIntro_balanceEquilibrium;

  /// No description provided for @exerciseTitle_deepRelaxationDive.
  ///
  /// In en, this message translates to:
  /// **'Deep Relaxation Dive'**
  String get exerciseTitle_deepRelaxationDive;

  /// No description provided for @exerciseIntro_deepRelaxationDive.
  ///
  /// In en, this message translates to:
  /// **'Dive deep into a state of complete relaxation and peace.'**
  String get exerciseIntro_deepRelaxationDive;

  /// No description provided for @exerciseTitle_cardioCoherence.
  ///
  /// In en, this message translates to:
  /// **'Cardio Coherence'**
  String get exerciseTitle_cardioCoherence;

  /// No description provided for @exerciseIntro_cardioCoherence.
  ///
  /// In en, this message translates to:
  /// **'A sequence to optimize heart rate variability and emotional balance.'**
  String get exerciseIntro_cardioCoherence;

  /// No description provided for @stageTitle_nervousSystemBalance.
  ///
  /// In en, this message translates to:
  /// **'Nervous System Balance'**
  String get stageTitle_nervousSystemBalance;

  /// No description provided for @stageTitle_deepRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Deep Relaxation'**
  String get stageTitle_deepRelaxation;

  /// No description provided for @stageTitle_sleepInduction.
  ///
  /// In en, this message translates to:
  /// **'Sleep Induction'**
  String get stageTitle_sleepInduction;

  /// No description provided for @stageTitle_stabilization.
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get stageTitle_stabilization;

  /// No description provided for @stageTitle_grounding.
  ///
  /// In en, this message translates to:
  /// **'Grounding'**
  String get stageTitle_grounding;

  /// No description provided for @stageTitle_parasympatheticActivation.
  ///
  /// In en, this message translates to:
  /// **'Parasympathetic Activation'**
  String get stageTitle_parasympatheticActivation;

  /// No description provided for @stageTitle_awakening.
  ///
  /// In en, this message translates to:
  /// **'Awakening'**
  String get stageTitle_awakening;

  /// No description provided for @stageTitle_energizing.
  ///
  /// In en, this message translates to:
  /// **'Energizing'**
  String get stageTitle_energizing;

  /// No description provided for @stageTitle_focusEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Focus Enhancement'**
  String get stageTitle_focusEnhancement;

  /// No description provided for @stageTitle_immediateCalming.
  ///
  /// In en, this message translates to:
  /// **'Immediate Calming'**
  String get stageTitle_immediateCalming;

  /// No description provided for @stageTitle_fullRecovery.
  ///
  /// In en, this message translates to:
  /// **'Full Recovery'**
  String get stageTitle_fullRecovery;

  /// No description provided for @stageTitle_foundationBuilding.
  ///
  /// In en, this message translates to:
  /// **'Foundation Building'**
  String get stageTitle_foundationBuilding;

  /// No description provided for @stageTitle_complexityIncrease.
  ///
  /// In en, this message translates to:
  /// **'Complexity Increase'**
  String get stageTitle_complexityIncrease;

  /// No description provided for @stageTitle_sustainedFocus.
  ///
  /// In en, this message translates to:
  /// **'Sustained Focus'**
  String get stageTitle_sustainedFocus;

  /// No description provided for @stageTitle_baselineEstablishment.
  ///
  /// In en, this message translates to:
  /// **'Baseline Establishment'**
  String get stageTitle_baselineEstablishment;

  /// No description provided for @stageTitle_therapeuticRatio.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic Ratio'**
  String get stageTitle_therapeuticRatio;

  /// No description provided for @stageTitle_maximumBenefit.
  ///
  /// In en, this message translates to:
  /// **'Maximum Benefit'**
  String get stageTitle_maximumBenefit;

  /// No description provided for @stageTitle_coherenceBuilding.
  ///
  /// In en, this message translates to:
  /// **'Coherence Building'**
  String get stageTitle_coherenceBuilding;

  /// No description provided for @stageTitle_mentalPreparation.
  ///
  /// In en, this message translates to:
  /// **'Mental Preparation'**
  String get stageTitle_mentalPreparation;

  /// No description provided for @stageTitle_controlledActivation.
  ///
  /// In en, this message translates to:
  /// **'Controlled Activation'**
  String get stageTitle_controlledActivation;

  /// No description provided for @stageTitle_heartRateNormalization.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Normalization'**
  String get stageTitle_heartRateNormalization;

  /// No description provided for @stageTitle_recoveryAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Recovery Acceleration'**
  String get stageTitle_recoveryAcceleration;

  /// No description provided for @stageTitle_homeostasisRestoration.
  ///
  /// In en, this message translates to:
  /// **'Homeostasis Restoration'**
  String get stageTitle_homeostasisRestoration;

  /// No description provided for @stageTitle_mindSettling.
  ///
  /// In en, this message translates to:
  /// **'Mind Settling'**
  String get stageTitle_mindSettling;

  /// No description provided for @stageTitle_deeperAwareness.
  ///
  /// In en, this message translates to:
  /// **'Deeper Awareness'**
  String get stageTitle_deeperAwareness;

  /// No description provided for @stageTitle_transitionToMeditation.
  ///
  /// In en, this message translates to:
  /// **'Transition to Meditation'**
  String get stageTitle_transitionToMeditation;

  /// No description provided for @stageTitle_gentleIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Gentle Introduction'**
  String get stageTitle_gentleIntroduction;

  /// No description provided for @stageTitle_painGateControl.
  ///
  /// In en, this message translates to:
  /// **'Pain Gate Control'**
  String get stageTitle_painGateControl;

  /// No description provided for @stageTitle_endorphinRelease.
  ///
  /// In en, this message translates to:
  /// **'Endorphin Release'**
  String get stageTitle_endorphinRelease;

  /// No description provided for @stageTitle_heartRatePreparation.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Preparation'**
  String get stageTitle_heartRatePreparation;

  /// No description provided for @stageTitle_peakCoherence.
  ///
  /// In en, this message translates to:
  /// **'Peak Coherence'**
  String get stageTitle_peakCoherence;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bg',
    'de',
    'en',
    'es',
    'fr',
    'he',
    'hi',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'sw',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sw':
      return AppLocalizationsSw();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
