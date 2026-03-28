# Gurmukhi SwiftUI App Scaffold

This folder contains a production-style SwiftUI MVVM scaffold for **Gurmukhi**, a daily Sikh spiritual reflection app.

## Folder structure

- `App/` app entry and root wiring
- `Models/` domain models
- `Services/` data repositories and daily selection logic
- `Core/` theme, routing, persistence, notifications
- `ViewModels/` onboarding, home, reflection, settings, global app state
- `Views/` onboarding, home, reflection cards, settings, reusable UI components
- `Resources/reflections.json` sample local content (ready to swap with API/Firestore later)

## Xcode setup

1. Open the generated project at `Gurmukhi.xcodeproj`.
2. In **Signing & Capabilities**, select your Apple Team and set a unique bundle id if needed.
3. Build/run on iPhone simulator or device.
4. On first launch, complete onboarding and allow notifications.

## Extensibility points

- Swap `ReflectionRepository` with Firestore/API implementation while keeping `ReflectionRepositoryProtocol`.
- Add audio playback by using `audioFileName` in `DailyReflectionView`.
- Add streaks/widgets by extending `AppViewModel` and persistence keys.
- Add scholar-reviewed metadata via `tags` and future fields in `ReflectionEntry`.

## Chaupai database

- SQLite database: `Resources/chaupai_verses.sqlite`
- Seed SQL (schema + inserts): `Resources/chaupai_seed.sql`
- Quick check:
  - `sqlite3 Resources/chaupai_verses.sqlite "SELECT COUNT(*) FROM chaupai_verses;"`
