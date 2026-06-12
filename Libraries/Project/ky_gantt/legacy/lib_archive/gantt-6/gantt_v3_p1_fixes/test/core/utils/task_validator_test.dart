import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/utils/task_validator.dart';

final _base = DateTime(2024, 6, 1);

Task _valid({
  String id = 't1',
  String title = 'Valid Task Title',
  DateTime? start,
  DateTime? end,
  double estimatedHours = 8,
  double progress = 0.0,
  double optimisticDays = 0,
  double pessimisticDays = 0,
  TaskConstraint constraint = TaskConstraint.asap,
  DateTime? constraintDate,
  List<TaskDependency> deps = const [],
}) {
  final s = start ?? _base;
  final e = end ?? _base.add(const Duration(days: 4));
  return Task(
    id: id,
    title: title,
    startDate: s,
    endDate: e,
    estimatedHours: estimatedHours,
    progress: progress,
    optimisticDays: optimisticDays,
    pessimisticDays: pessimisticDays,
    constraint: constraint,
    constraintDate: constraintDate,
    dependencies: deps,
    createdAt: _base,
    updatedAt: _base,
  );
}

void main() {
  group('TaskValidator.validate — title', () {
    test('valid title passes', () {
      expect(TaskValidator.validate(_valid(title: 'Sprint Planning')).isValid, isTrue);
    });

    test('empty title fails with error on "title" field', () {
      final r = TaskValidator.validate(_valid(title: ''));
      expect(r.isValid, isFalse);
      expect(r.errorFor('title'), isNotNull);
    });

    test('whitespace-only title fails', () {
      expect(TaskValidator.validate(_valid(title: '   ')).errorFor('title'), isNotNull);
    });

    test('single-character title fails (min 2)', () {
      expect(TaskValidator.validate(_valid(title: 'X')).errorFor('title'), isNotNull);
    });

    test('exactly 2 characters passes', () {
      expect(TaskValidator.validate(_valid(title: 'AB')).errorFor('title'), isNull);
    });

    test('200-character title passes', () {
      expect(TaskValidator.validate(_valid(title: 'A' * 200)).errorFor('title'), isNull);
    });

    test('201-character title fails', () {
      expect(TaskValidator.validate(_valid(title: 'A' * 201)).errorFor('title'), isNotNull);
    });
  });

  group('TaskValidator.validate — dates', () {
    test('start < end passes', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.add(const Duration(days: 7))));
      expect(r.errorFor('endDate'), isNull);
    });

    test('start == end passes (1-day / milestone)', () {
      expect(TaskValidator.validate(_valid(start: _base, end: _base)).errorFor('endDate'), isNull);
    });

    test('end before start fails', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.subtract(const Duration(days: 1))));
      expect(r.errorFor('endDate'), isNotNull);
    });

    test('duration over 5 years fails', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.add(const Duration(days: 1900))));
      expect(r.errorFor('endDate'), isNotNull);
    });
  });

  group('TaskValidator.validate — estimated hours', () {
    test('zero hours is valid', () {
      expect(TaskValidator.validate(_valid(estimatedHours: 0)).errorFor('estimatedHours'), isNull);
    });

    test('negative hours fails', () {
      expect(TaskValidator.validate(_valid(estimatedHours: -1)).errorFor('estimatedHours'), isNotNull);
    });

    test('100 000+ hours fails (unreasonably large)', () {
      expect(TaskValidator.validate(_valid(estimatedHours: 100001)).errorFor('estimatedHours'), isNotNull);
    });
  });

  group('TaskValidator.validate — progress', () {
    for (final p in [0.0, 0.5, 1.0]) {
      test('progress $p is valid', () {
        expect(TaskValidator.validate(_valid(progress: p)).errorFor('progress'), isNull);
      });
    }

    test('progress -0.01 fails', () {
      expect(TaskValidator.validate(_valid(progress: -0.01)).errorFor('progress'), isNotNull);
    });

    test('progress 1.01 fails', () {
      expect(TaskValidator.validate(_valid(progress: 1.01)).errorFor('progress'), isNotNull);
    });
  });

  group('TaskValidator.validate — Monte Carlo 3-point', () {
    // Task is 5 days (start to start+4)
    test('opt < duration < pess is valid', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.add(const Duration(days: 4)), // 5d
          optimisticDays: 3, pessimisticDays: 8));
      expect(r.errorFor('optimisticDays'), isNull);
      expect(r.errorFor('pessimisticDays'), isNull);
    });

    test('optimistic > duration fails', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.add(const Duration(days: 4)), // 5d
          optimisticDays: 7, pessimisticDays: 10));
      expect(r.errorFor('optimisticDays'), isNotNull);
    });

    test('pessimistic < duration fails', () {
      final r = TaskValidator.validate(_valid(
          start: _base, end: _base.add(const Duration(days: 4)), // 5d
          optimisticDays: 3, pessimisticDays: 4));
      expect(r.errorFor('pessimisticDays'), isNotNull);
    });
  });

  group('TaskValidator.validate — constraints', () {
    test('mustStartOn without constraintDate fails', () {
      final r = TaskValidator.validate(_valid(
          constraint: TaskConstraint.mustStartOn, constraintDate: null));
      expect(r.errorFor('constraintDate'), isNotNull);
    });

    test('mustStartOn with constraintDate passes', () {
      final r = TaskValidator.validate(_valid(
          constraint: TaskConstraint.mustStartOn,
          constraintDate: _base.add(const Duration(days: 5))));
      expect(r.errorFor('constraintDate'), isNull);
    });

    test('finishNoLaterThan without date fails', () {
      expect(
        TaskValidator.validate(_valid(constraint: TaskConstraint.finishNoLaterThan))
            .errorFor('constraintDate'),
        isNotNull,
      );
    });

    test('asap without date passes (not required)', () {
      expect(
        TaskValidator.validate(_valid(constraint: TaskConstraint.asap)).errorFor('constraintDate'),
        isNull,
      );
    });
  });

  group('TaskValidator.validate — dependencies', () {
    test('self-dependency fails', () {
      final r = TaskValidator.validate(_valid(
          id: 'me', deps: [TaskDependency(predecessorId: 'me')]));
      expect(r.errorFor('dependencies'), isNotNull);
    });

    test('two-node cycle A->B, B->A is detected', () {
      final taskB = _valid(id: 'B', deps: [TaskDependency(predecessorId: 'A')]);
      final taskA = _valid(id: 'A', deps: [TaskDependency(predecessorId: 'B')]);
      final r = TaskValidator.validate(taskA, existingTasks: [taskB]);
      expect(r.errorFor('dependencies'), isNotNull);
    });

    test('A->B with no reverse dep passes', () {
      final taskB = _valid(id: 'B'); // no dep on A
      final taskA = _valid(id: 'A', deps: [TaskDependency(predecessorId: 'B')]);
      final r = TaskValidator.validate(taskA, existingTasks: [taskB]);
      expect(r.errorFor('dependencies'), isNull);
    });
  });

  group('TaskValidator.validate — multi-error', () {
    test('empty title + reversed dates + negative hours = multiple errors', () {
      final r = TaskValidator.validate(_valid(
        title: '',
        start: _base,
        end: _base.subtract(const Duration(days: 1)),
        estimatedHours: -5,
        progress: 2.0,
      ));
      expect(r.isValid, isFalse);
      expect(r.errors.length, greaterThanOrEqualTo(4));
    });
  });

  group('TaskValidator.validateTitle — quick check', () {
    test('valid title returns null', () {
      expect(TaskValidator.validateTitle('My Task'), isNull);
    });

    test('empty returns message', () {
      expect(TaskValidator.validateTitle(''), isNotNull);
    });

    test('single char returns message', () {
      expect(TaskValidator.validateTitle('X'), isNotNull);
    });

    test('201 chars returns message', () {
      expect(TaskValidator.validateTitle('A' * 201), isNotNull);
    });
  });
}
