# Gurmukhi Flutter (Android-first)

This is a full starter skeleton mapped from your existing iOS SwiftUI architecture.

## Mapped architecture

- `lib/models`: shared data schema (`ReflectionEntry`, `SourceType`, `UserPreferences`, etc.)
- `lib/services`: JSON repository, daily selection, persistence, notifications
- `lib/state`: app-level state and business logic (`AppState`)
- `lib/features`: onboarding, home, learn deck, saved, settings, reflection pages

## Current implementation status

- Included:
  - Onboarding flow + preferences setup
  - Tabbed app shell (Home / Learn / Saved / Settings)
  - Daily reflection selection
  - Bookmarking
  - Language switching (english/hindi/punjabi JSON)
  - Progress tracking placeholders for Chaupai/Japji packets
  - Android deep link intent filter (`jagjeet://reflection/...`)
- Stubbed/placeholder:
  - Full notification scheduling details
  - Advanced card-swipe animation parity with iOS

## Run

1. Install Flutter SDK.
2. From this folder, run:

```bash
flutter pub get
flutter run -d android
```

If you want exact Android Gradle wrapper files generated, run `flutter create .` once Flutter is installed (it will fill in tooling files while preserving this app code).
