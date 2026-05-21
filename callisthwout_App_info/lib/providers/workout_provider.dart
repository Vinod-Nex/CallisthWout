import 'dart:math';
import 'package:flutter/material.dart';
import '../data/user_data.dart';
import '../data/workout_data.dart';

enum DayType { push, pull, leg }

class WorkoutProvider extends ChangeNotifier {
  final UserData _userData;
  
  UserData get userData => _userData;

  WorkoutProvider(this._userData);

  int get currentDay => _userData.currentDay;
  bool get isTodayCompleted => _userData.isDayCompleted(currentDay);

  DayType getDayType(int day) {
    int remainder = day % 3;
    if (remainder == 1) return DayType.push;
    if (remainder == 2) return DayType.pull;
    return DayType.leg;
  }

  Week getWeek(int day) {
    int weekIndex = (day - 1) ~/ 7;
    // Cap at index 7 (Week 8) since we have 8 weeks in data
    weekIndex = min(weekIndex, 7);
    return WorkoutData.weeks[weekIndex];
  }

  List<Exercise> getExercisesForDay(int day) {
    final type = getDayType(day);
    final week = getWeek(day);
    List<Exercise> exercises;
    
    switch (type) {
      case DayType.push: exercises = week.push; break;
      case DayType.pull: exercises = week.pull; break;
      case DayType.leg: exercises = week.leg; break;
    }

    // Apply deload logic: Week 4 and Week 8 have only 2 sets
    if (week.theme.contains('Deload') || week.num == 4 || week.num == 8) {
      return exercises.map((e) => Exercise(
        name: e.name,
        sets: '2 sets', // Override sets
        reps: e.reps,
        note: e.note,
      )).toList();
    }

    return exercises;
  }

  Future<void> completeToday() async {
    await _userData.markDayCompleted(currentDay);
    if (currentDay < 60) {
      await _userData.setCurrentDay(currentDay + 1);
    } else {
      // Day 60 complete — reset the cycle
      await _userData.setCurrentDay(1);
    }
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await _userData.resetProgress();
    notifyListeners();
  }
}
