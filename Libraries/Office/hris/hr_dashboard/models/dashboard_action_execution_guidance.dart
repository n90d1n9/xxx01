import 'dashboard_action_playbook_step.dart';
import 'dashboard_action_status.dart';

class DashboardActionExecutionGuidance {
  final String label;
  final String title;
  final String description;
  final int? activeStepIndex;
  final bool marksAllStepsComplete;

  const DashboardActionExecutionGuidance({
    required this.label,
    required this.title,
    required this.description,
    required this.activeStepIndex,
    required this.marksAllStepsComplete,
  });

  int? get activeStepNumber {
    final index = activeStepIndex;
    return index == null ? null : index + 1;
  }

  factory DashboardActionExecutionGuidance.fromStatus({
    required DashboardActionStatus status,
    required List<DashboardActionPlaybookStep> steps,
  }) {
    final firstStep = steps.isEmpty ? null : steps.first;
    final activeIndex = steps.length > 1 ? 1 : 0;
    final activeStep = steps.isEmpty ? null : steps[activeIndex];
    final lastStep = steps.isEmpty ? null : steps.last;

    return switch (status) {
      DashboardActionStatus.open => DashboardActionExecutionGuidance(
        label: 'Start here',
        title: firstStep?.title ?? 'Ready to start',
        description:
            'Begin with ownership and first-step alignment before moving this action into progress.',
        activeStepIndex: firstStep == null ? null : 0,
        marksAllStepsComplete: false,
      ),
      DashboardActionStatus.inProgress => DashboardActionExecutionGuidance(
        label: 'Active focus',
        title: activeStep?.title ?? 'Keep the action moving',
        description:
            'Keep attention on the current playbook step, remove blockers, and avoid widening scope.',
        activeStepIndex: activeStep == null ? null : activeIndex,
        marksAllStepsComplete: false,
      ),
      DashboardActionStatus.done => DashboardActionExecutionGuidance(
        label: 'Closure check',
        title: lastStep?.title ?? 'Action completed',
        description:
            'Keep the closing evidence visible so the next dashboard refresh can confirm the signal moved.',
        activeStepIndex: null,
        marksAllStepsComplete: true,
      ),
    };
  }
}
