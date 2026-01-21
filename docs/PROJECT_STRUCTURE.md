# Project Structure

This document provides an overview of the BreathSpace project structure.

## Root Directory

```
.
├── .github/              # GitHub Actions CI/CD workflows
├── android/              # Android-specific code
├── assets/               # Static assets (images, JSON files, fonts, music)
├── build/                # Build output directory
├── coverage/             # Test coverage reports
├── docs/                 # Documentation files
├── extension/            # Browser extension code
├── icons/                # App icons for various platforms
├── ios/                  # iOS-specific code
├── lib/                  # Main Flutter application code
├── linux/                # Linux-specific code
├── macos/                # macOS-specific code
├── test/                 # Unit and widget tests
├── web/                  # Web-specific code
├── website/              # Website source code
├── windows/              # Windows-specific code
├── .env                  # Environment variables (not in git)
├── .env.example          # Environment variables template
├── .gitignore            # Git ignore file
├── .idea/                # IDE configuration
├── .vscode/              # VS Code configuration
├── AGENTS.md             # AGENTS documentation
├── analysis_options.yaml # Dart analysis options
├── l10n.yaml             # Localization configuration
├── LICENSE               # Project license
├── OpenBreath.iml        # IntelliJ project file
├── pubspec.yaml          # Flutter package configuration
├── pubspec.lock          # Dependency lock file
├── README.md             # Project README
├── ROADMAP.md            # Future plans
└── untranslated_messages.txt # Untranslated text tracking
```

## Lib Directory

The `lib` directory contains the main Flutter application code:

```
lib/
├── l10n/                 # Localization files (ARB format)
│   ├── app_*.arb        # Localization resource files (21 languages)
│   └── app_localizations*.dart # Generated localization files
├── generated/            # Generated code
│   └── intl/            # Generated internationalization files
├── data.dart            # Exercise data models
├── main.dart            # Application entry point
├── logger.dart          # Logging utility
├── exercise_detail_screen.dart  # Exercise details screen
├── exercise_finished_screen.dart # Exercise completion screen
├── exercise_screen.dart        # Exercise execution screen
├── gemini_exercise_screen.dart # AI-generated exercise screen
├── gemini_service.dart        # Gemini AI service
├── intro_screen.dart          # Intro/onboarding screen
├── quiz_exercise_screen.dart  # Quiz-based exercise screen
├── settings_screen.dart      # Settings screen
├── settings_provider.dart     # Settings state management
├── theme_provider.dart       # Theme state management
├── pinned_exercises_provider.dart # Pinned exercises state
├── prompt_cache_service.dart      # AI prompt caching
├── rate_limiter.dart              # Rate limiting utility
├── models/                 # Data models directory (currently empty)
└── services/               # Services directory (currently empty)
```

## Assets Directory

The `assets` directory contains static assets used by the application:

```
assets/
├── exercises.json        # Exercise data in JSON format
├── fonts/               # Custom font files (GFS Didot)
│   ├── GFSDidot.otf
│   ├── GFSDidotBold.otf
│   ├── GFSDidotItalic.otf
│   └── GFSDidotBoldItalic.otf
├── music/               # Background music files
│   ├── lofi.mp3
│   ├── nature.mp3
│   └── piano.mp3
└── sounds/              # Sound effects
```

## Docs Directory

The `docs` directory contains all project documentation:

```
docs/
├── README.md             # Main documentation
├── PROJECT_STRUCTURE.md  # This file
├── DESIGN_GUIDE.md      # Design principles and guidelines
├── STYLE_GUIDE.md        # Code style guide
├── MODELS.md             # Data models documentation
├── PROGRESSIVE_EXERCISES.md  # Progressive exercises documentation
├── STATE_MANAGEMENT.md   # State management documentation
├── TESTING.md            # Testing guide
├── CONTRIBUTING.md       # Contributing guidelines
├── CHANGELOG.md          # Release history
├── KEYBOARD_SHORTCUTS.md # Keyboard shortcuts reference
├── android_signing_guide.md # Android signing instructions
└── index.md              # Documentation index
```

## Test Directory

The `test` directory contains all application tests:

```
test/
├── data_test.dart        # Exercise data tests
├── providers_test.dart   # Provider state management tests
├── rate_limiter_test.dart # Rate limiter utility tests
├── stages_test.dart      # Breathing stage tests
└── widget_test.dart      # Widget tests
```