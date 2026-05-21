import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static const String _keyCurrentDay = 'current_day';
  static const String _keyCompletedDays = 'completed_days';
  static const String _keyWeight = 'weight';
  static const String _keyHeight = 'height';

  static const String _keyHasOnboarded = 'has_onboarded';

  final SharedPreferences _prefs;

  UserData(this._prefs);

  static Future<UserData> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserData(prefs);
  }

  bool get hasOnboarded => _prefs.getBool(_keyHasOnboarded) ?? false;
  
  Future<void> setHasOnboarded(bool value) async {
    await _prefs.setBool(_keyHasOnboarded, value);
  }

  static const String _keyIsLoggedIn = 'is_logged_in';

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<void> setIsLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  int get currentDay => _prefs.getInt(_keyCurrentDay) ?? 1;

  Future<void> setCurrentDay(int day) async {
    await _prefs.setInt(_keyCurrentDay, day);
  }

  List<String> get completedDays => _prefs.getStringList(_keyCompletedDays) ?? [];

  Future<void> markDayCompleted(int day) async {
    final completed = completedDays;
    final dayStr = day.toString();
    if (!completed.contains(dayStr)) {
      completed.add(dayStr);
      await _prefs.setStringList(_keyCompletedDays, completed);
    }
  }
  
  bool isDayCompleted(int day) {
    return completedDays.contains(day.toString());
  }

  Future<void> resetProgress() async {
    await _prefs.remove(_keyCurrentDay);
    await _prefs.remove(_keyCompletedDays);
  }

  double get weight => _prefs.getDouble(_keyWeight) ?? 62.0;
  
  Future<void> setWeight(double w) async {
    await _prefs.setDouble(_keyWeight, w);
  }

  double get height => _prefs.getDouble(_keyHeight) ?? 170.0;

  Future<void> setHeight(double h) async {
    await _prefs.setDouble(_keyHeight, h);
  }
}
