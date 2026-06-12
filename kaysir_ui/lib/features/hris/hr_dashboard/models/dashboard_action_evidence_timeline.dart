import 'dashboard_action_detail.dart';
import 'dashboard_action_execution_guidance.dart';
import 'dashboard_action_status.dart';

enum DashboardActionEvidenceState { complete, current, next }

class DashboardActionEvidenceTimeline {
  final List<DashboardActionEvidenceEvent> events;

  const DashboardActionEvidenceTimeline({required this.events});

  factory DashboardActionEvidenceTimeline.fromDetail(
    DashboardActionDetail detail,
  ) {
    final guidance = DashboardActionExecutionGuidance.fromStatus(
      status: detail.status,
      steps: detail.playbookSteps,
    );
    final workIsDone = detail.status == DashboardActionStatus.done;

    return DashboardActionEvidenceTimeline(
      events: [
        DashboardActionEvidenceEvent(
          title: 'Signal captured',
          value: '${detail.action.metricValue} ${detail.action.metricLabel}',
          description: detail.signals.first.description,
          state: DashboardActionEvidenceState.complete,
        ),
        DashboardActionEvidenceEvent(
          title: 'Owner accountable',
          value: detail.action.ownerLabel,
          description: 'Accountability is visible before work starts.',
          state: DashboardActionEvidenceState.complete,
        ),
        DashboardActionEvidenceEvent(
          title: 'Current playbook step',
          value: guidance.title,
          description: guidance.description,
          state:
              workIsDone
                  ? DashboardActionEvidenceState.complete
                  : DashboardActionEvidenceState.current,
        ),
        DashboardActionEvidenceEvent(
          title: 'Outcome check',
          value: detail.impactEstimate.targetValue,
          description:
              'Review this by ${detail.impactEstimate.timeframe.toLowerCase()}.',
          state:
              workIsDone
                  ? DashboardActionEvidenceState.complete
                  : DashboardActionEvidenceState.next,
        ),
      ],
    );
  }
}

class DashboardActionEvidenceEvent {
  final String title;
  final String value;
  final String description;
  final DashboardActionEvidenceState state;

  const DashboardActionEvidenceEvent({
    required this.title,
    required this.value,
    required this.description,
    required this.state,
  });
}
