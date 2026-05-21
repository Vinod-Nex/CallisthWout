import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../data/resources_data.dart';
import '../data/workout_data.dart';
import 'active_workout_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  // Emoji-style icon labels
  static String _dayTypeEmoji(DayType type) {
    switch (type) {
      case DayType.push: return '💪';
      case DayType.pull: return '🏋️';
      case DayType.leg:  return '🦵';
    }
  }

  Color _dayColor(BuildContext context, DayType type) {
    switch (type) {
      case DayType.push: return AppTheme.getPushColor(context);
      case DayType.pull: return AppTheme.getPullColor(context);
      case DayType.leg:  return AppTheme.getLegsColor(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('60-Day Journey'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Legend Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LegendChip(emoji: '💪', label: 'Push', color: AppTheme.getPushColor(context)),
                    _LegendChip(emoji: '🏋️', label: 'Pull', color: AppTheme.getPullColor(context)),
                    _LegendChip(emoji: '🦵', label: 'Legs', color: AppTheme.getLegsColor(context)),
                    _LegendChip(emoji: '✅', label: 'Done', color: AppTheme.successLight),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final type = provider.getDayType(day);
                    final isCompleted = provider.userData.isDayCompleted(day);
                    final isToday = day == provider.currentDay;

                    final isFuture = day > provider.currentDay;
                    final accent = _dayColor(context, type);

                    return GestureDetector(
                      onTap: () => _showDayModal(context, provider, day, type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? accent.withValues(alpha: 0.12)
                              : isToday
                                  ? accent.withValues(alpha: 0.08)
                                  : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? accent
                                : isCompleted
                                    ? accent.withValues(alpha: 0.4)
                                    : Theme.of(context).dividerColor,
                            width: isToday ? 2.0 : 1.0,
                          ),
                          boxShadow: isToday
                              ? [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$day',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isFuture
                                          ? Theme.of(context).textTheme.bodySmall?.color
                                          : Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _dayTypeEmoji(type),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isFuture ? Colors.grey.shade400 : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Completed checkmark
                            if (isCompleted)
                              Positioned(
                                right: 3,
                                top: 3,
                                child: Icon(Icons.check_circle_rounded, size: 13, color: AppTheme.successLight),
                              ),
                            // Today label
                            if (isToday)
                              Positioned(
                                left: 3,
                                top: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                                ),
                              ),
                            // Lock overlay for future days
                            if (isFuture)
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Icon(Icons.lock, size: 10, color: Colors.grey.shade400),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDayModal(BuildContext context, WorkoutProvider provider, int day, DayType type) {
    final week = provider.getWeek(day);
    final exercises = provider.getExercisesForDay(day);
    final isCompleted = provider.userData.isDayCompleted(day);
    final isToday = day == provider.currentDay;
    final isPast = day < provider.currentDay;
    final isFuture = day > provider.currentDay;
    final accent = _dayColor(context, type);

    // Get video IDs
    String warmupId;
    String cooldownId;
    switch (type) {
      case DayType.push:
        warmupId = ResourcesData.warmupVideos['Push day warm-up']!;
        cooldownId = ResourcesData.cooldownVideos['Push day cool-down']!;
        break;
      case DayType.pull:
        warmupId = ResourcesData.warmupVideos['Pull day warm-up']!;
        cooldownId = ResourcesData.cooldownVideos['Pull day cool-down']!;
        break;
      case DayType.leg:
        warmupId = ResourcesData.warmupVideos['Leg day warm-up 1']!;
        cooldownId = ResourcesData.cooldownVideos['Leg day cool-down']!;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DayBottomSheet(
          day: day,
          type: type,
          week: week,
          exercises: exercises,
          isCompleted: isCompleted,
          isToday: isToday,
          isPast: isPast,
          isFuture: isFuture,
          accent: accent,
          warmupVideoId: warmupId,
          cooldownVideoId: cooldownId,
          emoji: _dayTypeEmoji(type),
          provider: provider,
        );
      },
    );
  }
}

// ─── Bottom Sheet Widget ───────────────────────────────────────────────────────

class _DayBottomSheet extends StatefulWidget {
  final int day;
  final DayType type;
  final Week week;
  final List<Exercise> exercises;
  final bool isCompleted;
  final bool isToday;
  final bool isPast;
  final bool isFuture;
  final Color accent;
  final String warmupVideoId;
  final String cooldownVideoId;
  final String emoji;
  final WorkoutProvider provider;

  const _DayBottomSheet({
    required this.day,
    required this.type,
    required this.week,
    required this.exercises,
    required this.isCompleted,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
    required this.accent,
    required this.warmupVideoId,
    required this.cooldownVideoId,
    required this.emoji,
    required this.provider,
  });

  @override
  State<_DayBottomSheet> createState() => _DayBottomSheetState();
}

class _DayBottomSheetState extends State<_DayBottomSheet> {
  bool _markedRedo = false;

  Future<void> _launchYouTube(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeload = widget.week.theme.contains('Deload') || widget.week.num == 4 || widget.week.num == 8;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${widget.day} · ${widget.type.name.toUpperCase()} DAY',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Week ${widget.week.num} — ${widget.week.theme}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, color: AppTheme.successLight, size: 14),
                        SizedBox(width: 4),
                        Text('Done', style: TextStyle(color: AppTheme.successLight, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _StatBadge(label: '${isDeload ? 2 : 4} sets', icon: Icons.repeat),
                const SizedBox(width: 8),
                _StatBadge(label: '${widget.exercises.length} exercises', icon: Icons.list_alt),
                const SizedBox(width: 8),
                _StatBadge(label: '~60 min', icon: Icons.timer_outlined),
              ],
            ),
          ),

          // Video buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.play_circle_outline, color: widget.accent, size: 18),
                    label: Text('Watch Warm-up', style: TextStyle(color: widget.accent, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.accent.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _launchYouTube(widget.warmupVideoId),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.play_circle_outline, color: widget.accent, size: 18),
                    label: Text('Watch Cool-down', style: TextStyle(color: widget.accent, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.accent.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _launchYouTube(widget.cooldownVideoId),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor, height: 1),

          // Exercise list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              itemCount: widget.exercises.length,
              separatorBuilder: (_, _) => Divider(color: Theme.of(context).dividerColor, height: 1),
              itemBuilder: (context, i) {
                final ex = widget.exercises[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${i + 1}', style: TextStyle(color: widget.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(ex.note, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(ex.sets, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.accent)),
                          Text(ex.reps, style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // CTA Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: _buildCTA(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    if (widget.isFuture) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.lock, size: 18),
          label: const Text('Locked — Complete Previous Days First'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade600,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: null,
        ),
      );
    }

    if (widget.isToday) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: Text(widget.isCompleted ? '🔁 Redo Today\'s Workout' : '▶ Start Today\'s Workout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ActiveWorkoutScreen(day: widget.day),
            ));
          },
        ),
      );
    }

    // Past day
    if (_markedRedo) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Marked as Redo ✓'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successLight,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: null,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Redo Day'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                setState(() => _markedRedo = true);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                side: BorderSide(color: Theme.of(context).dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _LegendChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _LegendChip({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
