import '../gantt_dashboard.dart' as gantt;
import 'gantt_branch_focus_summary_service.dart';
import 'gantt_dependency_chain_service.dart';
import 'gantt_successor_impact_service.dart';

class GanttTaskRelationshipOverview {
  const GanttTaskRelationshipOverview({
    required this.chain,
    required this.successorImpact,
    required this.branchSummary,
  });

  final GanttDependencyChain chain;
  final GanttSuccessorImpactSummary successorImpact;
  final GanttBranchFocusSummary? branchSummary;

  int get attentionCount =>
      chain.attentionCount +
      successorImpact.attentionCount +
      (branchSummary?.riskTaskCount ?? 0);

  String get headline {
    if (attentionCount <= 0) {
      return 'Upstream, downstream, and branch signals are clear.';
    }

    return attentionCount == 1
        ? '1 relationship signal needs review.'
        : '$attentionCount relationship signals need review.';
  }

  String get attentionLabel {
    if (attentionCount <= 0) return 'No signals';
    return attentionCount == 1 ? '1 signal' : '$attentionCount signals';
  }

  String get upstreamLabel {
    if (!chain.hasDependencies) return 'No upstream';
    return 'Upstream: ${chain.totalCount}';
  }

  String get downstreamLabel {
    if (!successorImpact.hasImpact) return 'No downstream';
    return 'Downstream: ${successorImpact.totalCount}';
  }

  String get branchLabel {
    final summary = branchSummary;
    if (summary == null) return 'No branch';
    return 'Branch: ${summary.taskCount}';
  }

  String get branchDetail {
    final summary = branchSummary;
    if (summary == null) return 'No subtasks under this task.';
    return '${summary.title}: ${summary.taskCountLabel}, '
        '${summary.progressLabel}, ${summary.riskTaskCount == 0 ? 'no risks' : summary.riskLabel}.';
  }
}

class GanttTaskRelationshipOverviewService {
  const GanttTaskRelationshipOverviewService();

  GanttTaskRelationshipOverview build({
    required gantt.GanttTask task,
    required List<gantt.GanttTask> dependencyTasks,
    DateTime? today,
  }) {
    return GanttTaskRelationshipOverview(
      chain: buildGanttDependencyChain(
        task: task,
        dependencyTasks: dependencyTasks,
        today: today,
      ),
      successorImpact: buildGanttSuccessorImpactSummary(
        task: task,
        dependencyTasks: dependencyTasks,
        today: today,
      ),
      branchSummary:
          task.subtasks.isEmpty
              ? null
              : const GanttBranchFocusSummaryService().summaryFor(
                task,
                today: today,
              ),
    );
  }
}
