---
name: CallisthWout Design System
colors:
  surface: '#fdf8f8'
  surface-dim: '#ddd9d9'
  surface-bright: '#fdf8f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3f2'
  surface-container: '#f1edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#46464a'
  inverse-surface: '#313030'
  inverse-on-surface: '#f4f0ef'
  outline: '#77767b'
  outline-variant: '#c7c6ca'
  surface-tint: '#5f5e60'
  primary: '#010102'
  on-primary: '#ffffff'
  primary-container: '#1c1c1e'
  on-primary-container: '#858486'
  inverse-primary: '#c8c6c8'
  secondary: '#5e5e62'
  on-secondary: '#ffffff'
  secondary-container: '#e0dfe3'
  on-secondary-container: '#626266'
  tertiary: '#010100'
  on-tertiary: '#ffffff'
  tertiary-container: '#1f1b1a'
  on-tertiary-container: '#8a8381'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e4e2e4'
  primary-fixed-dim: '#c8c6c8'
  on-primary-fixed: '#1b1b1d'
  on-primary-fixed-variant: '#474649'
  secondary-fixed: '#e3e2e6'
  secondary-fixed-dim: '#c7c6ca'
  on-secondary-fixed: '#1b1b1f'
  on-secondary-fixed-variant: '#46464a'
  tertiary-fixed: '#eae0de'
  tertiary-fixed-dim: '#cdc5c3'
  on-tertiary-fixed: '#1f1b1a'
  on-tertiary-fixed-variant: '#4b4644'
  background: '#fdf8f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
  push-accent: '#D85A30'
  pull-accent: '#378ADD'
  legs-accent: '#1D9E75'
  push-accent-dark: '#E57342'
  pull-accent-dark: '#5BA0D9'
  legs-accent-dark: '#2BBF8F'
  success: '#34C759'
  success-dark: '#30B350'
  bg-secondary-light: '#F5F5F5'
  bg-secondary-dark: '#1E1E1E'
  border-light: '#E5E5EA'
  border-dark: '#38383A'
typography:
  timer-display:
    fontFamily: JetBrains Mono
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: -0.02em
  headline-main:
    fontFamily: Lexend
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  subheadline:
    fontFamily: Lexend
    fontSize: 17px
    fontWeight: '500'
    lineHeight: 22px
  body-primary:
    fontFamily: Lexend
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 22px
  body-secondary:
    fontFamily: Lexend
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1rem
  stack-gap-lg: 1.5rem
  stack-gap-md: 1rem
  stack-gap-sm: 0.5rem
  timer-safe-area: 3rem
---

# Calisthenics 60‑Day Transformation App – UI/UX Design Document

## 1. Overview

This document defines the user interface and user experience design for a mobile app (iOS & Android) that delivers a structured 60‑day calisthenics program. The app guides users through daily push/pull/legs workouts with timed warm‑up, main work, and cool‑down phases, automatically recycling the cycle after completion. The primary goal is to provide a clear, motivational, and timer‑driven experience that helps users gain muscle mass and strength using only bodyweight or minimal equipment (e.g., a 20 kg bag in later weeks).

**Source of truth** – All workout data (8 weeks, 3 workout types, 6 exercises per day, sets/reps, progression notes) is taken from the provided HTML plan. Warm‑up and cool‑down YouTube links are also referenced from that document.

---

## 2. Target Users

- **Primary** – Individuals at beginner to intermediate level (example stats: 62 kg, 170 cm) aiming to build muscle, improve movement quality, and follow a consistent home workout routine.
- **Secondary** – Users who have some calisthenics experience and want a structured 60‑day overload plan with deload weeks.
- **Motivations** – No gym access, need timing guidance, want to see daily progress, appreciate video references for form.

---

## 3. Design Principles

| Principle | Description |
|-----------|-------------|
| **Glanceable** | During workouts, timers and exercise names must be readable from 1–2 meters (phone on floor). |
| **Motivating** | Celebratory animations, progress rings, and clear day counts keep users engaged. |
| **Error‑tolerant** | App must survive backgrounding, resume workouts, and never lose day completion data. |
| **Minimal** | No distracting UI during active sessions – only essential controls (pause, skip rest, volume). |
| **Accessible** | VoiceOver/TalkBack support, haptic feedback at timer ends, high contrast mode. |

