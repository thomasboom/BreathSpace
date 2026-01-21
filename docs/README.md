# BreathSpace Documentation

Welcome to the BreathSpace documentation. This guide will help you understand the project structure, setup process, and how to contribute.

## Table of Contents

- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [Localization](#localization)
- [Exercise Data](#exercise-data)
- [Development](#development)
- [Design](#design)

## Project Overview

BreathSpace is a Flutter application designed to help users practice various breathing exercises for relaxation and meditation. The app features:

- Multiple breathing exercise patterns
- Progressive exercise programs
- Multi-language support
- Customizable durations

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Setup

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter gen-l10n` to generate localization files
4. (Optional) Copy `.env.example` to `.env` and add your Gemini API key for AI-powered exercise recommendations:
   ```bash
   cp .env.example .env
   # Edit .env and replace YOUR_GEMINI_API_KEY with your actual API key from Google AI Studio
   ```
5. Use `flutter run` to start the application

## Localization

The app uses Flutter's gen-l10n for localization. Currently supported languages:
- English (`en`)
- Spanish (`es`)
- French (`fr`)
- German (`de`)
- Italian (`it`)
- Dutch (`nl`)
- Portuguese (`pt`)
- Russian (`ru`)
- Japanese (`ja`)
- Chinese (`zh`)
- Bulgarian (`bg`)
- Arabic (`ar`)
- Hebrew (`he`)
- Hindi (`hi`)
- Korean (`ko`)
- Polish (`pl`)
- Swahili (`sw`)
- Thai (`th`)
- Turkish (`tr`)
- Ukrainian (`uk`)
- Vietnamese (`vi`)

### Adding a New Language

1. Create a new ARB file in `lib/l10n/`, e.g. `app_es.arb` for Spanish
2. Copy all keys from `app_en.arb` and translate the values
3. Run:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
4. Rebuild the app. The new locale will be included automatically in `supportedLocales`
5. To expose the language in Settings:
   - Add an entry to the language dropdown in `lib/settings_screen.dart`
   - Add the language to the enum in `lib/settings_provider.dart`

### Changing Language at Runtime

Users can change the app language through the Settings screen (`Settings > Language`):
- System default
- English
- Spanish
- French
- German
- Italian
- Dutch
- Portuguese
- Russian
- Japanese
- Chinese
- Bulgarian
- Arabic
- Hebrew
- Hindi
- Korean
- Polish
- Swahili
- Thai
- Turkish
- Ukrainian
- Vietnamese

The selected language is persisted with `shared_preferences` and applied on startup.

## Exercise Data

Exercise data is stored in a single JSON file: `assets/exercises.json`. This file contains all exercises with translations for all supported languages.

### Exercise Structure

```json
[
  {
    "id": "box-breathing",
    "pattern": "4-4-4-4",
    "duration": "4 min",
    "title": {
      "en": "Box Breathing",
      "es": "Respiración en Caja",
      "fr": "Respiration Carrée",
      "de": "Box-Atmung",
      "it": "Respirazione a Scatola",
      "nl": "Box Ademhaling",
      "pt": "Respiração Quadrada",
      "ru": "Квадратное дыхание",
      "ja": "ボックス呼吸",
      "zh": "方块呼吸",
      "bg": "Квадратно дишане",
      "ar": "التنفس المربع",
      "he": "נשימת קופסה",
      "hi": "बॉक्स ब्रीदिंग",
      "ko": "박스 호흡",
      "pl": "Oddech w klatce",
      "sw": "Pumzi ya Kisanduku",
      "th": "การหายใจแบบกล่อง",
      "tr": "Kutu Nefes",
      "uk": "Квадратне дихання",
      "vi": "Hộp thở"
    },
    "intro": {
      "en": "A simple technique to calm your mind and body.",
      "es": "Una técnica simple para calmar tu mente y cuerpo.",
      "fr": "Une technique simple pour calmer votre esprit et votre corps.",
      "de": "Eine einfache Technik, um Ihren Geist und Körper zu beruhigen.",
      "it": "Una tecnica semplice per calmare la tua mente e il tuo corpo.",
      "nl": "Een eenvoudige techniek om je geest en lichaam te kalmeren.",
      "pt": "Uma técnica simples para acalmar sua mente e corpo.",
      "ru": "Простая техника для успокоения ума и тела.",
      "ja": "心と体を落ち着かせるシンプルなテクニック。",
      "zh": "一种简单的技术来平静你的心灵和身体。",
      "bg": "Проста техника за успокояване на ума и тялото.",
      "ar": "تقنية بسيطة لتهدئة عقلك وجسمك.",
      "he": "טכניקה פשוטה להרגעת הנפש והגוף.",
      "hi": "अपने मन और शरीर को शांत करने की एक सरल तकनीक।",
      "ko": "마음과 몸을 진정시키는 간단한 기법.",
      "pl": "Prosta technika uspokajająca umysł i ciało.",
      "sw": "Njia rahisi ya kukoa akili na mwili wako.",
      "th": "เทคนิคง่ายๆ เพื่อให้จิตใจและร่างกายสงบลง",
      "tr": "Zihninizi ve bedeninizi sakinleştirmek için basit bir teknik.",
      "uk": "Проста техніка для заспокоєння розуму та тіла.",
      "vi": "Một kỹ thuật đơn giản để làm dịu tâm trí và cơ thể."
    }
  }
]
```

### Adding or Updating Exercise Translations

1. Open `assets/exercises.json`
2. For each exercise, add a new key-value pair to the `title` and `intro` objects:
   - Key: Language code (e.g., "es" for Spanish)
   - Value: Translated text
3. If adding a new language to the app:
   - Add the language to the settings UI in `lib/settings_screen.dart`
   - Add the language to the enum in `lib/settings_provider.dart`
4. Rebuild the app

## Development

### Project Structure

```
lib/
├── l10n/                 # Localization files
├── screens/              # UI screens
├── providers/            # State management
├── models/               # Data models
└── utils/                # Utility functions

assets/
├── exercises.json        # Exercise data
└── images/               # App images

docs/                     # Documentation files
test/                     # Unit and widget tests
```

### Testing

Run tests with:
```bash
flutter test
```

### Building

Build for different platforms with:
```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Design

BreathSpace follows a clean, minimalist design philosophy focused on promoting calm and relaxation. For detailed information about the design principles, color scheme, typography, and UI components, please refer to the [Design Guide](./DESIGN_GUIDE.md).