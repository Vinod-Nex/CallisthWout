import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings values
  int _calorieTarget = 3000;
  bool _hapticsEnabled = true;
  bool _workoutReminder = false;
  bool _nutritionLog = false;
  bool _communityMilestones = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);

  static const _caloriesKey = 'calorie_target';
  static const _hapticsKey = 'haptics_enabled';
  static const _workoutReminderKey = 'notif_workout';
  static const _nutritionLogKey = 'notif_nutrition';
  static const _communityKey = 'notif_community';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinKey = 'reminder_min';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _calorieTarget = p.getInt(_caloriesKey) ?? 3000;
      _hapticsEnabled = p.getBool(_hapticsKey) ?? true;
      _workoutReminder = p.getBool(_workoutReminderKey) ?? false;
      _nutritionLog = p.getBool(_nutritionLogKey) ?? false;
      _communityMilestones = p.getBool(_communityKey) ?? false;
      final h = p.getInt(_reminderHourKey) ?? 19;
      final m = p.getInt(_reminderMinKey) ?? 0;
      _reminderTime = TimeOfDay(hour: h, minute: m);
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_caloriesKey, _calorieTarget);
    await p.setBool(_hapticsKey, _hapticsEnabled);
    await p.setBool(_workoutReminderKey, _workoutReminder);
    await p.setBool(_nutritionLogKey, _nutritionLog);
    await p.setBool(_communityKey, _communityMilestones);
    await p.setInt(_reminderHourKey, _reminderTime.hour);
    await p.setInt(_reminderMinKey, _reminderTime.minute);
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved ✓'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save', style: TextStyle(color: AppTheme.getPushColor(context), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          // ── Goals ─────────────────────────────────────────────────────────
          _SectionHeader('🎯 Calorie Goal'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Calories', style: Theme.of(context).textTheme.bodyLarge),
                    Text('$_calorieTarget kcal',
                      style: TextStyle(color: AppTheme.getPushColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _calorieTarget.toDouble(),
                  min: 1800,
                  max: 4500,
                  divisions: 27,
                  activeColor: AppTheme.getPushColor(context),
                  onChanged: (v) => setState(() => _calorieTarget = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1800', style: Theme.of(context).textTheme.labelSmall),
                    Text('4500', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),

          // ── Haptics ──────────────────────────────────────────────────────
          _SectionHeader('📳 Haptic Feedback'),
          Container(
            decoration: _cardDecor(context),
            child: _ToggleRow(
              icon: Icons.vibration_rounded,
              label: 'Haptic feedback on timers',
              value: _hapticsEnabled,
              onChanged: (v) => setState(() => _hapticsEnabled = v),
            ),
          ),

          // ── Notifications ─────────────────────────────────────────────────
          _SectionHeader('🔔 Notifications'),
          Container(
            decoration: _cardDecor(context),
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.fitness_center,
                  label: 'Workout Reminder',
                  value: _workoutReminder,
                  onChanged: (v) => setState(() => _workoutReminder = v),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _ToggleRow(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Nutrition Log Reminder',
                  value: _nutritionLog,
                  onChanged: (v) => setState(() => _nutritionLog = v),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _ToggleRow(
                  icon: Icons.emoji_events_outlined,
                  label: 'Community Milestones',
                  value: _communityMilestones,
                  onChanged: (v) => setState(() => _communityMilestones = v),
                ),
                if (_workoutReminder || _nutritionLog) ...[
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  InkWell(
                    onTap: _pickTime,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 22),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Reminder Time', style: Theme.of(context).textTheme.bodyLarge)),
                          Text(
                            _reminderTime.format(context),
                            style: TextStyle(color: AppTheme.getPushColor(context), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader('ℹ️ About'),
          Container(
            decoration: _cardDecor(context),
            child: Column(
              children: [
                _InfoRow(label: 'Version', value: '1.0.0'),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _InfoRow(label: 'Programme', value: '60-Day Calisthenics'),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _InfoRow(label: 'Target', value: '~3,000 kcal / day'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecor(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Theme.of(context).dividerColor),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.successLight),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
