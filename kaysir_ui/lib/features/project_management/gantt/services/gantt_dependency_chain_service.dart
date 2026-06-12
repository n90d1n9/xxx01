import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';

enum GanttDependencyChainState {
  independent,
  ready,
  waiting,
  blocked,
  missing,
  cycle,
}

class GanttDependencyChainNode {
  const GanttDependencyChainNode({
    required this.taskId,
    required this.title,
    required this.detail,
    required this.state,
    required this.depth,
    this.task,
  });

  final String taskId;
  final String title;
  final String detail;
  final GanttDependencyChainState state;
  final int depth;
  final gantt.GanttTask? task;

  String get positionLabel => depth <= 1 ? 'Nearest' : 'Upstream $depth';

  String get positionTooltip =>
      depth <= 1
          ? 'Immediate predecessor for ${task?.title ?? title}.'
          : 'Predecessor $depth steps upstream in this chain.';

  bool get needsAttention =>
      state == GanttDependencyChainState.waiting ||
      state == GanttDependencyChainState.blocked ||
      state == GanttDependencyChainState.missing ||
      state == GanttDependencyChainState.cycle;
}

class GanttDependencyChain {
  const GanttDependencyChain({
    required this.rootTask,
    required this.nodes,
    required this.state,
  });

  final gantt.GanttTask rootTask;
  final List<GanttDependencyChainNode> nodes;
  final GanttDependencyChainState state;

  bool get hasDependencies => nodes.isNotEmpty;
  int get totalCount => nodes.length;
  int get readyCount =>
      nodes
          .where((node) => node.state == GanttDependencyChainState.ready)
          .length;
  int get attentionCount => nodes.where((node) => node.needsAttention).length;

  String get predecessorCountLabel =>
      totalCount == 1 ? '1 predecessor' : '$totalCount predecessors';

  String get attentionCountLabel {
    if (attentionCount == 0) return 'Chain clear';
    return attentionCount == 1
        ? '1 needs attention'
        : '$attentionCount need attention';
  }

  String get readyCountLabel =>
      readyCount == 1 ? '1 ready' : '$readyCount ready';

  String get summary {
    if (nodes.isEmpty) return 'No upstream dependency chain.';

    final attentionNode = nodes.firstWhere(
      (node) =>
          node.state == GanttDependencyChainState.blocked ||
          node.state == GanttDependencyChainState.missing ||
          node.state == GanttDependencyChainState.cycle,
      orElse: () => nodes.first,
    );

    switch (state) {
      case GanttDependencyChainState.independent:
        return 'No upstream dependency chain.';
      case GanttDependencyChainState.ready:
        return '${nodes.length} predecessor${nodes.length == 1 ? '' : 's'} ready.';
      case GanttDependencyChainState.waiting:
        return 'Waiting on ${attentionNode.title}.';
      case GanttDependencyChainState.blocked:
        return 'Blocked by ${attentionNode.title}.';
      case GanttDependencyChainState.missing:
        return '${attentionNode.title} is missing from the roadmap.';
      case GanttDependencyChainState.cycle:
        return 'Dependency cycle detected at ${attentionNode.title}.';
    }
  }
}

extension GanttDependencyChainStatePresentation on GanttDependencyChainState {
  String get label {
    switch (this) {
      case GanttDependencyChainState.independent:
        return 'Independent';
      case GanttDependencyChainState.ready:
        return 'Ready';
      case GanttDependencyChainState.waiting:
        return 'Waiting';
      case GanttDependencyChainState.blocked:
        return 'Blocked';
      case GanttDependencyChainState.missing:
        return 'Missing';
      case GanttDependencyChainState.cycle:
        return 'Cycle';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttDependencyChainState.independent:
        return Icons.link_off_rounded;
      case GanttDependencyChainState.ready:
        return Icons.check_circle_outline;
      case GanttDependencyChainState.waiting:
        return Icons.pending_actions_outlined;
      case GanttDependencyChainState.blocked:
        return Icons.block_outlined;
      case GanttDependencyChainState.missing:
        return Icons.report_problem_outlined;
      case GanttDependencyChainState.cycle:
        return Icons.sync_problem_rounded;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttDependencyChainState.independent:
        return colorScheme.onSurfaceVariant;
      case GanttDependencyChainState.ready:
        return Colors.green.shade700;
      case GanttDependencyChainState.waiting:
        return Colors.orange.shade700;
      case GanttDependencyChainState.blocked:
      case GanttDependencyChainState.missing:
      case GanttDependencyChainState.cycle:
        return colorScheme.error;
    }
  }
}

