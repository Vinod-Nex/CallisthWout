import 'package:flutter/foundation.dart';
import '../data/workout_data.dart';

enum WorkoutPhase { warmup, work, rest, cooldown, complete }

class TimerProvider extends ChangeNotifier {
  final List<Exercise> exercises;
  
  WorkoutPhase _currentPhase = WorkoutPhase.warmup;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _totalSets = 4; // Defaults to 4, but can be 2 for deload week
  
  bool _isPaused = false;

  TimerProvider(this.exercises, bool isDeload) {
    if (isDeload) {
      _totalSets = 2;
    }
  }

  WorkoutPhase get currentPhase => _currentPhase;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get currentSet => _currentSet;
  int get totalSets => _totalSets;
  bool get isPaused => _isPaused;

  Exercise get currentExercise => exercises[_currentExerciseIndex];

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void nextPhase() {
    switch (_currentPhase) {
      case WorkoutPhase.warmup:
        _currentPhase = WorkoutPhase.work;
        break;
      case WorkoutPhase.work:
        // Transition to rest or next exercise/cooldown
        if (_currentSet < _totalSets) {
          _currentPhase = WorkoutPhase.rest;
        } else {
          // Finished all sets for this exercise
          if (_currentExerciseIndex < exercises.length - 1) {
            _currentExerciseIndex++;
            _currentSet = 1;
            // The design says 5s transition between exercises. We can treat it as a short rest or jump directly to work.
            // For simplicity, let's go to work and let the UI handle a brief overlay if needed.
            _currentPhase = WorkoutPhase.work;
          } else {
            // Finished all exercises
            _currentPhase = WorkoutPhase.cooldown;
          }
        }
        break;
      case WorkoutPhase.rest:
        _currentSet++;
        _currentPhase = WorkoutPhase.work;
        break;
      case WorkoutPhase.cooldown:
        _currentPhase = WorkoutPhase.complete;
        break;
      case WorkoutPhase.complete:
        break;
    }
    notifyListeners();
  }

  void skipRest() {
    if (_currentPhase == WorkoutPhase.rest) {
      nextPhase();
    }
  }
}
