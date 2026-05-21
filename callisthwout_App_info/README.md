# CallisthWout 💪

A **60-day calisthenics training app** built with Flutter — featuring structured Push/Pull/Leg workout programming, real-time workout timers, nutrition tracking, and full Firebase Authentication.

---

## Features

| Feature | Status |
|---|---|
| 🔐 Firebase Auth (Email + Google Sign-In) | ✅ |
| 🏠 Home Dashboard | ✅ |
| 📅 60-Day Calendar with completion tracking | ✅ |
| ▶️ Active Workout Timer (warmup → work → rest → cooldown) | ✅ |
| 🎉 Completion Screen with confetti + stats | ✅ |
| 🍽️ Nutrition & Recovery (hydration ring, meal plan) | ✅ |
| 📚 Exercise Library + Video Resources | ✅ |
| 👤 Profile (biometrics, theme, reminders) | ✅ |
| ⚙️ Settings (calorie goal, haptics, notifications) | ✅ |
| 🌙 Dark / Light / System theme | ✅ |
| 📳 Haptic feedback on timer intervals | ✅ |
| 🧪 Unit tests (27 passing) | ✅ |

---

## Project Structure

```
callisthwout_app/
├── lib/
│   ├── data/
│   │   ├── user_data.dart          # SharedPreferences persistence
│   │   ├── workout_data.dart       # 8-week workout programme
│   │   └── resources_data.dart     # Nutrition, meal plan, video IDs
│   ├── providers/
│   │   ├── workout_provider.dart   # Business logic: day type, completion
│   │   ├── timer_provider.dart     # Workout phase state machine
│   │   └── theme_provider.dart     # Dark/Light/System theme
│   ├── screens/
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_navigator.dart     # 5-tab bottom nav
│   │   ├── home_screen.dart
│   │   ├── calendar_screen.dart    # Phase 3: 60-day grid
│   │   ├── active_workout_screen.dart  # Phase 4: timer state machine
│   │   ├── completion_screen.dart  # Phase 4: post-workout
│   │   ├── nutrition_screen.dart   # Phase 5
│   │   ├── resources_screen.dart   # Phase 5
│   │   ├── profile_screen.dart     # Phase 5
│   │   └── settings_screen.dart    # Phase 6
│   ├── services/
│   │   └── auth_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── main.dart
└── test/
    └── workout_logic_test.dart     # 27 unit tests
```

---

## Build Instructions

### Prerequisites

- Flutter SDK >= 3.11.x
- Dart SDK >= 3.11.x
- Xcode (iOS builds)
- Android Studio / Android SDK (Android builds)
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

### 1. Install Dependencies

```bash
cd callisthwout_app
flutter pub get
```

### 2. Configure Firebase

```bash
firebase login
flutterfire configure
```

This generates `lib/firebase_options.dart`. Then update `lib/main.dart`:

```dart
import 'firebase_options.dart';
// Change: await Firebase.initializeApp();
// To:    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Run in Development

```bash
flutter run -d iPhone        # iOS Simulator
flutter run -d android       # Android Emulator
flutter run -d chrome        # Web (limited Firebase support)
```

### 4. Run Unit Tests

```bash
flutter test test/workout_logic_test.dart --reporter expanded
```

Expected: **27 tests, all passing**.

### 5. Release Build

```bash
flutter build ipa --release            # iOS
flutter build appbundle --release      # Android (App Bundle for Play Store)
flutter build apk --release --split-per-abi   # Android APK
```

---

## 60-Day Programme Logic

| Days | Pattern | Week Type |
|---|---|---|
| 1, 4, 7, 10 ... | Push (Chest/Shoulders/Triceps) | Normal (4 sets) |
| 2, 5, 8, 11 ... | Pull (Back/Biceps) | Normal (4 sets) |
| 3, 6, 9, 12 ... | Legs (Quads/Glutes/Core) | Normal (4 sets) |
| Weeks 4 and 8 | All types | Deload (2 sets) |

After **Day 60**, the counter resets to Day 1 for a new cycle. All historical completions are preserved.

---

## Architecture

- **State**: `provider` with `ChangeNotifier` (WorkoutProvider, ThemeProvider)
- **Persistence**: `SharedPreferences` for progress, theme, hydration, biometrics
- **Auth**: Firebase Auth + Google Sign-In with graceful degradation for UI testing
- **Background**: `WidgetsBindingObserver` saves timer state on pause, Resume dialog on return
- **Haptics**: `HapticFeedback.mediumImpact()` on work->rest, `.heavyImpact()` on set completion
- **Timer**: `Timer.periodic` for full control of phase transitions

---

## Theme Colours

| Token | Light | Dark |
|---|---|---|
| Background | #FDF8F8 | #121212 |
| Surface | #F5F5F5 | #1E1E1E |
| Border | #E5E5EA | #38383A |
| Push accent | #D85A30 | #E57342 |
| Pull accent | #378ADD | #5BA0D9 |
| Legs accent | #1D9E75 | #2BBF8F |
| Success | #34C759 | #30B350 |
