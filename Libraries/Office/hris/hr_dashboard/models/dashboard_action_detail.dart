import 'dashboard_action_detail_content.dart';
import 'dashboard_action_impact_estimate.dart';
import 'dashboard_action_playbook_step.dart';
import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

export 'dashboard_action_impact_estimate.dart';
export 'dashboard_action_playbook_step.dart';

class DashboardActionDetail {
  final DashboardActionRecommendation action;
  final DashboardActionStatus status;
  final String rationale;
  final String nextStep;
  final DashboardActionImpactEstimate impactEstimate;
  final List<DashboardActionDetailSignal> signals;
  final List<DashboardActionPlaybookStep> playbookSteps;

  const DashboardActionDetail({
    required this.action,
    required this.status,
    required this.rationale,
    required this.nextStep,
    required this.impactEstimate,
    required this.signals,
    required this.playbookSteps,
  });

  factory DashboardActionDetail.fromRecommendation({
    required DashboardActionRecommendation action,
    required DashboardActionStatus status,
  }) {
    final content = dashboardActionDetailContentFor(action);

    return DashboardActionDetail(
      action: action,
      status: status,
      rationale: content.rationale,
      nextStep: content.nextStep,
      impactEstimate: content.impactEstimate,
      playbookSteps: content.playbookSteps,
      signals: [
        DashboardActionDetailSignal(
          label: action.metricLabel,
          value: action.metricValue,
          description: 'Current dashboard signal behind this recommendation.',
        ),
        DashboardActionDetailSignal(
          label: 'Owner',
          value: action.ownerLabel,
          description: 'Team accountable for moving the action forward.',
        ),
        DashboardActionDetailSignal(
          label: 'Due',
          value: action.dueLabel,
          description: 'Suggested review window for this action.',
        ),
        DashboardActionDetailSignal(
          label: 'Priority',
          value: action.priority.label,
          description: 'Escalation level based on risk and KPI movement.',
        ),
      ],
    );
  }
}

class DashboardActionDetailSignal {
  final String label;
  final String value;
  final String description;

  const DashboardActionDetailSignal({
    required this.label,
    required this.value,
    required this.description,
  });
}
