import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/utils/resource_leveler.dart';

final _base = DateTime(2024, 1, 1);

Assignee _person(String id, {double hours = 8.0}) =>
    Assignee(id: id, name: 'User $id', allocatedHoursPerDay: hours);

Task _task(
  String id, {
  required DateTime start,
  required DateTime end,
  List<Assignee> assignees = const [],
  double estimatedHours = 0,
  TaskPriority priority = TaskPriority.medium,
  bool autoSchedule = true,
  bool isLocked = false,
}) =>
    Task(
      id: id,
      title: 'Task $id',
      startDate: start,
      endDate: end,
      assignees: assignees,
      estimatedHours: estimatedHours,
      priority: priority,
      autoSchedule: autoSchedule,
      isLocked: isLocked,
      createdAt: _base,
      updatedAt: _base,
    );

void main() {
  final alice = _person('alice');
  final bob   = _person('bob');

  group('ResourceLeveler.level', () {
    // ── No-op ─────────────────────────────────────────────────────────────────

    test('empty task list returns zero shifts', () {
      final r = ResourceLeveler.level([], [alice]);
      expect(r.shiftsApplied, 0);
      expect(r.tasks, isEmpty);
    });

    test('no overload: tasks are unchanged', () {
      // Alice 8h/day. Single 4h/day task over 3 days — well within capacity.
      final tasks = [
        _task('A',
          start: _base, end: _base.add(const Duration(days: 2)),
          assignees: [alice], estimatedHours: 12),
      ];
      final r = ResourceLeveler.level(tasks, [alice]);
      expect(r.shiftsApplied, 0);
      expect(r.tasks.first.startDate, equals(_base));
    });

    // ── Overload resolution ───────────────────────────────────────────────────

    test('two overlapping tasks on same assignee: lower priority is delayed', () {
      // Both on Alice (8h/day). Each 8h in 1 day → 16h on day 1 → overloaded.
      final high = _task('HIGH',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8,
          priority: TaskPriority.high);
      final med = _task('MED',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8,
          priority: TaskPriority.medium);

      final r = ResourceLeveler.level([high, med], [alice]);
      expect(r.shiftsApplied, greaterThan(0));
      final medResult = r.tasks.firstWhere((t) => t.id == 'MED');
      expect(medResult.startDate.isAfter(_base), isTrue,
          reason: 'Lower-priority task must be pushed out');
    });

    test('locked task is never moved regardless of overload', () {
      final locked = _task('LOCKED',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8,
          priority: TaskPriority.low, isLocked: true);
      final free = _task('FREE',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8);

      final r = ResourceLeveler.level([locked, free], [alice]);
      final lockedResult = r.tasks.firstWhere((t) => t.id == 'LOCKED');
      expect(lockedResult.startDate, equals(_base));
    });

    test('critical-path task is not shifted', () {
      final crit = _task('CRIT',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8,
          priority: TaskPriority.low); // low priority but critical
      final free = _task('FREE',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8);

      final r = ResourceLeveler.level([crit, free], [alice], criticalIds: {'CRIT'});
      final critResult = r.tasks.firstWhere((t) => t.id == 'CRIT');
      expect(critResult.startDate, equals(_base));
    });

    // ── Multi-resource ────────────────────────────────────────────────────────

    test('separate assignees on same day do not cause overload', () {
      final a = _task('A', start: _base, end: _base, assignees: [alice], estimatedHours: 8);
      final b = _task('B', start: _base, end: _base, assignees: [bob],   estimatedHours: 8);
      final r = ResourceLeveler.level([a, b], [alice, bob]);
      // Combined capacity 16h, combined load 16h — no overload
      expect(r.shiftsApplied, 0);
    });

    // ── Duration preservation ─────────────────────────────────────────────────

    test('shifted task preserves its original duration', () {
      final low = _task('LOW',
          start: _base, end: _base.add(const Duration(days: 2)), // 3-day task
          assignees: [alice], estimatedHours: 24,
          priority: TaskPriority.low);
      final high = _task('HIGH',
          start: _base, end: _base.add(const Duration(days: 2)),
          assignees: [alice], estimatedHours: 24,
          priority: TaskPriority.high);

      final r = ResourceLeveler.level([low, high], [alice]);
      final shifted = r.tasks.firstWhere((t) => t.id == 'LOW');
      expect(shifted.durationDays, equals(3),
          reason: 'Leveling must not change task duration');
    });

    // ── Result metadata ───────────────────────────────────────────────────────

    test('daysExtended is non-negative', () {
      final a = _task('A', start: _base, end: _base,
          assignees: [alice], estimatedHours: 8, priority: TaskPriority.low);
      final b = _task('B', start: _base, end: _base,
          assignees: [alice], estimatedHours: 8, priority: TaskPriority.high);
      final r = ResourceLeveler.level([a, b], [alice]);
      expect(r.daysExtended, greaterThanOrEqualTo(0));
    });

    // ── Max iterations guard ──────────────────────────────────────────────────

    test('terminates cleanly when nothing can be moved', () {
      final tasks = List.generate(5, (i) => _task('t$i',
          start: _base, end: _base,
          assignees: [alice], estimatedHours: 8,
          isLocked: true));
      expect(
        () => ResourceLeveler.level(tasks, [alice], maxIterations: 10),
        returnsNormally,
      );
    });
  });
}
