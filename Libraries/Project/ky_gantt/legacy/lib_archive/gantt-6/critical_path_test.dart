import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/utils/critical_path.dart';

final _t0 = DateTime(2024, 1, 1);

Task _task(String id, {int d = 5, List<String> deps = const []}) => Task(
      id: id,
      title: 'Task $id',
      startDate: _t0,
      endDate: _t0.add(Duration(days: d - 1)),
      createdAt: _t0,
      updatedAt: _t0,
      dependencies: deps.map((p) => TaskDependency(predecessorId: p)).toList(),
    );

void main() {
  group('CriticalPathCalculator', () {
    test('empty list returns empty set', () {
      expect(CriticalPathCalculator.calculate([]), isEmpty);
    });

    test('single task with no deps is critical', () {
      expect(CriticalPathCalculator.calculate([_task('A', d: 3)]), contains('A'));
    });

    test('linear chain A->B->C: all three are critical', () {
      final tasks = [
        _task('A', d: 3),
        _task('B', d: 4, deps: ['A']),
        _task('C', d: 2, deps: ['B']),
      ];
      final cp = CriticalPathCalculator.calculate(tasks);
      expect(cp, containsAll(['A', 'B', 'C']));
    });

    test('longer parallel branch is critical; shorter is not', () {
      final tasks = [
        _task('A', d: 1),
        _task('B', d: 5),
        _task('C', d: 1, deps: ['A', 'B']),
      ];
      final cp = CriticalPathCalculator.calculate(tasks);
      expect(cp, contains('B'));
      expect(cp, contains('C'));
      expect(cp, isNot(contains('A')));
    });

    test('equal-length parallel paths: both are critical', () {
      final tasks = [
        _task('A', d: 3),
        _task('B', d: 3),
        _task('C', d: 2, deps: ['A', 'B']),
      ];
      expect(CriticalPathCalculator.calculate(tasks), containsAll(['A', 'B', 'C']));
    });

    test('diamond: longer branch critical, shorter branch not', () {
      final tasks = [
        _task('S',     d: 1),
        _task('LONG',  d: 10, deps: ['S']),
        _task('SHORT', d: 2,  deps: ['S']),
        _task('E',     d: 1,  deps: ['LONG', 'SHORT']),
      ];
      final cp = CriticalPathCalculator.calculate(tasks);
      expect(cp, containsAll(['S', 'LONG', 'E']));
      expect(cp, isNot(contains('SHORT')));
    });

    test('non-critical task has positive float and is excluded', () {
      final tasks = [
        _task('A', d: 1),
        _task('B', d: 5),
        _task('C', d: 1, deps: ['A', 'B']),
      ];
      expect(CriticalPathCalculator.calculate(tasks), isNot(contains('A')));
    });

    test('disconnected chains each have their own critical tasks', () {
      final tasks = [
        _task('X', d: 3),
        _task('Y', d: 2, deps: ['X']),
        _task('P', d: 1),
      ];
      expect(CriticalPathCalculator.calculate(tasks), containsAll(['X', 'Y', 'P']));
    });

    test('dep referencing non-existent task does not throw', () {
      expect(
        () => CriticalPathCalculator.calculate([_task('A', deps: ['ghost'])]),
        returnsNormally,
      );
    });

    test('500-task linear chain completes and returns 500 critical tasks', () {
      final tasks = List.generate(500, (i) =>
          _task('t$i', d: 2, deps: i > 0 ? ['t${i - 1}'] : []));
      expect(CriticalPathCalculator.calculate(tasks).length, equals(500));
    });
  });
}