---

## 4. Color Palette (Light & Dark Mode)

| Role | Light Mode | Dark Mode |
|------|------------|-----------|
| Background primary | `#FFFFFF` | `#121212` |
| Background secondary | `#F5F5F5` | `#1E1E1E` |
| Text primary | `#1C1C1E` | `#FFFFFF` |
| Text secondary | `#6C6C70` | `#8E8E93` |
| Push accent | `#D85A30` | `#E57342` |
| Pull accent | `#378ADD` | `#5BA0D9` |
| Legs accent | `#1D9E75` | `#2BBF8F` |
| Success / complete | `#34C759` | `#30B350` |
| Border / divider | `#E5E5EA` | `#38383A` |

- The accent colour changes dynamically on the active workout screen and home card based on the day’s workout type (Push/Pull/Legs).

---

## 5. Typography

- **System fonts** – SF Pro (iOS) / Roboto (Android).
- **Headings** – Bold, 22 pt, `#1C1C1E` (light) / `#FFFFFF` (dark).
- **Subheadings** – Medium, 17 pt.
- **Exercise name** – Medium, 17 pt, primary text.
- **Timer digits** – Monospace (SF Mono / Roboto Mono), 48 pt, bold.
- **Coaching note / rep target** – Regular, 13 pt, secondary text.

---

## 6. User Flows

### 6.1 Login & Onboarding

1. **Screen: Login**  
   - Fields: Email, Password.  
   - Buttons: “Sign In”, “Sign Up”, “Continue as Guest” (local storage only).  
   - Optional: “Sign in with Google/Apple”.

2. **Screen: Quick Onboarding** (new users only)  
   - Step 1: Enter weight (pre‑fill 62 kg) and height (170 cm).  
   - Step 2: Choose reminder time (e.g., 7 PM).  
   - Step 3: Welcome screen with program overview (8 weeks, 60 days, deload weeks).  
   - → Navigate to Home.

### 6.2 Home (Dashboard) Screen

- **Top**: Greeting (“Good morning, Alex”), profile icon (taps to Settings: edit stats, logout, reminder).
- **Progress ring** (circular) – shows completion of current 60‑day cycle. Inner text: “Day 14 of 60”.
- **Today’s workout card**:
  - Day type (Push / Pull / Legs) with corresponding accent colour.
  - Muscle focus (e.g., “Chest · Shoulders · Triceps”).
  - Week theme (e.g., “Week 3 – tempo focus”).
  - Preview of first two exercises.
  - **Large “Start Workout” button** (disabled if already completed today).
- **Recovery tip** – small banner (changes daily, e.g., “Sleep 7–9h for muscle growth”).
- **Bottom navigation bar** (4 icons):
  - Home (Today)
  - Calendar
  - Nutrition & Recovery
  - Resources

### 6.3 Calendar Screen

- **Two‑month grid** (60 days, 8 weeks).  
- Each day cell shows:
  - Day number (1–60).
  - Small icon: 💪 (Push), 🏋️ (Pull), 🦵 (Legs).
  - Green checkmark overlay if completed.
- **Tap a day** → Modal bottom sheet with:
  - Full workout (6 exercises with sets/reps/coaching note).
  - “Watch warm‑up” and “Watch cool‑down” links.
  - If day is future – cannot mark complete; if past – read‑only.
- **Today indicator** – highlighted border or background.

### 6.4 Active Workout Screen (most critical)

Launch from Home → immediately shows warm‑up phase.

#### Phases

| Phase | Duration | Behaviour |
|-------|----------|-----------|
| **Warm‑up** | 5 min | Embedded YouTube video (day‑specific, from resources). Timer counts down 5:00 → 0:00. No rest; no pause between exercises. |
| **Main workout** | 50 min | 6 exercises × 4 sets each (except deload week: 2 sets). Per set: 1:30 work → 0:30 rest. After 4th set of an exercise → 5 sec transition to next exercise. |
| **Cool‑down** | 5 min | Video + countdown timer. Automatically starts after last set of last exercise. |

#### Active Workout UI Components

