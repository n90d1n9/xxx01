import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_decision_action_plan_service.dart';
import 'project_decision_brief_pack_service.dart';
import 'project_decision_cadence_service.dart';
import 'project_decision_escalation_ladder_service.dart';
import 'project_decision_evidence_matrix_service.dart';
import 'project_decision_governance_service.dart';
import 'project_decision_impact_matrix_service.dart';
import 'project_decision_readiness_gate_service.dart';
import 'project_decision_register_service.dart';
import 'project_decision_sla_tracker_service.dart';
import 'project_decision_workflow_board_service.dart';
import 'project_next_decision_service.dart';
import 'project_status_update_domain_profile_service.dart';

/// Aggregates the decision panels needed by the project decisions workspace.
class ProjectDecisionsWorkspaceSummary {
  const ProjectDecisionsWorkspaceSummary({
    required this.project,
    required this.timelineTasks,
    required this.nextDecisionSummary,
    required this.governanceSummary,
    required this.decisionRegisterSummary,
    required this.decisionActionPlanSummary,
    required this.decisionBriefPackSummary,
    required this.decisionCadenceSummary,
    required this.decisionEvidenceMatrixSummary,
    required this.decisionImpactMatrixSummary,
    required this.decisionWorkflowBoardSummary,
    required this.decisionEscalationLadderSummary,
    required this.decisionSlaTrackerSummary,
    required this.decisionReadinessGateSummary,
  });

  final ProjectPortfolioItem project;
  final List<gantt.GanttTask> timelineTasks;
  final ProjectNextDecisionSummary nextDecisionSummary;
  final ProjectDecisionGovernanceSummary governanceSummary;
  final ProjectDecisionRegisterSummary decisionRegisterSummary;
  final ProjectDecisionActionPlanSummary decisionActionPlanSummary;
  final ProjectDecisionBriefPackSummary decisionBriefPackSummary;
  final ProjectDecisionCadenceSummary decisionCadenceSummary;
  final ProjectDecisionEvidenceMatrixSummary decisionEvidenceMatrixSummary;
  final ProjectDecisionImpactMatrixSummary decisionImpactMatrixSummary;
  final ProjectDecisionWorkflowBoardSummary decisionWorkflowBoardSummary;
  final ProjectDecisionEscalationLadderSummary decisionEscalationLadderSummary;
  final ProjectDecisionSlaTrackerSummary decisionSlaTrackerSummary;
  final ProjectDecisionReadinessGateSummary decisionReadinessGateSummary;

  bool get hasLinkedTimeline => timelineTasks.isNotEmpty;
}

/// Builds a domain-aware decision workspace summary from project and Gantt data.
ProjectDecisionsWorkspaceSummary buildProjectDecisionsWorkspaceSummary({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> dependencyTasks,
  DateTime? today,
}) {
  final timelineTasks = projectDecisionTimelineTasks(
    project: project,
    dependencyTasks: dependencyTasks,
  );
  final profile = projectStatusUpdateDomainProfileFor(project.businessDomain);
  final nextDecisionSummary = buildProjectNextDecisionSummary(
    project: project,
    timelineTasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: today,
  );
  final governanceSummary = buildProjectDecisionGovernance(
    project: project,
    timelineTasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    vocabulary: profile.vocabulary,
    audience: profile.audience,
    today: today,
  );
  final decisionRegisterSummary = buildProjectDecisionRegisterSummary(
    project: project,
    nextDecisionSummary: nextDecisionSummary,
    governanceSummary: governanceSummary,
    today: today,
  );
  final decisionActionPlanSummary = buildProjectDecisionActionPlan(
    decisionRegisterSummary,
  );
  final decisionBriefPackSummary = buildProjectDecisionBriefPackSummary(
    project: project,
    nextDecisionSummary: nextDecisionSummary,
    governanceSummary: governanceSummary,
    registerSummary: decisionRegisterSummary,
    actionPlanSummary: decisionActionPlanSummary,
  );
  final decisionCadenceSummary = buildProjectDecisionCadenceSummary(
    registerSummary: decisionRegisterSummary,
    actionPlanSummary: decisionActionPlanSummary,
  );
  final decisionEvidenceMatrixSummary = buildProjectDecisionEvidenceMatrix(
    decisionRegisterSummary,
  );
  final decisionImpactMatrixSummary = buildProjectDecisionImpactMatrix(
    decisionRegisterSummary,
  );
  final decisionWorkflowBoardSummary = buildProjectDecisionWorkflowBoard(
    decisionRegisterSummary,
  );
  final decisionEscalationLadderSummary = buildProjectDecisionEscalationLadder(
    decisionRegisterSummary,
  );
  final decisionSlaTrackerSummary = buildProjectDecisionSlaTracker(
    decisionRegisterSummary,
  );
  final decisionReadinessGateSummary = buildProjectDecisionReadinessGate(
    decisionRegisterSummary,
  );

  return ProjectDecisionsWorkspaceSummary(
    project: project,
    timelineTasks: List.unmodifiable(timelineTasks),
    nextDecisionSummary: nextDecisionSummary,
    governanceSummary: governanceSummary,
    decisionRegisterSummary: decisionRegisterSummary,
    decisionActionPlanSummary: decisionActionPlanSummary,
    decisionBriefPackSummary: decisionBriefPackSummary,
    decisionCadenceSummary: decisionCadenceSummary,
    decisionEvidenceMatrixSummary: decisionEvidenceMatrixSummary,
    decisionImpactMatrixSummary: decisionImpactMatrixSummary,
    decisionWorkflowBoardSummary: decisionWorkflowBoardSummary,
    decisionEscalationLadderSummary: decisionEscalationLadderSummary,
    decisionSlaTrackerSummary: decisionSlaTrackerSummary,
    decisionReadinessGateSummary: decisionReadinessGateSummary,
  );
}

/// Returns the Gantt tasks that should inform project decision governance.
List<gantt.GanttTask> projectDecisionTimelineTasks({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> dependencyTasks,
}) {
  final linkedTaskIds = project.timelineTaskIds.toSet();
  final flatTasks = _flattenGanttTaskTree(dependencyTasks);

  return [
    for (final task in flatTasks)
      if (task.projectId == project.id || linkedTaskIds.contains(task.id)) task,
  ];
}

List<gantt.GanttTask> _flattenGanttTaskTree(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenGanttTaskTree(task.subtasks),
    ],
  ];
}
