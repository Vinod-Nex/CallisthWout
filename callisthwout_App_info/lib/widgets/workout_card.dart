import 'package:flutter/material.dart';
import '../data/workout_data.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  final int day;
  final DayType type;
  final Week week;
  final List<Exercise> exercises;
  final bool isCompleted;
  final VoidCallback onStart;

  const WorkoutCard({
    super.key,
    required this.day,
    required this.type,
    required this.week,
    required this.exercises,
    required this.isCompleted,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    String typeLabel;
    List<String> musclesLabel;
    IconData typeIcon;

    switch (type) {
      case DayType.push:
        accentColor = AppTheme.getPushColor(context);
        typeLabel = 'Push Day';
        musclesLabel = ['Chest', 'Shoulders', 'Triceps'];
        typeIcon = Icons.fitness_center;
        break;
      case DayType.pull:
        accentColor = AppTheme.getPullColor(context);
        typeLabel = 'Pull Day';
        musclesLabel = ['Back', 'Biceps'];
        typeIcon = Icons.sports_gymnastics;
        break;
      case DayType.leg:
        accentColor = AppTheme.getLegsColor(context);
        typeLabel = 'Legs Day';
        musclesLabel = ['Quads', 'Hamstrings', 'Glutes', 'Calves'];
        typeIcon = Icons.directions_run;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        child: Stack(
          children: [
            // Decorative background element
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'WEEK ${week.num} THEME',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: accentColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(typeLabel, style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 4),
                          Text(week.theme, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Icon(typeIcon, color: accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: musclesLabel.map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Text(
                          m,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DURATION', style: Theme.of(context).textTheme.labelSmall),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 16),
                                const SizedBox(width: 4),
                                Text('60 min', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('INTENSITY', style: Theme.of(context).textTheme.labelSmall),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, size: 16, color: accentColor),
                                const SizedBox(width: 4),
                                Text('High', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? AppTheme.successDark : accentColor, // We could use gradient but simple is fine for now, or use Ink
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isCompleted ? null : onStart,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? null
                              : LinearGradient(
                                  colors: [accentColor, accentColor.withValues(alpha: 0.8)], // Simplified gradient
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isCompleted ? 'Completed' : "Start Today's Workout",
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              if (!isCompleted) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.play_arrow, color: Colors.white),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