**Top bar**:
- Phase label (“Warm‑up” / “Workout” / “Cool‑down”).
- Elapsed time / total time (e.g., “12:34 / 60:00”).
- Pause button (stops all timers).
- Volume toggle (mute audio cues).

**During main workout** (central area):
- **Exercise name** (large, bold).
- **Coaching note** (small, below exercise name, e.g., “2 sec descent”).
- **Set indicator**: “Set 2 of 4”.
- **Rep target**: “10–12 reps” (or “Max reps” for test days).
- **Timer display**:
  - **Work interval** – large circular progress ring or big digital countdown (1:30 → 0:00). Ring colour = day type accent.
  - **Rest interval** – same ring, colour grey, countdown from 30s. Text: “Rest”.
- **Control button** – “Skip rest” (jumps to next set/exercise).  
- **Manual next** – “Set done early” (triggers rest immediately).

**Between exercises** (after 4th set of an exercise):
- Banner appears for 5 seconds: “Next: Wide push‑ups”. Then automatically starts next exercise’s first set.

**During warm‑up / cool‑down**:
- Video occupies central area (embedded YouTube player with “Watch on YouTube” fallback link).
- Timer overlay at bottom.

**Completion screen** (after cool‑down):
- Full‑screen animation (confetti or rising text).
- Message: “Congratulations! Day 14 complete 🎉”
- Buttons: “Go to Home” | “Preview tomorrow’s workout”.

### 6.5 Nutrition & Recovery Screen

- Two main cards:
  - **Daily macro targets** – protein, carbs, fats, calories, water (from given plan: ~3000 kcal, 135‑145g protein, 370‑410g carbs, 75‑85g fat).
  - **Sample meal plan** (Indian foods as per HTML) – collapsible sections for breakfast, lunch, dinner, etc.
- **Recovery rules** – sleep (7‑9h), active recovery (walk 20 min), deload info, joint care.
- **Edit calorie target** – optional slider (default 3000) with updated macro estimates.

### 6.6 Resources Screen

- Tab bar (3 tabs):
  1. **Warm‑up** – push, pull, legs videos (links from original plan).
  2. **Cool‑down** – respective videos.
  3. **Exercise library** – list of all exercises (grouped by muscle group) with thumbnails and clickable YouTube links.
- Tapping a link opens in‑app WebView or external YouTube app.

### 6.7 Settings (accessed from Home profile icon)

- Edit weight / height (recalculates calorie suggestion).
- Change reminder time.
- Reset progress (confirmation dialog – clears all day completions, resets day counter to 1).
- Logout / switch account.
- Dark mode toggle (follow system by default).

---

## 7. Component Library

| Component | Description | States |
|-----------|-------------|--------|
| `PrimaryButton` | Large, rounded (12px), solid fill, gradient optional. | default, pressed, disabled. |
| `SecondaryButton` | Outline, same rounding. | default, pressed. |
| `WorkoutCard` | Home screen card with day type badge, exercise preview, start button. | – |
| `TimerRing` | Circular progress (SVG or Lottie) that animates from full to empty. Colour = accent. | work, rest, transition. |
| `BottomNavBar` | 4 icons + labels (Home, Calendar, Nutrition, Resources). | active (colored), inactive (grey). |
| `DayCell` (Calendar) | 44×44pt minimum, shows day number + icon + optional checkmark. | default, completed, today. |
| `ProgressRing` (Home) | Circular ring showing days completed / 60. Inner label “Day X/60”. | – |
| `VideoEmbed` | Thumbnail + play icon, taps to open YouTube (in‑app or external). | – |
| `ModalBottomSheet` | For day details, comes from bottom, dismiss by drag down. | – |

---

## 8. Data Logic (How the app determines each day’s workout)

- **Current day counter** stored in `UserDefaults` / local database (1…60). Increments after successful completion.
- **Week number** = `ceil(currentDay / 7)` → 1…8.
- **Day type**:
  - `(currentDay % 3 == 1)` → Push
  - `(currentDay % 3 == 2)` → Pull
  - `(currentDay % 3 == 0)` → Legs
- **Exercise list** fetched from `weeks[week‑1][dayType]` array (see HTML data).
  - For week 4 and week 8 (deload) → override `sets` field to “2 sets” for all exercises, but keep same reps/notes.
