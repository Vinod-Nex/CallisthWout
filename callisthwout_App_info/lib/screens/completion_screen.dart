import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'main_navigator.dart';

class CompletionScreen extends StatefulWidget {
  final int day;
  final int totalSets;
  final bool isDeload;

  const CompletionScreen({
    super.key,
    required this.day,
    required this.totalSets,
    this.isDeload = false,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _entryAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool get _isDay60 => widget.day == 60;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 5));
    _confetti.play();

    _entryAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _entryAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    final tomorrowDay = (widget.day % 60) + 1;
    final tomorrowType = provider.getDayType(tomorrowDay);
    final accentColor = _getAccent(context, provider.getDayType(widget.day));
    final journeyPercent = (widget.day / 60 * 100).round();
    const calories = 450;
    const totalTime = '60:00';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Trophy / Medal
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _isDay60 ? '🏆' : '🎯',
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        _isDay60 ? 'Challenge Complete!' : 'Workout Complete!',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isDay60
                            ? '🎉 You crushed all 60 days! You are a calisthenics champion!'
                            : 'Day ${widget.day} done. You\'re $journeyPercent% through your journey.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Stats grid
                      _StatsGrid(
                        accentColor: accentColor,
                        stats: [
                          _Stat(icon: '⏱', label: 'Total Time', value: totalTime),
                          _Stat(icon: '🔥', label: 'Calories', value: '~$calories kcal'),
                          _Stat(icon: '📅', label: 'Day', value: '${widget.day}/60'),
                          _Stat(icon: '🏋️', label: 'Total Sets', value: '${widget.totalSets}'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Journey progress bar
                      _JourneyProgress(
                        day: widget.day,
                        accentColor: accentColor,
                        percent: journeyPercent,
                      ),
                      const SizedBox(height: 28),

                      // Day 60 special message
                      if (_isDay60) ...[
                        _Day60Banner(accentColor: accentColor),
                        const SizedBox(height: 24),
                      ],

                      // Back to Home
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.home_rounded, size: 20),
                          label: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const MainNavigator()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Preview Tomorrow
                      if (!_isDay60)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.preview_rounded, size: 18),
                            label: Text(
                              'Preview Tomorrow (${_dayTypeName(tomorrowType)} Day) →',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentColor,
                              side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _showTomorrowPreview(context, provider, tomorrowDay, tomorrowType),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.04,
              numberOfParticles: 60,
              maxBlastForce: 80,
              minBlastForce: 40,
              gravity: 0.15,
              colors: [accentColor, Colors.amber, Colors.green, Colors.blue, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccent(BuildContext context, DayType type) {
    switch (type) {
      case DayType.push: return AppTheme.getPushColor(context);
      case DayType.pull: return AppTheme.getPullColor(context);
      case DayType.leg:  return AppTheme.getLegsColor(context);
    }
  }

  String _dayTypeName(DayType type) {
    switch (type) {
      case DayType.push: return 'Push';
      case DayType.pull: return 'Pull';
      case DayType.leg:  return 'Leg';
    }
  }

  void _showTomorrowPreview(BuildContext context, WorkoutProvider provider, int tomorrow, DayType type) {
    final exercises = provider.getExercisesForDay(tomorrow);
    final week = provider.getWeek(tomorrow);
    final accent = _getAccent(context, type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Day $tomorrow Preview', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 4),
            Text('${_dayTypeName(type)} Day · ${week.theme}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: exercises.length,
                separatorBuilder: (_, _) => Divider(color: Theme.of(context).dividerColor, height: 1),
                itemBuilder: (_, i) {
                  final ex = exercises[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text('${i + 1}', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ex.name, style: Theme.of(context).textTheme.bodyLarge)),
                        Text(ex.reps, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Grid ────────────────────────────────────────────────────────────────
class _Stat {
  final String icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});
}

class _StatsGrid extends StatelessWidget {
  final Color accentColor;
  final List<_Stat> stats;

  const _StatsGrid({required this.accentColor, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(s.value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: accentColor)),
            Text(s.label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      )).toList(),
    );
  }
}

// ─── Journey Progress ─────────────────────────────────────────────────────────
class _JourneyProgress extends StatelessWidget {
  final int day;
  final Color accentColor;
  final int percent;

  const _JourneyProgress({required this.day, required this.accentColor, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Journey Progress', style: Theme.of(context).textTheme.titleLarge),
              Text('$percent%', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: day / 60,
              minHeight: 10,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day $day', style: Theme.of(context).textTheme.labelSmall),
              Text('Day 60', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Day 60 Banner ─────────────────────────────────────────────────────────────
class _Day60Banner extends StatelessWidget {
  final Color accentColor;

  const _Day60Banner({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor.withValues(alpha: 0.15), accentColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'You Completed the 60-Day Challenge!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your counter will reset to Day 1 for your next cycle. Keep the momentum going!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
