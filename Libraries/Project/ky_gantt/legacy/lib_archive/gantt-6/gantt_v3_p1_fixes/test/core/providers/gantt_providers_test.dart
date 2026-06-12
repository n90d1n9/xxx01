import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_chart/core/models/task_model.dart';
import 'package:gantt_chart/core/providers/gantt_providers.dart';
import 'package:gantt_chart/core/utils/task_validator.dart';

final _base = DateTime(2024, 6, 1);

ProviderContainer _emptyContainer() {
  return ProviderContainer(overrides: [
    tasksProvider.overrideWith(
      (ref) => TasksNotifier(ref, initialTasks: []),
    ),
  ]);
}

Task _task(
  String id, {
  String title = 'Task Title',
  DateTime? start,
  DateTime? end,
  double estimatedHours = 8.0,
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.todo,
}) {
  final s = start ?? _base;
  final e = end ?? _base.add(const Duration(days: 4));
  return Task(
    id: id,
    title: title,
    startDate: s,
    endDate: e,
    estimatedHours: estimatedHours,
    priority: priority,
    status: status,
    createdAt: _base,
    updatedAt: _base,
  );
}

void main() {
  group('TasksNotifier', () {
    group('addTask', () {
      test('valid task is added to state', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final result = c.read(tasksProvider.notifier).addTask(_task('t1'));
        expect(result.isValid, isTrue);
        expect(c.read(tasksProvider).any((t) => t.id == 't1'), isTrue);
      });

      test('empty title is rejected — state unchanged', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final result =
            c.read(tasksProvider.notifier).addTask(_task('bad', title: ''));
        expect(result.isValid, isFalse);
        expect(result.errorFor('title'), isNotNull);
        expect(c.read(tasksProvider), isEmpty);
      });

      test('end before start is rejected', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final result = c.read(tasksProvider.notifier).addTask(_task(
              'bad',
              start: _base,
              end: _base.subtract(const Duration(days: 2)),
            ));
        expect(result.isValid, isFalse);
        expect(result.errorFor('endDate'), isNotNull);
        expect(c.read(tasksProvider), isEmpty);
      });

      test('adds multiple valid tasks independently', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.addTask(_task('t2'));
        n.addTask(_task('t3'));
        expect(c.read(tasksProvider).length, equals(3));
      });
    });

    group('updateTask', () {
      test('valid update changes task title', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1', title: 'Old Title'));
        final result = n.updateTask(_task('t1', title: 'New Title'));
        expect(result.isValid, isTrue);
        final found = c.read(tasksProvider).firstWhere((t) => t.id == 't1');
        expect(found.title, equals('New Title'));
      });

      test('empty title update is rejected — state unchanged', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1', title: 'Original'));
        final result = n.updateTask(_task('t1', title: ''));
        expect(result.isValid, isFalse);
        final found = c.read(tasksProvider).firstWhere((t) => t.id == 't1');
        expect(found.title, equals('Original'));
      });
    });

    group('deleteTask', () {
      test('deletes task by id', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.addTask(_task('t2'));
        n.deleteTask('t1');
        expect(c.read(tasksProvider).any((t) => t.id == 't1'), isFalse);
        expect(c.read(tasksProvider).any((t) => t.id == 't2'), isTrue);
      });

      test('unknown id does not throw', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        expect(() => c.read(tasksProvider.notifier).deleteTask('ghost'),
            returnsNormally);
      });
    });

    group('undo/redo', () {
      test('undo after addTask removes the task', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        expect(c.read(tasksProvider).length, 1);
        n.undo();
        expect(c.read(tasksProvider), isEmpty);
      });

      test('redo re-adds the task', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.undo();
        n.redo();
        expect(c.read(tasksProvider).any((t) => t.id == 't1'), isTrue);
      });

      test('canUndo false on empty history', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        expect(c.read(tasksProvider.notifier).canUndo, isFalse);
      });

      test('canUndo true after addTask', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        expect(n.canUndo, isTrue);
      });

      test('canRedo true after undo', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.undo();
        expect(n.canRedo, isTrue);
      });

      test('multi-command undo-redo cycle', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.addTask(_task('t2'));
        n.addTask(_task('t3'));
        n.undo();
        expect(c.read(tasksProvider).length, 2);
        n.undo();
        expect(c.read(tasksProvider).length, 1);
        n.redo();
        expect(c.read(tasksProvider).length, 2);
      });
    });

    group('rescheduleTask', () {
      test('moves start and end by same delta', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(
            _task('t1', start: _base, end: _base.add(const Duration(days: 4))));
        final newStart = _base.add(const Duration(days: 7));
        n.rescheduleTask('t1', newStart);
        final t = c.read(tasksProvider).firstWhere((t) => t.id == 't1');
        expect(t.startDate, equals(newStart));
        expect(t.endDate, equals(newStart.add(const Duration(days: 4))));
      });

      test('locked task is not rescheduled', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(
            _task('t1', start: _base, end: _base.add(const Duration(days: 4))));
        n.toggleLock('t1');
        n.rescheduleTask('t1', _base.add(const Duration(days: 20)));
        final t = c.read(tasksProvider).firstWhere((t) => t.id == 't1');
        expect(t.startDate, equals(_base));
      });
    });

    group('updateProgress', () {
      test('clamps above 1.0 to 1.0', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.updateProgress('t1', 1.5);
        expect(c.read(tasksProvider).firstWhere((t) => t.id == 't1').progress,
            equals(1.0));
      });

      test('clamps below 0.0 to 0.0', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('t1'));
        n.updateProgress('t1', -0.5);
        expect(c.read(tasksProvider).firstWhere((t) => t.id == 't1').progress,
            equals(0.0));
      });
    });

    group('loadPersisted', () {
      test('replaces state with provided tasks', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('original'));
        n.loadPersisted([_task('r1'), _task('r2')]);
        final ids = c.read(tasksProvider).map((t) => t.id).toList();
        expect(ids, containsAll(['r1', 'r2']));
        expect(ids, isNot(contains('original')));
      });

      test('ignores empty list — keeps current state', () {
        final c = _emptyContainer();
        addTearDown(c.dispose);
        final n = c.read(tasksProvider.notifier);
        n.addTask(_task('existing'));
        n.loadPersisted([]);
        expect(c.read(tasksProvider).any((t) => t.id == 'existing'), isTrue);
      });
    });
  });

  group('TaskValidationResult', () {
    test('isValid true when no errors', () {
      expect(const TaskValidationResult([]).isValid, isTrue);
    });

    test('isValid false when errors present', () {
      final r = TaskValidationResult([
        const TaskValidationError(field: 'title', message: 'Required'),
      ]);
      expect(r.isValid, isFalse);
    });

    test('errorFor returns correct message', () {
      final r = TaskValidationResult([
        const TaskValidationError(field: 'title', message: 'Too short'),
        const TaskValidationError(field: 'endDate', message: 'Invalid range'),
      ]);
      expect(r.errorFor('title'), equals('Too short'));
      expect(r.errorFor('endDate'), equals('Invalid range'));
      expect(r.errorFor('estimatedHours'), isNull);
    });
  });
}
