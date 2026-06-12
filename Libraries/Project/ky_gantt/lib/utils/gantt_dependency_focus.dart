import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import 'gantt_task_tree.dart';

class KyGanttDependencyEdge {
  const KyGanttDependencyEdge(this.predecessorId, this.taskId);

  final String predecessorId;
  final String taskId;

  @override
  bool operator ==(Object other) {
    return other is KyGanttDependencyEdge &&
        other.predecessorId == predecessorId &&
        other.taskId == taskId;
  }

  @override
  int get hashCode => Object.hash(predecessorId, taskId);
}

Set<KyGanttDependencyEdge> focusedGanttDependencyEdges({
  required List<GanttTask> tasks,
  required String? selectedTaskId,
  required bool enabled,
  required KyGanttDependencyLineFocusScope focusScope,
}) {
  final selectedId = selectedTaskId?.trim();
  if (!enabled || selectedId == null || selectedId.isEmpty) {
    return const {};
  }

  final flatTasks = flattenGanttTasks(tasks);
  final taskById = {for (final task in flatTasks) task.id: task};
  final successorsById = _successorsById(taskById);

  switch (focusScope) {
    case KyGanttDependencyLineFocusScope.direct:
      return {
        for (final task in flatTasks) ...[
          if (_directDependencyEdgeFor(task, selectedId) case final edge?) edge,
        ],
      };
    case KyGanttDependencyLineFocusScope.upstream:
      return _selectedUpstreamDependencyEdges(
        selectedId: selectedId,
        taskById: taskById,
      );
    case KyGanttDependencyLineFocusScope.downstream:
      return _selectedDownstreamDependencyEdges(
        selectedId: selectedId,
        successorsById: successorsById,
      );
    case KyGanttDependencyLineFocusScope.chain:
      return _selectedDependencyChainEdges(
        selectedId: selectedId,
        taskById: taskById,
        successorsById: successorsById,
      );
  }
}

Set<String> focusedGanttDependencyTaskIds({
  required List<GanttTask> tasks,
  required String? selectedTaskId,
  required bool enabled,
  required KyGanttDependencyLineFocusScope focusScope,
}) {
  final edges = focusedGanttDependencyEdges(
    tasks: tasks,
    selectedTaskId: selectedTaskId,
    enabled: enabled,
    focusScope: focusScope,
  );
  if (edges.isEmpty) return const {};

  return {
    for (final edge in edges) ...[
      edge.predecessorId,
      edge.taskId,
    ],
  };
}

KyGanttDependencyEdge? _directDependencyEdgeFor(
  GanttTask task,
  String selectedId,
) {
  final predecessorId = task.dependsOn?.trim();
  if (predecessorId == null || predecessorId.isEmpty) return null;
  if (task.id != selectedId && predecessorId != selectedId) return null;

  return KyGanttDependencyEdge(predecessorId, task.id);
}

Map<String, List<String>> _successorsById(Map<String, GanttTask> taskById) {
  final successorsById = <String, List<String>>{};

  for (final task in taskById.values) {
    final predecessorId = task.dependsOn?.trim();
    if (predecessorId == null || predecessorId.isEmpty) continue;
    successorsById.putIfAbsent(predecessorId, () => []).add(task.id);
  }

  return successorsById;
}

Set<KyGanttDependencyEdge> _selectedDependencyChainEdges({
  required String selectedId,
  required Map<String, GanttTask> taskById,
  required Map<String, List<String>> successorsById,
}) {
  return {
    ..._selectedUpstreamDependencyEdges(
      selectedId: selectedId,
      taskById: taskById,
    ),
    ..._selectedDownstreamDependencyEdges(
      selectedId: selectedId,
      successorsById: successorsById,
    ),
  };
}

Set<KyGanttDependencyEdge> _selectedUpstreamDependencyEdges({
  required String selectedId,
  required Map<String, GanttTask> taskById,
}) {
  final edges = <KyGanttDependencyEdge>{};
  final upstreamVisited = <String>{};

  void collectUpstream(String taskId) {
    if (!upstreamVisited.add(taskId)) return;

    final predecessorId = taskById[taskId]?.dependsOn?.trim();
    if (predecessorId == null || predecessorId.isEmpty) return;
    if (!taskById.containsKey(predecessorId)) return;

    edges.add(KyGanttDependencyEdge(predecessorId, taskId));
    collectUpstream(predecessorId);
  }

  collectUpstream(selectedId);
  return edges;
}

Set<KyGanttDependencyEdge> _selectedDownstreamDependencyEdges({
  required String selectedId,
  required Map<String, List<String>> successorsById,
}) {
  final edges = <KyGanttDependencyEdge>{};
  final downstreamVisited = <String>{};

  void collectDownstream(String taskId) {
    if (!downstreamVisited.add(taskId)) return;

    for (final successorId in successorsById[taskId] ?? const <String>[]) {
      edges.add(KyGanttDependencyEdge(taskId, successorId));
      collectDownstream(successorId);
    }
  }

  collectDownstream(selectedId);

  return edges;
}
