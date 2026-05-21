import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../data/workout_data.dart';
import '../data/resources_data.dart';
import 'completion_screen.dart';

// ─── Phase Enum ────────────────────────────────────────────────────────────────
enum _Phase { warmup, work, rest, transition, cooldown, done }

class ActiveWorkoutScreen extends StatefulWidget {
  final int day;
  const ActiveWorkoutScreen({super.key, required this.day});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with WidgetsBindingObserver {
  // ── Data ────────────────────────────────────────────────────────────────────
  late final List<Exercise> _exercises;
  late final int _totalSets;
  late final Color _accentColor;
  late final String _warmupVideoId;
  late final String _cooldownVideoId;

  // ── State ────────────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.warmup;
  int _exIdx = 0;
  int _currentSet = 1;

  // Timer state
  int _secondsLeft = 5 * 60; // warmup default
  bool _isPaused = false;
  Timer? _timer;

  // Transition banner
  String _transitionLabel = '';
  Timer? _transitionTimer;

  // Audio
  final AudioPlayer _beep = AudioPlayer();

  // ── Init ────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final provider = context.read<WorkoutProvider>();
    final type = provider.getDayType(widget.day);
    _exercises = provider.getExercisesForDay(widget.day);

    final week = provider.getWeek(widget.day);
    final isDeload = week.theme.contains('Deload') || week.num == 4 || week.num == 8;
    _totalSets = isDeload ? 2 : 4;

    _accentColor = () {
      switch (type) {
        case DayType.push: return AppTheme.getPushColor(context);
        case DayType.pull: return AppTheme.getPullColor(context);
        case DayType.leg:  return AppTheme.getLegsColor(context);
      }
    }();

    switch (type) {
      case DayType.push:
        _warmupVideoId  = ResourcesData.warmupVideos['Push day warm-up']!;
        _cooldownVideoId = ResourcesData.cooldownVideos['Push day cool-down']!;
        break;
      case DayType.pull:
        _warmupVideoId  = ResourcesData.warmupVideos['Pull day warm-up']!;
        _cooldownVideoId = ResourcesData.cooldownVideos['Pull day cool-down']!;
        break;
      case DayType.leg:
        _warmupVideoId  = ResourcesData.warmupVideos['Leg day warm-up 1']!;
        _cooldownVideoId = ResourcesData.cooldownVideos['Leg day cool-down']!;
        break;
    }

    _secondsLeft = 5 * 60;
    _startTimer();
  }

