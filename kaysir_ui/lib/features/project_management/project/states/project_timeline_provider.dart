import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/states/gantt_filter_provider.dart';
import 'project_portfolio_provider.dart';

final projectTimelineTasksProvider =
    Provider.family<List<gantt.GanttTask>, String>((ref, projectId) {
      final project = ref.watch(projectByIdProvider(projectId));
      final taskIds = project?.timelineTaskIds.toSet() ?? const <String>{};
      final tasks = flattenGanttTaskTree(ref.watch(gantt.tasksProvider));

      return tasks.where((task) {
        return task.projectId == projectId || taskIds.contains(task.id);
      }).toList();
    });
