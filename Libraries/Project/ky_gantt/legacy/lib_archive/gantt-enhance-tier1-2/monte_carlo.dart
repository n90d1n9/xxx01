import 'dart:math' as math;
import '../models/task_model.dart';
import 'critical_path.dart';
import 'date_utils.dart';

/// Monte Carlo Schedule Risk Simulation
///
/// Runs N simulations drawing task durations from triangular distributions
/// defined by (optimistic, likely, pessimistic) days.
///
/// Returns: P50, P80, P90 project completion dates + a histogram of outcomes.
class MonteCarloResult {
  final DateTime p50;
  final DateTime p80;
  final DateTime p90;
  final DateTime projectStart;
  final List<int> histogram;   // day counts (relative to projectStart)
  final int simulations;

  const MonteCarloResult({
    required this.p50, required this.p80, required this.p90,
    required this.projectStart, required this.histogram,
    required this.simulations,
  });
}

class MonteCarloEngine {
  MonteCarloEngine._();

  static const int _defaultSimulations = 5000;

  static MonteCarloResult? run(List<Task> tasks, {int simulations = _defaultSimulations}) {
    if (tasks.isEmpty) return null;

    final starts = tasks.map((t) => t.startDate).toList()..sort();
    final projectStart = starts.first;
    final rng = math.Random();

    // Topological sort for deterministic simulation order
    final taskMap = {for (final t in tasks) t.id: t};
    final sorted = _topoSort(tasks, taskMap);
    if (sorted.isEmpty) return null;

    final completionDays = <int>[];

    for (int s = 0; s < simulations; s++) {
      // Map: taskId → simulated end day (relative to projectStart)
      final endDay = <String, int>{};

      for (final task in sorted) {
        final duration = _sampleTriangular(
          task.mcOptimistic, task.likelyDays, task.mcPessimistic, rng
        ).round().clamp(1, 9999);

        // Earliest start = max(predecessor ends) or task's own day offset
        int startDay = GanttDateUtils.daysBetween(projectStart, task.startDate);

        for (final dep in task.dependencies) {
          final predEnd = endDay[dep.predecessorId];
          if (predEnd != null) {
            final candidate = switch (dep.type) {
              DependencyType.fs => predEnd + dep.lagDays + 1,
              DependencyType.ss => predEnd - (endDay[dep.predecessorId]! - startDay) + dep.lagDays,
              DependencyType.ff => predEnd + dep.lagDays,
              DependencyType.sf => predEnd - duration + 1 + dep.lagDays,
            };
            if (candidate > startDay) startDay = candidate;
          }
        }

        endDay[task.id] = startDay + duration - 1;
      }

      final maxEnd = endDay.values.isEmpty ? 0 : endDay.values.reduce(math.max);
      completionDays.add(maxEnd);
    }

    completionDays.sort();

    final p50day = completionDays[(simulations * 0.50).floor()];
    final p80day = completionDays[(simulations * 0.80).floor()];
    final p90day = completionDays[(simulations * 0.90).floor()];

    // Build histogram with 30 buckets
    final minDay = completionDays.first;
    final maxDay = completionDays.last;
    const buckets = 30;
    final range = (maxDay - minDay).clamp(1, 9999);
    final hist = List<int>.filled(buckets, 0);
    for (final d in completionDays) {
      final idx = ((d - minDay) / range * (buckets - 1)).round().clamp(0, buckets - 1);
      hist[idx]++;
    }

    return MonteCarloResult(
      p50: projectStart.add(Duration(days: p50day)),
      p80: projectStart.add(Duration(days: p80day)),
      p90: projectStart.add(Duration(days: p90day)),
      projectStart: projectStart,
      histogram: hist,
      simulations: simulations,
    );
  }

  /// Triangular distribution sample
  static double _sampleTriangular(double a, double c, double b, math.Random rng) {
    if (a >= b) return c;
    final u = rng.nextDouble();
    final fc = (c - a) / (b - a);
    if (u < fc) {
      return a + math.sqrt(u * (b - a) * (c - a));
    } else {
      return b - math.sqrt((1 - u) * (b - a) * (b - c));
    }
  }

  static List<Task> _topoSort(List<Task> tasks, Map<String, Task> taskMap) {
    final visited = <String>{};
    final result = <Task>[];
    void visit(Task t) {
      if (visited.contains(t.id)) return;
      visited.add(t.id);
      for (final dep in t.dependencies) {
        final pred = taskMap[dep.predecessorId];
        if (pred != null) visit(pred);
      }
      result.add(t);
    }
    for (final t in tasks) visit(t);
    return result;
  }
}