  // ── WidgetsBindingObserver ──────────────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
      _saveState();
    } else if (state == AppLifecycleState.resumed) {
      _showResumeDialog();
    }
  }

  // ── Persistence ────────────────────────────────────────────────────────────
  Future<void> _saveState() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('ws_phase', _phase.index);
    await p.setInt('ws_ex', _exIdx);
    await p.setInt('ws_set', _currentSet);
    await p.setInt('ws_secs', _secondsLeft);
  }

  // ── Timer Logic ────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isPaused = true);
  }

  void _resumeTimer() {
    setState(() => _isPaused = false);
  }

  void _onTimerComplete() {
    _playBeep();
    switch (_phase) {
      case _Phase.warmup:
        _enterWork();
        break;
      case _Phase.work:
        _enterRest();
        break;
      case _Phase.rest:
        _nextSetOrExercise();
        break;
      case _Phase.cooldown:
        _enterDone();
        break;
      default:
        break;
    }
  }

  void _enterWork() {
    setState(() {
      _phase = _Phase.work;
      _secondsLeft = 90; // 1:30
    });
  }

  void _enterRest() {
    _playBeep();
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = _Phase.rest;
      _secondsLeft = 30;
    });
  }

  void _nextSetOrExercise() {
    _playBeep();
    HapticFeedback.heavyImpact();
    if (_currentSet < _totalSets) {
      // Next set of same exercise
      setState(() {
        _currentSet++;
        _phase = _Phase.work;
        _secondsLeft = 90;
      });
    } else if (_exIdx < _exercises.length - 1) {
      // Show transition banner
      final nextName = _exercises[_exIdx + 1].name;
      setState(() {
        _transitionLabel = 'Next: $nextName';
        _phase = _Phase.transition;
        _secondsLeft = 5;
      });
      _transitionTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _exIdx++;
          _currentSet = 1;
          _phase = _Phase.work;
          _secondsLeft = 90;
        });
      });
    } else {
      // Cooldown
      _enterCooldown();
    }
  }

  void _enterCooldown() {
    setState(() {
      _phase = _Phase.cooldown;
      _secondsLeft = 5 * 60;
    });
  }

  void _enterDone() {
    _timer?.cancel();
    setState(() => _phase = _Phase.done);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<WorkoutProvider>().completeToday();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompletionScreen(
            day: widget.day,
            totalSets: _exercises.length * _totalSets,
            isDeload: _totalSets == 2,
          ),
        ),
      );
    });
  }

  Future<void> _playBeep() async {
    try {
      await _beep.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {
      // If asset not found, skip silently
    }
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Resume Workout?'),
        content: const Text('Your workout was paused. Ready to continue?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Exit workout
            },
            child: const Text('Quit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeTimer();
            },
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _transitionTimer?.cancel();
    _beep.dispose();
    super.dispose();
  }

  // ── Formatters ────────────────────────────────────────────────────────────
  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.warmup:     return '🔥 Warm-up';
      case _Phase.work:       return '💪 Work';
      case _Phase.rest:       return '😮‍💨 Rest';
      case _Phase.transition: return '⏭ Next Exercise';
      case _Phase.cooldown:   return '🧘 Cool-down';
      case _Phase.done:       return '✅ Done!';
    }
  }

  double get _timerFraction {
    int total;
    switch (_phase) {
      case _Phase.warmup:
      case _Phase.cooldown:
        total = 5 * 60;
        break;
      case _Phase.work:
        total = 90;
        break;
      case _Phase.rest:
        total = 30;
        break;
      default:
        return 1.0;
    }
    return _secondsLeft / total;
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.done) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_phaseLabel, style: const TextStyle(fontSize: 16)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            tooltip: _isPaused ? 'Resume' : 'Pause',
            onPressed: () {
              if (_isPaused) {
                _resumeTimer();
              } else {
                _pauseTimer();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text('Workout Paused'),
                    content: const Text('Take a breather. Resume when ready.'),
                    actions: [
                      TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Quit')),
                      ElevatedButton(onPressed: () { Navigator.pop(context); _resumeTimer(); }, child: const Text('Resume')),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_phase == _Phase.warmup || _phase == _Phase.cooldown) {
      return _buildVideoPhase();
    }
    if (_phase == _Phase.transition) {
      return _buildTransitionBanner();
    }
    return _buildWorkoutPhase();
  }

  // ── Warmup / Cooldown ───────────────────────────────────────────────────────
  Widget _buildVideoPhase() {
    final isWarmup = _phase == _Phase.warmup;
    final videoId = isWarmup ? _warmupVideoId : _cooldownVideoId;
    final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            isWarmup ? 'Prepare your body for today\'s session' : 'Great work! Time to recover.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // YouTube card / thumbnail
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(youtubeUrl);
              await _launchUrlCompat(uri);
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage('https://img.youtube.com/vi/$videoId/hqdefault.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 64),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Circular Timer
          _CircularTimer(
            fraction: _timerFraction,
            label: _fmt(_secondsLeft),
            color: _accentColor,
            isPaused: _isPaused,
          ),

          const Spacer(),

          // Skip button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _accentColor,
                side: BorderSide(color: _accentColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (isWarmup) {
                  _enterWork();
                } else {
                  _enterDone();
                }
              },
              child: Text(isWarmup ? 'Skip Warm-up →' : 'Skip Cool-down →'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrlCompat(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  // ── Transition Banner ───────────────────────────────────────────────────────
  Widget _buildTransitionBanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accentColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Text('⏭', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(_transitionLabel, style: Theme.of(context).textTheme.displayLarge, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Starting in ${_secondsLeft}s', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            onPressed: () {
              _transitionTimer?.cancel();
              setState(() {
                _exIdx++;
                _currentSet = 1;
                _phase = _Phase.work;
                _secondsLeft = 90;
              });
            },
            child: const Text('Start Now →'),
          ),
        ],
      ),
    );
  }

  // ── Work / Rest Phase ───────────────────────────────────────────────────────
  Widget _buildWorkoutPhase() {
    final isRest = _phase == _Phase.rest;
    final ex = _exercises[_exIdx];
    final phaseColor = isRest ? Colors.blueGrey : _accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Progress bar — overall
          _WorkoutProgressBar(
            exerciseIdx: _exIdx,
            totalExercises: _exercises.length,
            setIdx: _currentSet,
            totalSets: _totalSets,
            accentColor: _accentColor,
          ),
          const SizedBox(height: 20),

          // Phase label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRest ? '😮‍💨 REST' : '💪 WORK',
              style: TextStyle(color: phaseColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 16),

          // Exercise name
          Text(ex.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(ex.note, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),

          // Set indicator + reps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SetDot(count: _totalSets, current: _currentSet, color: _accentColor),
              const SizedBox(width: 16),
              Text('Set $_currentSet of $_totalSets', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _accentColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(ex.reps, style: Theme.of(context).textTheme.bodyMedium),

          const Spacer(),

          // Big Timer Ring
          _CircularTimer(
            fraction: _timerFraction,
            label: _fmt(_secondsLeft),
            color: phaseColor,
            isPaused: _isPaused,
            size: 220,
          ),

          const Spacer(),

          // Action buttons
          if (!isRest)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _enterRest,
                child: const Text('✅ Mark Set Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: phaseColor,
                  side: BorderSide(color: phaseColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _nextSetOrExercise,
                child: const Text('⏭ Skip Rest', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Custom Circular Timer Widget ─────────────────────────────────────────────
class _CircularTimer extends StatelessWidget {
  final double fraction;
  final String label;
  final Color color;
  final bool isPaused;
  final double size;

  const _CircularTimer({
    required this.fraction,
    required this.label,
    required this.color,
    required this.isPaused,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: fraction,
            strokeWidth: 12,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
                if (isPaused)
                  Icon(Icons.pause_circle_outline, color: color, size: size * 0.12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Bar Widget ───────────────────────────────────────────────────────
class _WorkoutProgressBar extends StatelessWidget {
  final int exerciseIdx;
  final int totalExercises;
  final int setIdx;
  final int totalSets;
  final Color accentColor;

  const _WorkoutProgressBar({
    required this.exerciseIdx,
    required this.totalExercises,
    required this.setIdx,
    required this.totalSets,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final totalUnits = totalExercises * totalSets;
    final doneUnits = exerciseIdx * totalSets + (setIdx - 1);
    final progress = doneUnits / totalUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Exercise ${exerciseIdx + 1} of $totalExercises', style: Theme.of(context).textTheme.labelSmall),
            Text('${(progress * 100).toInt()}% Complete', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accentColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ],
    );
  }
}

// ─── Set Dot Indicator ─────────────────────────────────────────────────────────
class _SetDot extends StatelessWidget {
  final int count;
  final int current;
  final Color color;

  const _SetDot({required this.count, required this.current, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final done = i < current - 1;
        final active = i == current - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: active ? 12 : 8,
          height: active ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? color : color.withValues(alpha: 0.2),
            border: active ? Border.all(color: color, width: 2) : null,
          ),
        );
      }),
    );
  }
}


