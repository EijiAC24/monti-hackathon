# Monti Hackathon Edition

> 親が言いたいことを、AIキャラが代わりに伝える子供向けしつけアプリ
> カテゴリ: Live Agents | 締切: 2026-03-16 17:00 PDT

## Commands

```bash
flutter run                    # Run app (debug)
flutter build apk              # Build Android APK
flutter analyze                # Lint check
flutter test                   # Run tests
flutter pub get                # Install dependencies
```

## Project Structure

```
lib/
├── main.dart
├── app/                       # App config, router, theme
├── features/
│   ├── profile/               # Child profile input (P0)
│   ├── scenario/              # Scenario selection (P0)
│   ├── home/                  # Child home screen (P0)
│   └── conversation/          # Voice conversation (P0 - core)
├── models/                    # Data models
├── services/                  # Gemini Live API, Audio
└── shared/                    # Widgets, theme, constants
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| Client | Flutter (iOS/Android) |
| AI | Gemini 2.5 Flash Native Audio (Live API) |
| Backend | Cloud Run (Python) |
| Database | Firestore |
| Auth | Firebase Auth (P1) |
| State | Riverpod |
| Routing | go_router |

## Design System

```dart
const primary = Color(0xFFF97316);      // Warm Orange
const secondary = Color(0xFF22C55E);    // Forest Green
const accent = Color(0xFF0EA5E9);       // Sky Blue
const background = Color(0xFFFFFBF5);   // Warm Off-white
const textPrimary = Color(0xFF3D3D3D);  // Soft Black
```

- Font: Nunito (headings), Noto Sans JP (body)
- Child tap target: 64dp+
- Border radius: 16-24px

## Key Files

- @docs/hackathon-spec.md — Full specification
- @lib/services/gemini_live_service.dart — Gemini Live API
- @lib/features/conversation/ — Core conversation feature

## Rules

- P0 first, P1 only with spare time
- No Rive — use Flutter AnimationController
- Character: emoji placeholder → AI-generated PNG later
- Keep it simple, ship fast

## Schedule

| Day | Date | Focus |
|-----|------|-------|
| 1 | 3/12 | Foundation, profile, scenario screens |
| 2 | 3/13 | Gemini Live API, audio, Cloud Run |
| 3 | 3/14 | Conversation screen, UX polish |
| 4 | 3/15 | Deploy, Firestore, P1 features |
| 5 | 3/16 | Demo video, README, submission |
