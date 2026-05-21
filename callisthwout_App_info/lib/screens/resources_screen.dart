import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/resources_data.dart';
import '../data/workout_data.dart';
import '../theme/app_theme.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Library'),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).textTheme.displayLarge?.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
            tabs: const [
              Tab(text: '🔥 Warm-up'),
              Tab(text: '🧘 Cool-down'),
              Tab(text: '📚 Exercises'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VideoTab(data: ResourcesData.warmupVideos),
            _VideoTab(data: ResourcesData.cooldownVideos),
            const _ExerciseLibraryTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Video Tab ────────────────────────────────────────────────────────────────
class _VideoTab extends StatelessWidget {
  final Map<String, String> data;
  const _VideoTab({required this.data});

  Future<void> _open(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  String _dayType(String title) {
    final t = title.toLowerCase();
    if (t.contains('push')) return 'Push';
    if (t.contains('pull')) return 'Pull';
    if (t.contains('leg')) return 'Legs';
    return 'General';
  }

  Color _typeColor(BuildContext context, String type) {
    switch (type) {
      case 'Push': return AppTheme.getPushColor(context);
      case 'Pull': return AppTheme.getPullColor(context);
      case 'Legs': return AppTheme.getLegsColor(context);
      default: return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final title = data.keys.elementAt(i);
        final videoId = data.values.elementAt(i);
        final thumb = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        final type = _dayType(title);
        final color = _typeColor(context, type);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: InkWell(
            onTap: () => _open(videoId),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        thumb,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 180,
                          color: Theme.of(context).dividerColor,
                          child: const Icon(Icons.play_circle_outline, size: 48),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(type, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Exercise Library Tab ─────────────────────────────────────────────────────
class _ExerciseLibraryTab extends StatefulWidget {
  const _ExerciseLibraryTab();

  @override
  State<_ExerciseLibraryTab> createState() => _ExerciseLibraryTabState();
}

class _ExerciseLibraryTabState extends State<_ExerciseLibraryTab> {
  String _search = '';

  // Build unique exercises from all weeks, grouped by day-type
  static Map<String, List<Exercise>> _buildLibrary() {
    final seen = <String>{};
    final grouped = <String, List<Exercise>>{
      'Push (Chest / Shoulders / Triceps)': [],
      'Pull (Back / Biceps)': [],
      'Legs (Quads / Glutes / Core)': [],
    };

    for (var week in WorkoutData.weeks) {
      void addGroup(String key, List<Exercise> exList) {
        for (final ex in exList) {
          if (!seen.contains(ex.name)) {
            seen.add(ex.name);
            grouped[key]!.add(ex);
          }
        }
      }

      addGroup('Push (Chest / Shoulders / Triceps)', week.push);
      addGroup('Pull (Back / Biceps)', week.pull);
      addGroup('Legs (Quads / Glutes / Core)', week.leg);
    }
    return grouped;
  }

  final _library = _buildLibrary();

  Future<void> _openSearch(String name) async {
    final q = Uri.encodeComponent('$name calisthenics form tutorial');
    final uri = Uri.parse('https://www.youtube.com/results?search_query=$q');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search exercises…',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: _library.entries.map((entry) {
              final groupLabel = entry.key;
              final exercises = entry.value
                  .where((e) => _search.isEmpty || e.name.toLowerCase().contains(_search))
                  .toList();

              if (exercises.isEmpty) return const SizedBox.shrink();

              final color = groupLabel.startsWith('Push')
                  ? AppTheme.getPushColor(context)
                  : groupLabel.startsWith('Pull')
                      ? AppTheme.getPullColor(context)
                      : AppTheme.getLegsColor(context);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(groupLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14))),
                        Text('${exercises.length}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: exercises.asMap().entries.map((e) {
                        final idx = e.key;
                        final ex = e.value;
                        final isLast = idx == exercises.length - 1;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _openSearch(ex.name),
                              borderRadius: idx == 0
                                  ? const BorderRadius.vertical(top: Radius.circular(14))
                                  : isLast
                                      ? const BorderRadius.vertical(bottom: Radius.circular(14))
                                      : BorderRadius.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30, height: 30,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text('${idx + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ex.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                          Text(ex.note, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.open_in_new_rounded, size: 16, color: color.withValues(alpha: 0.7)),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast) Divider(height: 1, color: Theme.of(context).dividerColor),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