- **Warm‑up / cool‑down video URLs** mapped by day type (from “Resources” section in HTML).
- **Day 60 completion** → mark cycle done, show celebration, reset counter to 0 (or 1 for next day) automatically. Next time user opens, day = 1 again, but history of previous cycles is stored (optional).

---

## 9. Edge Cases & Handling

| Scenario | Handling |
|----------|----------|
| App closed during active workout | Save session state (current phase, exercise index, set index, timer remaining). When reopened, prompt “Resume workout?” → yes restores exactly. |
| Skip rest early | Immediately go to next set (or next exercise if last set). Still enforce 1.5 min work time – user cannot cut work short unless they manually tap “Set done early”. |
| Offline mode | All workout data cached; videos show placeholder image and “Watch when online” label. Timers work offline. |
| Deload week reminder | On Home screen, small banner appears: “This is a deload week – only 2 sets per exercise.” |
| Day 60 completed | After completion screen, show “Cycle complete! Tomorrow starts Day 1 of a new 60‑day journey.” |
| User wants to repeat an already completed day | Calendar → tap past day → “Redo workout” button. Redo does **not** change current day counter but marks that day as “redone” (optional). |
| User manually changes system time | Use server timestamp (if logged in) or store session start time to prevent cheating. For guest mode, allow but show warning. |

---

## 10. Dark Mode Specifications

- All colours defined in section 4 have dark mode equivalents.
- Timer ring changes contrast (lighter accent colours on dark background).
- Bottom navigation icons invert.
- Cards have a subtle border (0.5px) in dark mode instead of shadow.
- Video embed background becomes `#1C1C1E`.

---

## 11. Accessibility (A11Y)

- **VoiceOver / TalkBack**:
  - All buttons have descriptive labels (“Start today’s push workout”).
  - Timer digits announce remaining seconds every 10 seconds.
  - Exercise names and set numbers are read automatically when screen changes.
- **Haptics**:
  - Light vibration at end of work interval.
  - Slightly stronger vibration at end of rest interval.
  - Toggle in settings to turn haptics off.
- **High contrast mode** – respects system “Increase Contrast” setting (border widths increase, shadows removed).
- **Text size** – scales with system dynamic type up to 150%.

---

## 12. Deliverables for Design Team

1. **High‑fidelity Figma / Sketch file** containing:
   - Login & onboarding screens.
   - Home dashboard (with progress ring and workout card).
   - Calendar screen (two months grid + day modal).
   - Active workout screen (warm‑up, work interval, rest interval, cool‑down, completion).
   - Nutrition & Recovery screen.
   - Resources screen (tabs).
   - Settings screen.
2. **Component variants** – light/dark mode for each screen.
3. **Prototype** linking the main flow: Login → Home → Start Workout → complete → return to Home with updated day.
4. **Icon set** – bottom navigation, exercise placeholders, checkmark, play button, etc.
5. **Motion guidelines**:
   - Progress ring animation duration = timer duration.
   - Transition between exercises: fade + slide up (0.2s).
   - Completion: confetti burst (2s) followed by optional haptic success.

---

## 13. References to Original Data

- **Workout weeks** – weeks array (8 weeks) from the provided HTML. Each week contains `push`, `pull`, `leg` arrays with 6 exercises (name, sets, reps, note).
- **Warm‑up / cool‑down videos** – from the “Resources” section of the HTML.
- **Nutrition macros** – from the “Nutrition & recovery” section.
- **Deload weeks** – week 4 and week 8 have reduced sets.

> ⚠️ The design must respect the exact exercise names, rep ranges, and progression notes as they appear in the original plan. No creative changes to the workout content.

---

## 14. Success Metrics (for design validation)

- User can complete a full workout **without needing to look at any external notes**.
- Average time to start a workout from opening the app < 15 seconds.
- 80% of test users understand the 60‑day loop and the concept of deload weeks.
- No user asks “what exercise comes next?” – the UI makes sequence obvious.

---

**Document version** – 1.0  
**Last updated** – 2026‑05‑14  
**Intended for** – UI/UX designers, frontend developers, QA testers.