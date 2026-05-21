import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/resources_data.dart';
import '../theme/app_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  static const double _maxWater = 4.0;
  double _waterLitres = 0.0;
  static const String _waterKey = 'water_litres';

  @override
  void initState() {
    super.initState();
    _loadWater();
  }

  Future<void> _loadWater() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _waterLitres = p.getDouble(_waterKey) ?? 0.0);
  }

  Future<void> _addWater(double amount) async {
    final newVal = math.min(_waterLitres + amount, _maxWater);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_waterKey, newVal);
    setState(() => _waterLitres = newVal);
  }

  Future<void> _resetWater() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_waterKey, 0.0);
    setState(() => _waterLitres = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Fuel & Recovery'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset water',
            onPressed: _resetWater,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          // ── Hydration Tracker ────────────────────────────────────────────
          _SectionHeader(title: '💧 Hydration Tracker'),
          _HydrationCard(
            current: _waterLitres,
            max: _maxWater,
            onAdd: _addWater,
          ),

          // ── Daily Macro Targets ──────────────────────────────────────────
          _SectionHeader(title: '🎯 Daily Macro Targets'),
          _MacroGrid(),

          // ── Meal Plan ───────────────────────────────────────────────────
          _SectionHeader(title: '🍽️ Today\'s Meal Plan'),
          ...ResourcesData.mealPlan.entries.map((e) => _MealCard(
                meal: e.key,
                foods: e.value,
              )),

          // ── Recovery Protocols ───────────────────────────────────────────
          _SectionHeader(title: '🔁 Recovery Protocols'),
          _RecoverySection(),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ─── Hydration Card ───────────────────────────────────────────────────────────
class _HydrationCard extends StatelessWidget {
  final double current;
  final double max;
  final Future<void> Function(double) onAdd;

  const _HydrationCard({required this.current, required this.max, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final fraction = (current / max).clamp(0.0, 1.0);
    final colour = AppTheme.getPullColor(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colour.withValues(alpha: 0.08), colour.withValues(alpha: 0.02)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colour.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ring
              SizedBox(
                width: 110, height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 10,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(colour),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${current.toStringAsFixed(1)}L',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colour),
                          ),
                          Text('of ${max.toStringAsFixed(1)}L', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Goal', style: Theme.of(context).textTheme.bodySmall),
                    Text('${max.toStringAsFixed(1)} Litres', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('${((max - current).clamp(0, max)).toStringAsFixed(1)}L remaining', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    // Quick-add buttons
                    Wrap(
                      spacing: 6,
                      children: [0.25, 0.5, 1.0].map((amt) {
                        return GestureDetector(
                          onTap: () => onAdd(amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colour.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colour.withValues(alpha: 0.3)),
                            ),
                            child: Text('+${amt}L', style: TextStyle(color: colour, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress segments (8 x 500ml glasses)
          Row(
            children: List.generate(8, (i) {
              final glassVal = (i + 1) * 0.5;
              final filled = current >= glassVal;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled ? colour : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0L', style: Theme.of(context).textTheme.labelSmall),
              Text('${max}L', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Macro Grid ───────────────────────────────────────────────────────────────
class _MacroGrid extends StatelessWidget {
  static const List<Map<String, dynamic>> _macros = [
    {'label': 'Protein', 'value': '135–145 g', 'icon': '🥩', 'color': Color(0xFFD85A30)},
    {'label': 'Carbs', 'value': '370–410 g', 'icon': '🍚', 'color': Color(0xFF378ADD)},
    {'label': 'Fats', 'value': '75–85 g', 'icon': '🥑', 'color': Color(0xFF1D9E75)},
    {'label': 'Calories', 'value': '~3,000 kcal', 'icon': '🔥', 'color': Color(0xFFFF9500)},
    {'label': 'Water', 'value': '3.5–4 L', 'icon': '💧', 'color': Color(0xFF5AC8FA)},
    {'label': 'Meals/day', 'value': '6–7', 'icon': '🍽️', 'color': Color(0xFF8E8E93)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: _macros.map((m) {
        final color = m['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(m['icon'] as String, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(m['value'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(m['label'] as String, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Meal Card ────────────────────────────────────────────────────────────────
class _MealCard extends StatefulWidget {
  final String meal;
  final String foods;
  const _MealCard({required this.meal, required this.foods});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  bool _expanded = false;

  static String _emoji(String meal) {
    if (meal.contains('Break')) return '🌅';
    if (meal.contains('Mid')) return '🥛';
    if (meal.contains('Lunch')) return '🍛';
    if (meal.contains('Pre')) return '⚡';
    if (meal.contains('Post')) return '💪';
    if (meal.contains('Dinner')) return '🌙';
    if (meal.contains('bed')) return '🌜';
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(_emoji(widget.meal), style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.meal, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 16, 16),
                child: Text(widget.foods, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recovery Section ────────────────────────────────────────────────────────
class _RecoverySection extends StatelessWidget {
  static const List<Map<String, String>> _protocols = [
    {'icon': '😴', 'title': 'Sleep', 'desc': '7–9 hrs — non-negotiable for muscle synthesis'},
    {'icon': '🚶', 'title': 'Active Recovery', 'desc': 'Walk 20 min after meals on rest days'},
    {'icon': '📅', 'title': 'Deload Weeks', 'desc': 'Week 4 & 8 — reduce sets to 2, keep reps same'},
    {'icon': '🦵', 'title': 'Joint Care', 'desc': 'Wrist / shoulder mobility 5 min daily'},
    {'icon': '🧘', 'title': 'Stretching', 'desc': 'Static stretches after every session'},
    {'icon': '💊', 'title': 'Nutrition Timing', 'desc': 'Post-workout meal within 30–60 minutes'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: _protocols.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final isLast = i == _protocols.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(p['icon']!, style: const TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['title']!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(p['desc']!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}
