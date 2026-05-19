# CallisthWout
60‑day calisthenics app with PPL split, timers, videos &amp; nutrition – Flutter. CallisthWout is a mobile app (iOS &amp; Android) that delivers a structured 60‑day calisthenics program.  Push / Pull / Legs rotation with daily progressive overload  Timed workouts (warm‑up 5 min → 50 min main work → cool‑down 5 min)  8 weeks of exercises, including weeks.


# CallisthWout – 60‑Day Calisthenics Transformation App

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-blue)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**CallisthWout** is a mobile fitness app for iOS and Android that guides you through a **60‑day calisthenics program** with a rotating Push / Pull / Legs split. No gym required – just your bodyweight and optional a 20 kg bag from week 5 onwards.

![App Preview](assets/preview.gif) *Replace with a real GIF or screenshot collage*

---

## ✨ Features

- **Structured 60‑day plan** – 8 weeks of progressive overload, including two deload weeks.
- **Daily workouts** – 6 exercises per session, 4 sets each (2 sets on deload weeks).
- **Built‑in timers** – 5 min warm‑up → 50 min main work (1:30 work / 0:30 rest) → 5 min cool‑down.
- **Video library** – Warm‑up, cool‑down, and exercise‑specific YouTube links.
- **Calendar tracking** – See completed days, tap any day to review exercises.
- **Nutrition & recovery** – Macro targets (3000 kcal, 140g protein), sample Indian meal plan, hydration tracker, sleep and joint care tips.
- **Profile & settings** – Weight/height, dark/light mode, daily reminder (local notifications), reset progress, logout.
- **100% offline** – All workouts are stored locally; videos open via YouTube (internet only for those links).
- **Dark / light theme** – Respects system setting or manual override.

---

## 📱 Screenshots

| Home Dashboard | Active Workout | Calendar | Nutrition |
|----------------|----------------|----------|-----------|
| ![Home](screenshots/home.png) | ![Workout](screenshots/workout.png) | ![Calendar](screenshots/calendar.png) | ![Nutrition](screenshots/nutrition.png) |

*Replace with actual screenshots inside a `screenshots/` folder.*

---

## 🛠️ Tech Stack

- **Framework**: Flutter (SDK ≥3.22)
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Navigation**: Flutter built‑in router + bottom navigation bar
- **Video playback**: `youtube_player_flutter` + `url_launcher`
- **Notifications**: `flutter_local_notifications`
- **Audio cues**: `audioplayers` (optional)
- **Platform**: iOS 12+, Android 5+ (API 21+)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- iOS: Xcode (for iOS build) or Android: Android Studio / SDK.
- A device or emulator.

### Clone & Run

```bash
git clone https://github.com/YOUR_USERNAME/callisthwout.git
cd callisthwout
flutter pub get
flutter run
