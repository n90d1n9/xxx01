import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/utils/auto_scheduler.dart';

final _base = DateTime(2024, 3, 1);

// Build a task spanning [start, end] inclusive.
Task _task(
  String id, {
  required DateTime start,
  required DateTime end,
  List<TaskDependency> deps = const [],
  bool autoSchedule = true,
  bool isLocked = false,
  TaskConstraint constraint = TaskConstraint.asap,
  DateTime? constraintDate,
}) =>
    Task(
      id: id,
      title: 'Task $id',
      startDate: start,
      endDate: end,
      dependencies: deps,
      autoSchedule: autoSchedule,
      isLocked: isLocked,
      constraint: constraint,
      constraintDate: constraintDate,
      createdAt: _base,
      updatedAt: _base,
    );

TaskDependency _fs(String id, {int lag = 0}) =>
    TaskDependency(predecessorId: id, type: DependencyType.fs, lagDays: lag);

TaskDependency _ss(String id, {int lag = 0}) =>
    TaskDependency(predecessorId: id, type: DependencyType.ss, lagDays: lag);

TaskDependency _ff(String id, {int lag = 0}) =>
    TaskDependency(predecessorId: id, type: DependencyType.ff, lagDays: lag);

void main() {
  group('AutoScheduler.propagate', () {
    // ── No-op guards ──────────────────────────────────────────────────────────

    test('returns same list when changed task has no successors', () {
      final b0 = _base.add(const Duration(days: 10));
      final tasks = [
        _task('A', start: _base, end: _base.add(const Duration(days: 4))),
        _task('B', start: b0,    end: b0.add(const Duration(days: 4))),
      ];
      final result = AutoScheduler.propagate(tasks, 'A');
      expect(result.firstWhere((t) => t.id == 'B').startDate, equals(b0));
    });

    test('locked successor is never moved', () {
      final aEnd = _base.add(const Duration(days: 9));
      final bStart = _base.add(const Duration(days: 5));
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: bStart, end: bStart.add(const Duration(days: 4)),
            deps: [_fs('A')], isLocked: true),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(bStart));
    });

    test('autoSchedule=false successor is not moved', () {
      final aEnd = _base.add(const Duration(days: 9));
      final bStart = _base.add(const Duration(days: 5));
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: bStart, end: bStart.add(const Duration(days: 4)),
            deps: [_fs('A')], autoSchedule: false),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(bStart));
    });

    // ── Finish-to-Start ───────────────────────────────────────────────────────

    test('FS: successor starts the day after predecessor ends', () {
      final aEnd = _base.add(const Duration(days: 4)); // Mar 5
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: _base, end: _base.add(const Duration(days: 2)),
            deps: [_fs('A')]),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(aEnd.add(const Duration(days: 1))));
      // Duration preserved: was 3 days
      expect(b.durationDays, equals(3));
    });

    test('FS with lag: start = predEnd + lag + 1', () {
      final aEnd = _base.add(const Duration(days: 4));
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: _base, end: _base.add(const Duration(days: 2)),
            deps: [_fs('A', lag: 3)]),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(aEnd.add(const Duration(days: 4))));
    });

    // ── Start-to-Start ────────────────────────────────────────────────────────

    test('SS: successor pulled to predecessor start', () {
      final aStart = _base.add(const Duration(days: 5));
      final tasks = [
        _task('A', start: aStart, end: aStart.add(const Duration(days: 4))),
        _task('B', start: _base,  end: _base.add(const Duration(days: 3)),
            deps: [_ss('A')]),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(aStart));
    });

    // ── Finish-to-Finish ──────────────────────────────────────────────────────

    test('FF: successor ends on same day as predecessor', () {
      final aEnd = _base.add(const Duration(days: 9)); // Mar 10
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: _base, end: _base.add(const Duration(days: 4)),
            deps: [_ff('A')]), // 5-day task, ends too early
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.endDate, equals(aEnd));
      expect(b.durationDays, equals(5)); // duration preserved
    });

    // ── Chain propagation ─────────────────────────────────────────────────────

    test('chain A -> B -> C: moving A propagates to B then C', () {
      final newAEnd = _base.add(const Duration(days: 14)); // A ends Mar 15
      final bOrig   = _base.add(const Duration(days: 6));  // B originally starts Mar 7 (5d)
      final cOrig   = _base.add(const Duration(days: 11)); // C originally starts Mar 12 (5d)
      final tasks = [
        _task('A', start: _base, end: newAEnd),
        _task('B', start: bOrig, end: bOrig.add(const Duration(days: 4)), deps: [_fs('A')]),
        _task('C', start: cOrig, end: cOrig.add(const Duration(days: 4)), deps: [_fs('B')]),
      ];
      final result = AutoScheduler.propagate(tasks, 'A');
      final b = result.firstWhere((t) => t.id == 'B');
      final c = result.firstWhere((t) => t.id == 'C');
      // B: Mar 15 + 1 = Mar 16
      expect(b.startDate, equals(newAEnd.add(const Duration(days: 1))));
      // C: B.end + 1
      expect(c.startDate, equals(b.endDate.add(const Duration(days: 1))));
    });

    // ── Constraints ───────────────────────────────────────────────────────────

    test('mustStartOn overrides computed start', () {
      final mustStart = _base.add(const Duration(days: 20));
      final aEnd = _base.add(const Duration(days: 4));
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: _base, end: _base.add(const Duration(days: 4)),
            deps: [_fs('A')],
            constraint: TaskConstraint.mustStartOn,
            constraintDate: mustStart),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(mustStart));
    });

    test('startNoEarlierThan: uses constraint date when computed is before it', () {
      final earliest = _base.add(const Duration(days: 15));
      final aEnd = _base.add(const Duration(days: 4));
      final tasks = [
        _task('A', start: _base, end: aEnd),
        _task('B', start: _base, end: _base.add(const Duration(days: 4)),
            deps: [_fs('A')],
            constraint: TaskConstraint.startNoEarlierThan,
            constraintDate: earliest),
      ];
      final b = AutoScheduler.propagate(tasks, 'A').firstWhere((t) => t.id == 'B');
      expect(b.startDate, equals(earliest));
    });

    // ── Robustness ────────────────────────────────────────────────────────────

    test('dep on non-existent predecessor does not throw', () {
      final tasks = [
        _task('B', start: _base, end: _base.add(const Duration(days: 4)),
            deps: [_fs('ghost')]),
      ];
      expect(() => AutoScheduler.propagate(tasks, 'B'), returnsNormally);
    });
  });
}
