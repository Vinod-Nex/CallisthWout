import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../data/user_data.dart';
import '../providers/workout_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Editable Biometrics ────────────────────────────────────────────────────
  double _weight = 62.0;
  double _height = 170.0;

  // ── Preferences ────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.system;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _remindersEnabled = false;

  static const _themeKey = 'theme_mode';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinKey = 'reminder_min';
  static const _reminderEnabledKey = 'reminder_enabled';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userData = context.read<UserData>();
    final p = await SharedPreferences.getInstance();
    setState(() {
      _weight = userData.weight;
      _height = userData.height;
      final modeIdx = p.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[modeIdx];
      final h = p.getInt(_reminderHourKey) ?? 19;
      final m = p.getInt(_reminderMinKey) ?? 0;
      _reminderTime = TimeOfDay(hour: h, minute: m);
      _remindersEnabled = p.getBool(_reminderEnabledKey) ?? false;
    });
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    await context.read<ThemeProvider>().setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_reminderHourKey, picked.hour);
      await p.setInt(_reminderMinKey, picked.minute);
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _toggleReminder(bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_reminderEnabledKey, val);
    setState(() => _remindersEnabled = val);
  }

  void _showEditMetrics() {
    final wCtrl = TextEditingController(text: _weight.toStringAsFixed(1));
    final hCtrl = TextEditingController(text: _height.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('Update Metrics', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 20),
                _MetricField(controller: wCtrl, label: 'Weight (kg)', icon: Icons.monitor_weight_outlined),
                const SizedBox(height: 14),
                _MetricField(controller: hCtrl, label: 'Height (cm)', icon: Icons.height_rounded),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final w = double.tryParse(wCtrl.text) ?? _weight;
                      final h = double.tryParse(hCtrl.text) ?? _height;
                      final userData = context.read<UserData>();
                      await userData.setWeight(w);
                      await userData.setHeight(h);
                      setState(() { _weight = w; _height = h; });
                      if (ctx.mounted) Navigator.pop(ctx);
                      HapticFeedback.lightImpact();
                    },
                    child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all completed workouts and reset your day counter to Day 1. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              final wp = context.read<WorkoutProvider>();
              await wp.userData.resetProgress();
              await wp.userData.setCurrentDay(1);
              wp.resetProgress();
              HapticFeedback.heavyImpact();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset! Day 1, let\'s go again 💪'), duration: Duration(seconds: 3)),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final provider = context.read<WorkoutProvider>();
    final daysCompleted = provider.userData.completedDays.length;
    final currentDay = provider.currentDay;

    // Show a summary dialog so user knows their progress is saved to their account
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your workout progress is saved to your account and will be waiting when you sign back in.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(ctx).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(ctx).dividerColor),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    icon: '📅',
                    label: 'Current Day',
                    value: 'Day $currentDay / 60',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    icon: '✅',
                    label: 'Days Completed',
                    value: '$daysCompleted workouts',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    icon: '🔥',
                    label: 'Journey',
                    value: '${(daysCompleted / 60 * 100).round()}% done',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    await context.read<AppAuthProvider>().signOut();
    // StreamBuilder in main.dart automatically navigates to LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final daysCompleted = provider.userData.completedDays.length;
    final currentDay = provider.currentDay;
    final progress = (daysCompleted / 60).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          // ── Avatar / Header ──────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Builder(builder: (context) {
                  final authProv = context.watch<AppAuthProvider>();
                  final displayName = authProv.displayName;
                  final email = authProv.email;
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Theme.of(context).cardColor,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(displayName, style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text(email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                }),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.getPushColor(context), AppTheme.getPullColor(context)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🏅 Calisthenics Athlete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Journey Stats ────────────────────────────────────────────────
          _SectionLabel('📊 Journey Stats'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatTile(label: 'Current Day', value: '$currentDay / 60', icon: '📅', flex: 1),
                    _StatTile(label: 'Days Done', value: '$daysCompleted', icon: '✅', flex: 1),
                    _StatTile(label: 'Journey', value: '${(progress * 100).round()}%', icon: '🔥', flex: 1),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getPushColor(context)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Biometrics ───────────────────────────────────────────────────
          _SectionLabel('⚖️ Biometrics'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: '${_weight.toStringAsFixed(1)} kg',
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _InfoRow(
                  icon: Icons.height_rounded,
                  label: 'Height',
                  value: '${_height.toStringAsFixed(0)} cm',
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Update Metrics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _showEditMetrics,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Appearance ───────────────────────────────────────────────────
          _SectionLabel('🎨 Appearance'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _AppearanceOption(
                  label: '☀️ Light',
                  selected: _themeMode == ThemeMode.light,
                  onTap: () => _saveTheme(ThemeMode.light),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _AppearanceOption(
                  label: '🌙 Dark',
                  selected: _themeMode == ThemeMode.dark,
                  onTap: () => _saveTheme(ThemeMode.dark),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _AppearanceOption(
                  label: '📱 System',
                  selected: _themeMode == ThemeMode.system,
                  onTap: () => _saveTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Reminders ────────────────────────────────────────────────────
          _SectionLabel('🔔 Daily Reminder'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Workout Reminder', style: Theme.of(context).textTheme.bodyLarge)),
                      Switch(
                        value: _remindersEnabled,
                        onChanged: _toggleReminder,
                        activeThumbColor: AppTheme.successLight,
                      ),
                    ],
                  ),
                ),
                if (_remindersEnabled) ...[
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  InkWell(
                    onTap: _pickReminderTime,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 22),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Reminder time', style: Theme.of(context).textTheme.bodyLarge)),
                          Text(
                            _reminderTime.format(context),
                            style: TextStyle(color: AppTheme.getPushColor(context), fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Account Actions ──────────────────────────────────────────────
          _SectionLabel('⚙️ Account'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.refresh_rounded,
                  label: 'Reset Progress',
                  color: Colors.orange,
                  onTap: () => _showResetDialog(context),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _ActionRow(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  color: Colors.red,
                  onTap: _signOut,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('CallisthWout v1.0.0 · 60-Day Programme', style: Theme.of(context).textTheme.labelSmall)),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final int flex;

  const _StatTile({required this.label, required this.value, required this.icon, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _MetricField({required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            if (selected) Icon(Icons.check_circle_rounded, color: AppTheme.successLight, size: 22)
            else Icon(Icons.circle_outlined, color: Theme.of(context).textTheme.bodySmall?.color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color))),
            Icon(Icons.chevron_right_rounded, size: 20, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
