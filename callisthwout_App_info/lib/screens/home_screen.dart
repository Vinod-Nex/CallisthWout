import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_card.dart';
import '../theme/app_theme.dart';
import 'active_workout_screen.dart';
import '../providers/timer_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            final day = provider.currentDay;
            final type = provider.getDayType(day);
            final week = provider.getWeek(day);
            final exercises = provider.getExercisesForDay(day);
            final isCompleted = provider.isTodayCompleted;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning,', style: Theme.of(context).textTheme.bodySmall),
                          Text('Alex', style: Theme.of(context).textTheme.displayLarge),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuC3Farv7Vs0xYK47INB0wUK6RqJYXLELCNGEApEmtSmNxG6b7fuixod3h8cZhKVaFXDenpTOlRjG365dy9QtfqCAOTlhKakjT8qRl3me7mbeiIB-LjGPF6Rv4SOCzngWgu4i7vkkAdrA5dBDhF9_zPBfZ0Jeh3RcGd5kcUis-4fGjWHwOEnS4onHImZV_4fM8Fk3G8ANzMpMAmhlEZqVC1_JAcNc13f8z1SGiOzn2zY_-70WYtUuODAphAIbyxnvsUTa_P-FwLJMlk"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Motivation & Progress Ring Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: day / 60.0,
                                strokeWidth: 8,
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                color: AppTheme.getPushColor(context),
                                strokeCap: StrokeCap.round,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Day $day',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.getPushColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'OF 60',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Consistency is Key', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                "You're making solid progress on your 60-day challenge. Keep the momentum going strong today!",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 7-Day Calendar Strip (mocked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('This Week', style: Theme.of(context).textTheme.titleLarge),
                      Row(
                        children: [
                          Text('VIEW ALL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.getPushColor(context))),
                          Icon(Icons.arrow_forward, size: 16, color: AppTheme.getPushColor(context)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        final mockDay = day - 3 + index;
                        final isToday = mockDay == day;
                        final isPast = mockDay < day;
                        final dayName = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][index % 7];

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Text(
                                dayName,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isToday ? AppTheme.getPushColor(context) : null,
                                  fontWeight: isToday ? FontWeight.bold : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: isToday ? AppTheme.getPushColor(context) : Theme.of(context).dividerColor,
                                    width: isToday ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: isPast
                                      ? Icon(Icons.check_circle, color: AppTheme.successDark, size: 20)
                                      : Text(
                                          '$mockDay',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isToday ? AppTheme.getPushColor(context) : null,
                                            fontWeight: isToday ? FontWeight.bold : null,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Today's Workout Card
                  Text("Today's Protocol", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  WorkoutCard(
                    day: day,
                    type: type,
                    week: week,
                    exercises: exercises,
                    isCompleted: isCompleted,
                    onStart: () {
                      final isDeload = week.theme.contains('Deload');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => TimerProvider(exercises, isDeload),
                            child: ActiveWorkoutScreen(day: day),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recovery Tip Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.getPullColor(context).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.getPullColor(context).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bedtime, color: AppTheme.getPullColor(context)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recovery Tip', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(
                                "Sleep 7-9h for optimal muscle growth. Deep sleep triggers HGH release essential for repairing tissue damaged during today's workout.",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
