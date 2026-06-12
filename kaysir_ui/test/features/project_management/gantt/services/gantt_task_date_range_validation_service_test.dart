import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_date_range_validation_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  const service = GanttTaskDateRangeValidationService();

  group('GanttTaskDateRangeValidationService', () {
    test('allows date ranges that preserve dependency order', () {
      final validation = service.validate(
        _buildTask,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
        tasks: _tasks,
      );

      expect(validation.isValid, isTrue);
      expect(validation.canCommit, isTrue);
      expect(validation.message, isNull);
    });

    test('warns when the predecessor is missing', () {
      final validation = service.validate(
        _missingPredecessorTask,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 7),
        tasks: [_missingPredecessorTask],
      );

      expect(
        validation.severity,
        KyGanttTaskDateRangeValidationSeverity.warning,
      );
      expect(validation.canCommit, isTrue);
      expect(validation.message, 'Predecessor is missing');
    });

    test('blocks ranges that start before the predecessor finishes', () {
      final validation = service.validate(
        _buildTask,
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 9),
        tasks: _tasks,
      );

      expect(validation.isBlocking, isTrue);
      expect(validation.message, 'Starts before Planning finishes');
    });

    test('blocks ranges that overlap a successor', () {
      final validation = service.validate(
        _buildTask,
        startDate: DateTime(2026, 1, 6),
        endDate: DateTime(2026, 1, 12),
        tasks: _tasks,
      );

      expect(validation.isBlocking, isTrue);
      expect(validation.message, 'Would overlap Testing');
    });
  });
}

final _planTask = gantt.GanttTask(
  id: 'plan',
  title: 'Planning',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 5),
);

final _buildTask = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 1, 6),
  endDate: DateTime(2026, 1, 10),
  dependsOn: ' plan ',
);

final _testTask = gantt.GanttTask(
  id: 'test',
  title: 'Testing',
  startDate: DateTime(2026, 1, 11),
  endDate: DateTime(2026, 1, 14),
  dependsOn: ' build ',
);

final _tasks = [
  gantt.GanttTask(
    id: 'project',
    title: 'Project',
    startDate: DateTime(2026, 1),
    endDate: DateTime(2026, 1, 20),
    subtasks: [_planTask, _buildTask, _testTask],
  ),
];

final _missingPredecessorTask = gantt.GanttTask(
  id: 'blocked',
  title: 'Blocked',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 7),
  dependsOn: 'ghost',
);
