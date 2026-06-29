import 'dashboard_action_detail.dart';
import 'dashboard_action_execution_guidance.dart';

enum DashboardActionHandoffKind { ownerAsk, evidence, review }

class DashboardActionHandoffBrief {
  final String title;
  final List<DashboardActionHandoffLine> lines;

  const DashboardActionHandoffBrief({required this.title, required this.lines});

  factory DashboardActionHandoffBrief.fromDetail(DashboardActionDetail detail) {
    final guidance = DashboardActionExecutionGuidance.fromStatus(
      status: detail.status,
      steps: detail.playbookSteps,
    );

    return DashboardActionHandoffBrief(
      title: detail.action.title,
      lines: [
        DashboardActionHandoffLine(
          kind: DashboardActionHandoffKind.ownerAsk,
          label: 'Owner ask',
          value: detail.action.ownerLabel,
          description: detail.nextStep,
        ),
        DashboardActionHandoffLine(
          kind: DashboardActionHandoffKind.evidence,
          label: 'Evidence to share',
          value: '${detail.action.metricValue} ${detail.action.metricLabel}',
          description: guidance.description,
        ),
        DashboardActionHandoffLine(
          kind: DashboardActionHandoffKind.review,
          label: 'Review window',
          value: detail.impactEstimate.timeframe,
          description: 'Look for ${detail.impactEstimate.targetValue}.',
        ),
      ],
    );
  }

  String get clipboardText {
    return [
      'Handoff: $title',
      for (final line in lines)
        '${line.label}: ${line.value}\n${line.description}',
    ].join('\n\n');
  }
}

class DashboardActionHandoffLine {
  final DashboardActionHandoffKind kind;
  final String label;
  final String value;
  final String description;

  const DashboardActionHandoffLine({
    required this.kind,
    required this.label,
    required this.value,
    required this.description,
  });

  String get clipboardText {
    return '$label: $value\n$description';
  }
}
