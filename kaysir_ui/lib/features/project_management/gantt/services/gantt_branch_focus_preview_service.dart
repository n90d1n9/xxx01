import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';
import 'gantt_schedule_health_service.dart';

enum GanttBranchAttentionLens { all, dependency }

class GanttBranchFocusPreviewItem {
  const GanttBranchFocusPreviewItem({
    required this.taskId,
    required this.title,
    required this.progress,
    required this.health,
    required this.scheduleDetail,
    required this.dependencyHealth,
    required this.dependencyDetail,
  });

  final String taskId;
  final String title;
  final double progress;
  final GanttScheduleHealth health;
  final String scheduleDetail;
  final GanttDependencyHealth dependencyHealth;
  final String dependencyDetail;

  String get progressLabel => '${(progress * 100).round()}%';

  bool get hasDependencyAttention =>
      hasDependencyAlert || isWaitingOnDependency;

  bool get hasDependencyAlert =>
      dependencyHealth == GanttDependencyHealth.blocked ||
      dependencyHealth == GanttDependencyHealth.missing;

  bool get isWaitingOnDependency =>
      dependencyHealth == GanttDependencyHealth.waiting;
}

class GanttBranchFocusPreview {
  const GanttBranchFocusPreview({
    required this.items,
    required this.totalItemCount,
    required this.dependencyAlertCount,
    required this.waitingDependencyCount,
  });

  final List<GanttBranchFocusPreviewItem> items;
  final int totalItemCount;
  final int dependencyAlertCount;
  final int waitingDependencyCount;

  int get hiddenItemCount => totalItemCount - items.length;

  bool get hasHiddenItems => hiddenItemCount > 0;

  bool get hasDependencySummary =>
      dependencyAlertCount > 0 || waitingDependencyCount > 0;

  String get hiddenItemCountLabel =>
      hiddenItemCount == 1
          ? '1 more in branch'
          : '$hiddenItemCount more in branch';

  String get dependencyAlertCountLabel =>
      dependencyAlertCount == 1
          ? '1 dependency risk'
          : '$dependencyAlertCount dependency risks';

  String get waitingDependencyCountLabel =>
      waitingDependencyCount == 1
          ? '1 waiting dep'
          : '$waitingDependencyCount waiting deps';
}

class GanttBranchFocusPreviewService {
  const GanttBranchFocusPreviewService();

  static const defaultMaxItems = 3;

  GanttBranchFocusPreview previewFor(
    gantt.GanttTask task, {
    DateTime? today,
    int maxItems = defaultMaxItems,
    List<gantt.GanttTask>? dependencyTasks,
    GanttBranchAttentionLens lens = GanttBranchAttentionLens.all,
  }) {
    if (maxItems <= 0 || task.subtasks.isEmpty) {
      return const GanttBranchFocusPreview(
        items: [],
        totalItemCount: 0,
        dependencyAlertCount: 0,
        waitingDependencyCount: 0,
      );
    }

    final items = _buildItems(
      task,
      today: today,
      dependencyTasks: dependencyTasks,
    )..sort(_compareItems);
    final lensItems = _applyLens(items, lens);

    return GanttBranchFocusPreview(
      items: lensItems.take(maxItems).toList(),
      totalItemCount: lensItems.length,
      dependencyAlertCount:
          items.where((item) => item.hasDependencyAlert).length,
      waitingDependencyCount:
          items.where((item) => item.isWaitingOnDependency).length,
    );
  }

  List<GanttBranchFocusPreviewItem> itemsFor(
    gantt.GanttTask task, {
    DateTime? today,
    int maxItems = defaultMaxItems,
    List<gantt.GanttTask>? dependencyTasks,
    GanttBranchAttentionLens lens = GanttBranchAttentionLens.all,
  }) {
    return previewFor(
      task,
      today: today,
      maxItems: maxItems,
      dependencyTasks: dependencyTasks,
      lens: lens,
    ).items;
  }

  List<GanttBranchFocusPreviewItem> _applyLens(
    List<GanttBranchFocusPreviewItem> items,
    GanttBranchAttentionLens lens,
  ) {
    switch (lens) {
      case GanttBranchAttentionLens.all:
        return items;
      case GanttBranchAttentionLens.dependency:
        return [
          for (final item in items)
            if (item.hasDependencyAttention) item,
        ];
    }
  }

  List<GanttBranchFocusPreviewItem> _buildItems(
    gantt.GanttTask task, {
    required DateTime? today,
    required List<gantt.GanttTask>? dependencyTasks,
  }) {
    final dependencyPool = dependencyTasks ?? [task];

    return [
      for (final descendant in _flattenDescendants(task))
        _previewItemFor(
          descendant,
          dependencyTasks: dependencyPool,
          today: today,
        ),
    ];
  }

  GanttBranchFocusPreviewItem _previewItemFor(
    gantt.GanttTask task, {
    required List<gantt.GanttTask> dependencyTasks,
    required DateTime? today,
  }) {
    final dependencyInsight = ganttDependencyInsightFor(
      task,
      dependencyTasks,
      today: today,
    );

    return GanttBranchFocusPreviewItem(
      taskId: task.id,
      title: task.title,
      progress: task.progress,
      health: ganttScheduleHealthFor(task, today: today),
      scheduleDetail: ganttScheduleHealthDetail(task, today: today),
      dependencyHealth: dependencyInsight.health,
      dependencyDetail: dependencyInsight.detail,
    );
  }

  int _compareItems(
    GanttBranchFocusPreviewItem left,
    GanttBranchFocusPreviewItem right,
  ) {
    final dependencyDelta = _dependencyPriority(
      left.dependencyHealth,
    ).compareTo(_dependencyPriority(right.dependencyHealth));
    if (dependencyDelta != 0) return dependencyDelta;

    final priorityDelta = _healthPriority(
      left.health,
    ).compareTo(_healthPriority(right.health));
    if (priorityDelta != 0) return priorityDelta;

    final progressDelta = left.progress.compareTo(right.progress);
    if (progressDelta != 0) return progressDelta;

    return left.title.compareTo(right.title);
  }

  int _dependencyPriority(GanttDependencyHealth health) {
    switch (health) {
      case GanttDependencyHealth.blocked:
      case GanttDependencyHealth.missing:
        return 0;
      case GanttDependencyHealth.independent:
      case GanttDependencyHealth.ready:
      case GanttDependencyHealth.waiting:
        return 1;
    }
  }

  int _healthPriority(GanttScheduleHealth health) {
    switch (health) {
      case GanttScheduleHealth.overdue:
        return 0;
      case GanttScheduleHealth.active:
        return 1;
      case GanttScheduleHealth.dueSoon:
        return 2;
      case GanttScheduleHealth.scheduled:
        return 3;
      case GanttScheduleHealth.complete:
        return 4;
    }
  }

  List<gantt.GanttTask> _flattenDescendants(gantt.GanttTask task) {
    return [
      for (final subtask in task.subtasks) ...[
        subtask,
        if (subtask.subtasks.isNotEmpty) ..._flattenDescendants(subtask),
      ],
    ];
  }
}
