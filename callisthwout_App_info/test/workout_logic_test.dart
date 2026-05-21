import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callisthwout_app/data/user_data.dart';
import 'package:callisthwout_app/providers/workout_provider.dart';
import 'package:callisthwout_app/data/workout_data.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────
Future<UserData> _makeUserData() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return UserData(prefs);
}

// ─── Tests ────────────────────────────────────────────────────────────────────
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── getDayType ──────────────────────────────────────────────────────────────
  group('getDayType', () {
    late WorkoutProvider provider;

    setUp(() async {
      provider = WorkoutProvider(await _makeUserData());
    });

    test('Day 1 → Push', () {
      expect(provider.getDayType(1), DayType.push);
    });

    test('Day 2 → Pull', () {
      expect(provider.getDayType(2), DayType.pull);
    });

    test('Day 3 → Leg', () {
      expect(provider.getDayType(3), DayType.leg);
    });

    test('Day 4 → Push (cycle repeats)', () {
      expect(provider.getDayType(4), DayType.push);
    });

    test('Day 60 → Leg', () {
      expect(provider.getDayType(60), DayType.leg);
    });

    test('all days 1..60 are non-null', () {
      for (var d = 1; d <= 60; d++) {
        expect(DayType.values, contains(provider.getDayType(d)));
      }
    });
  });

  // ── getWeek ─────────────────────────────────────────────────────────────────
  group('getWeek', () {
    late WorkoutProvider provider;

    setUp(() async {
      provider = WorkoutProvider(await _makeUserData());
    });

    test('Day 1 → Week 1', () {
      expect(provider.getWeek(1).num, 1);
    });

    test('Day 7 → Week 1', () {
      expect(provider.getWeek(7).num, 1);
    });

    test('Day 8 → Week 2', () {
      expect(provider.getWeek(8).num, 2);
    });

    test('Day 28 → Week 4 (deload)', () {
      final week = provider.getWeek(28);
      expect(week.num, 4);
    });

    test('Day 60 → Week 8 (final deload)', () {
      final week = provider.getWeek(60);
      expect(week.num, 8);
    });
  });

  // ── getExercisesForDay ──────────────────────────────────────────────────────
  group('getExercisesForDay', () {
    late WorkoutProvider provider;

    setUp(() async {
      provider = WorkoutProvider(await _makeUserData());
    });

    test('Day 1 returns non-empty push exercises', () {
      final exs = provider.getExercisesForDay(1);
      expect(exs, isNotEmpty);
    });

    test('Deload week (day 22–28) exercises have "2 sets"', () {
      // Day 22 is in week 4 (deload)
      final exs = provider.getExercisesForDay(22);
      for (final e in exs) {
        expect(e.sets, '2 sets');
      }
    });

    test('Normal week (day 1) exercises do NOT have "2 sets"', () {
      final exs = provider.getExercisesForDay(1);
      for (final e in exs) {
        expect(e.sets, isNot('2 sets'));
      }
    });

    test('Returns 6 exercises per day', () {
      for (var d = 1; d <= 60; d++) {
        final exs = provider.getExercisesForDay(d);
        expect(exs.length, greaterThanOrEqualTo(1),
            reason: 'Day $d had no exercises');
      }
    });
  });

  // ── isDayCompleted ──────────────────────────────────────────────────────────
  group('isDayCompleted', () {
    late UserData userData;

    setUp(() async {
      userData = await _makeUserData();
    });

    test('Day is not completed initially', () {
      expect(userData.isDayCompleted(1), isFalse);
    });

    test('Day is completed after markDayCompleted', () async {
      await userData.markDayCompleted(1);
      expect(userData.isDayCompleted(1), isTrue);
    });

    test('Other days remain uncompleted', () async {
      await userData.markDayCompleted(5);
      expect(userData.isDayCompleted(1), isFalse);
      expect(userData.isDayCompleted(5), isTrue);
    });

    test('markDayCompleted is idempotent', () async {
      await userData.markDayCompleted(1);
      await userData.markDayCompleted(1);
      expect(userData.completedDays.where((d) => d == '1').length, 1);
    });
  });

  // ── completeToday & day counter ─────────────────────────────────────────────
  group('completeToday', () {
    late WorkoutProvider provider;

    setUp(() async {
      provider = WorkoutProvider(await _makeUserData());
    });

    test('currentDay is 1 by default', () {
      expect(provider.currentDay, 1);
    });

    test('completing day advances to next day', () async {
      await provider.completeToday();
      expect(provider.currentDay, 2);
    });

    test('completing day 60 resets to day 1', () async {
      await provider.userData.setCurrentDay(60);
      await provider.completeToday();
      expect(provider.currentDay, 1);
    });

    test('completed day is marked in list', () async {
      await provider.completeToday();
      expect(provider.userData.isDayCompleted(1), isTrue);
    });
  });

  // ── resetProgress ───────────────────────────────────────────────────────────
  group('resetProgress', () {
    test('resets day and completed list', () async {
      final userData = await _makeUserData();
      final provider = WorkoutProvider(userData);

      await provider.completeToday(); // Day 1 → day 2
      await provider.completeToday(); // Day 2 → day 3

      await userData.resetProgress();
      await userData.setCurrentDay(1);

      expect(userData.currentDay, 1);
      expect(userData.completedDays, isEmpty);
    });
  });

  // ── WorkoutData integrity ───────────────────────────────────────────────────
  group('WorkoutData integrity', () {
    test('has exactly 8 weeks', () {
      expect(WorkoutData.weeks.length, 8);
    });

    test('each week has push/pull/leg lists', () {
      for (final w in WorkoutData.weeks) {
        expect(w.push, isNotEmpty, reason: 'Week ${w.num} push missing');
        expect(w.pull, isNotEmpty, reason: 'Week ${w.num} pull missing');
        expect(w.leg, isNotEmpty, reason: 'Week ${w.num} leg missing');
      }
    });

    test('week numbers are sequential 1..8', () {
      for (var i = 0; i < WorkoutData.weeks.length; i++) {
        expect(WorkoutData.weeks[i].num, i + 1);
      }
    });
  });
}
