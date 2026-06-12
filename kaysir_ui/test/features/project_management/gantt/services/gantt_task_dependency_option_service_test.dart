import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_dependency_option_service.dart';

void main() {
  test('gantt dependency options exclude unsafe predecessors', () {
    final child = _task(id: 'child', title: 'Child');
    final target = _task(id: 'target', title: 'Target', subtasks: [child]);
    final independent = _task(id: 'independent', title: 'Independent');
    final successor = _task(
      id: 'successor',
      title: 'Successor',
      dependsOn: 'target',
    );

    final options = buildGanttTaskDependencyOptions(
      task: target,
      dependencyTasks: [target, independent, successor],
    );

    expect(options.candidates.map((candidate) => candidate.id), [
      'independent',
    ]);
    expect(options.blockedSelfCount, 1);
    expect(options.blockedDescendantCount, 1);
    expect(options.blockedCycleCount, 1);
    expect(options.blockedCount, 3);
    expect(options.availabilityLabel, '1 available');
    expect(options.guardLabel, '1 cycle guard');
    expect(options.currentStatus, GanttTaskDependencyCurrentStatus.independent);
  });

  test('gantt dependency options report missing current predecessor', () {
    final task = _task(id: 'task', title: 'Task', dependsOn: 'ghost');
    final predecessor = _task(id: 'predecessor', title: 'Predecessor');

    final options = buildGanttTaskDependencyOptions(
      task: task,
      dependencyTasks: [task, predecessor],
    );

    expect(options.candidates.map((candidate) => candidate.id), [
      'predecessor',
    ]);
    expect(options.currentDependencyId, 'ghost');
    expect(options.currentDependencyTask, isNull);
    expect(options.currentStatus, GanttTaskDependencyCurrentStatus.missing);
    expect(options.hasMissingDependency, true);
    expect(options.shouldIncludeCurrentDependencyOption, true);
    expect(options.currentGuardLabel, 'Missing current');
  });

  test('gantt dependency options report guarded current predecessor', () {
    final task = _task(id: 'task', title: 'Task', dependsOn: 'successor');
    final successor = _task(
      id: 'successor',
      title: 'Successor',
      dependsOn: 'task',
    );
    final predecessor = _task(id: 'predecessor', title: 'Predecessor');

    final options = buildGanttTaskDependencyOptions(
      task: task,
      dependencyTasks: [task, successor, predecessor],
    );

    expect(options.candidates.map((candidate) => candidate.id), [
      'predecessor',
    ]);
    expect(options.currentDependencyTask?.id, 'successor');
    expect(options.currentStatus, GanttTaskDependencyCurrentStatus.guarded);
    expect(options.hasGuardedCurrentDependency, true);
    expect(options.shouldIncludeCurrentDependencyOption, true);
    expect(options.currentGuardLabel, 'Guarded current');
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  String? dependsOn,
  List<gantt.GanttTask> subtasks = const [],
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 5, 5),
    dependsOn: dependsOn,
    subtasks: subtasks,
  );
}
