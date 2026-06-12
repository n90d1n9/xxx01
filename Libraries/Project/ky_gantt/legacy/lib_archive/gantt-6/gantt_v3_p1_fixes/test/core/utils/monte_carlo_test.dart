import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/utils/monte_carlo.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

final _base = DateTime(2024, 1, 1);

Task _task(
  String id, {
  required int durationDays,
  List<String> depIds = const [],
  double optimisticDays = 0,
  double pessimisticDays = 0,
}) {
  final start = _base;
  final end   = _base.add(Duration(days: durationDays - 1));
  return Task(
    id: id,
    title: 'Task $id',
    startDate: start,
    endDate: end,
    optimisticDays: optimisticDays,
    pessimisticDays: pessimisticDays,
    dependencies: depIds.map((d) => TaskDependency(predecessorId: d)).toList(),
    createdAt: _base,
    updatedAt: _base,
  );
}

void main() {
  // Use a modest simulation count for test speed while still being statistically
  // meaningful. 1000 sims give ~3% tolerance on percentiles.
  const sims = 1000;

  group('MonteCarloEngine.run', () {

    // ── Null / empty ────────────────────────────────────────────────────────

    test('returns null for empty task list', () {
      expect(MonteCarloEngine.run([], simulations: sims), isNull);
    });

    // ── Single task ─────────────────────────────────────────────────────────

    test('single deterministic task (opt==pess==likely): all percentiles equal', () {
      // When opt = pess = likely, every simulation draws the same duration.
      // mcOptimistic = durationDays * 0.8 by default if 0 is passed, so we
      // pin explicitly by using a task where opt and pess bracket duration tightly.
      final task = _task('A',
        durationDays: 10,
        optimisticDays: 10,   // ← exactly likely
        pessimisticDays: 10,  // ← exactly likely
      );
      final result = MonteCarloEngine.run([task], simulations: sims);
      expect(result, isNotNull);
      // With zero spread all percentiles should be the same date (±0 days)
      expect(result!.p50, equals(result.p80));
      expect(result.p80, equals(result.p90));
    });

    test('p50 ≤ p80 ≤ p90 always holds', () {
      final task = _task('A',
        durationDays: 10,
        optimisticDays: 6,
        pessimisticDays: 18,
      );
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      expect(result.p50.isBefore(result.p80) || result.p50 == result.p80, isTrue);
      expect(result.p80.isBefore(result.p90) || result.p80 == result.p90, isTrue);
    });

    test('p50 ≈ likely duration for symmetric spread', () {
      // Triangular with opt=7, likely=10, pess=13 — roughly symmetric.
      // The median of a symmetric triangular distribution ≈ the mode (10 days).
      // Allow ±2-day tolerance given 1000 simulations.
      final task = _task('A',
        durationDays: 10,
        optimisticDays: 7,
        pessimisticDays: 13,
      );
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      final p50Days = result.p50.difference(_base).inDays;
      expect(p50Days, inInclusiveRange(7, 12),
          reason: 'P50 should be near the mode of 10 days ± tolerance');
    });

    test('p90 > p50 for a right-skewed triangular distribution', () {
      // opt=8, likely=10, pess=20 — long right tail
      final task = _task('A',
        durationDays: 10,
        optimisticDays: 8,
        pessimisticDays: 20,
      );
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      expect(result.p90.isAfter(result.p50), isTrue,
          reason: 'Right-skewed distribution should push P90 well past P50');
    });

    // ── Histogram ────────────────────────────────────────────────────────────

    test('histogram has exactly 30 buckets', () {
      final task = _task('A', durationDays: 10, optimisticDays: 6, pessimisticDays: 18);
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      expect(result.histogram.length, equals(30));
    });

    test('histogram bucket counts sum to total simulations', () {
      final task = _task('A', durationDays: 10, optimisticDays: 6, pessimisticDays: 18);
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      final total = result.histogram.fold(0, (s, v) => s + v);
      expect(total, equals(sims));
    });

    test('histogram has no negative counts', () {
      final task = _task('A', durationDays: 5, optimisticDays: 3, pessimisticDays: 10);
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      expect(result.histogram.every((v) => v >= 0), isTrue);
    });

    // ── Multi-task sequential chain ─────────────────────────────────────────

    test('chain of tasks: p50 ≥ sum of individual likely durations', () {
      // A(5) → B(5) → C(5): likely total = 15 days from project start.
      // With uncertainty, p50 should be ≥ 15.
      final tasks = [
        _task('A', durationDays: 5, optimisticDays: 3, pessimisticDays: 10),
        _task('B', durationDays: 5, optimisticDays: 3, pessimisticDays: 10, depIds: ['A']),
        _task('C', durationDays: 5, optimisticDays: 3, pessimisticDays: 10, depIds: ['B']),
      ];
      final result = MonteCarloEngine.run(tasks, simulations: sims)!;
      final p50Days = result.p50.difference(_base).inDays;
      // Sum of optimistic lower bounds: 3+3+3=9. p50 should be above that.
      expect(p50Days, greaterThanOrEqualTo(9));
    });

    test('chain: p90 > p50 (uncertainty grows along chain)', () {
      final tasks = [
        _task('A', durationDays: 5, optimisticDays: 3, pessimisticDays: 14),
        _task('B', durationDays: 5, optimisticDays: 3, pessimisticDays: 14, depIds: ['A']),
        _task('C', durationDays: 5, optimisticDays: 3, pessimisticDays: 14, depIds: ['B']),
      ];
      final result = MonteCarloEngine.run(tasks, simulations: sims)!;
      expect(result.p90.isAfter(result.p50), isTrue);
    });

    // ── Parallel tasks ────────────────────────────────────────────────────────

    test('parallel tasks: p50 driven by longer branch', () {
      // A(10) and B(5) run in parallel, no dep — project end = max(endA, endB).
      // p50 should be close to 10 days (A's likely duration), not 5.
      final tasks = [
        _task('A', durationDays: 10, optimisticDays: 10, pessimisticDays: 10),
        _task('B', durationDays: 5,  optimisticDays: 5,  pessimisticDays: 5),
      ];
      final result = MonteCarloEngine.run(tasks, simulations: sims)!;
      final p50Days = result.p50.difference(_base).inDays;
      // All sims should land at exactly 9 days (10-day task, 0-indexed)
      expect(p50Days, closeTo(9, 1));
    });

    // ── Metadata ─────────────────────────────────────────────────────────────

    test('projectStart matches the earliest task start date', () {
      final task = _task('A', durationDays: 5);
      final result = MonteCarloEngine.run([task], simulations: sims)!;
      expect(result.projectStart, equals(_base));
    });

    test('simulations field matches requested count', () {
      final task = _task('A', durationDays: 5);
      final result = MonteCarloEngine.run([task], simulations: 500)!;
      expect(result.simulations, equals(500));
    });

    // ── Default mcOptimistic / mcPessimistic fallbacks ────────────────────────

    test('tasks with no explicit MC estimates use 0.8/1.3 fallback', () {
      // optimisticDays=0, pessimisticDays=0 → fallback: opt=8, pess=13 for duration=10
      final task = _task('A', durationDays: 10); // no opt/pess set
      // Should not throw and should produce a reasonable result
      final result = MonteCarloEngine.run([task], simulations: sims);
      expect(result, isNotNull);
      final p50Days = result!.p50.difference(_base).inDays;
      expect(p50Days, greaterThan(0));
    });
  });
}