GanttDependencyChain buildGanttDependencyChain({
  required gantt.GanttTask task,
  required List<gantt.GanttTask> dependencyTasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(dependencyTasks);
  final tasksById = {for (final task in flatTasks) task.id: task};
  final nodes = <GanttDependencyChainNode>[];
  final visitedTaskIds = <String>{task.id};

  var currentTask = task;
  var depth = 0;

  while ((currentTask.dependsOn?.trim().isNotEmpty ?? false)) {
    depth++;
    final dependencyId = currentTask.dependsOn!.trim();

    if (visitedTaskIds.contains(dependencyId)) {
      nodes.add(
        GanttDependencyChainNode(
          taskId: dependencyId,
          title: 'Task $dependencyId',
          detail: 'This task creates a circular dependency path.',
          state: GanttDependencyChainState.cycle,
          depth: depth,
        ),
      );
      break;
    }

    final dependencyTask = tasksById[dependencyId];
    if (dependencyTask == null) {
      nodes.add(
        GanttDependencyChainNode(
          taskId: dependencyId,
          title: 'Task $dependencyId',
          detail: 'This dependency is not available in the roadmap.',
          state: GanttDependencyChainState.missing,
          depth: depth,
        ),
      );
      break;
    }

    final insight = ganttDependencyInsightFor(
      currentTask,
      dependencyTasks,
      today: today,
      fallbackDependencyTitle: dependencyTask.title,
    );
    nodes.add(
      GanttDependencyChainNode(
        taskId: dependencyTask.id,
        title: dependencyTask.title,
        detail: insight.detail,
        state: _chainStateFor(insight.health),
        depth: depth,
        task: dependencyTask,
      ),
    );

    visitedTaskIds.add(dependencyId);
    currentTask = dependencyTask;
  }

  return GanttDependencyChain(
    rootTask: task,
    nodes: List.unmodifiable(nodes),
    state: _chainStateForNodes(nodes),
  );
}

GanttDependencyChainState _chainStateFor(GanttDependencyHealth health) {
  switch (health) {
    case GanttDependencyHealth.independent:
      return GanttDependencyChainState.independent;
    case GanttDependencyHealth.ready:
      return GanttDependencyChainState.ready;
    case GanttDependencyHealth.waiting:
      return GanttDependencyChainState.waiting;
    case GanttDependencyHealth.blocked:
      return GanttDependencyChainState.blocked;
    case GanttDependencyHealth.missing:
      return GanttDependencyChainState.missing;
  }
}

GanttDependencyChainState _chainStateForNodes(
  List<GanttDependencyChainNode> nodes,
) {
  if (nodes.isEmpty) return GanttDependencyChainState.independent;
  if (nodes.any((node) => node.state == GanttDependencyChainState.cycle)) {
    return GanttDependencyChainState.cycle;
  }
  if (nodes.any((node) => node.state == GanttDependencyChainState.missing)) {
    return GanttDependencyChainState.missing;
  }
  if (nodes.any((node) => node.state == GanttDependencyChainState.blocked)) {
    return GanttDependencyChainState.blocked;
  }
  if (nodes.any((node) => node.state == GanttDependencyChainState.waiting)) {
    return GanttDependencyChainState.waiting;
  }
  return GanttDependencyChainState.ready;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}
