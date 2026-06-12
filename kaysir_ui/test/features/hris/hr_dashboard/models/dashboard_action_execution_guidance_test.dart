import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_execution_guidance.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_playbook_step.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';

void main() {
  test('execution guidance highlights the right playbook step by status', () {
    final open = DashboardActionExecutionGuidance.fromStatus(
      status: DashboardActionStatus.open,
      steps: _steps,
    );
    final active = DashboardActionExecutionGuidance.fromStatus(
      status: DashboardActionStatus.inProgress,
      steps: _steps,
    );
    final done = DashboardActionExecutionGuidance.fromStatus(
      status: DashboardActionStatus.done,
      steps: _steps,
    );

    expect(open.label, 'Start here');
    expect(open.activeStepIndex, 0);
    expect(open.activeStepNumber, 1);
    expect(open.marksAllStepsComplete, isFalse);

    expect(active.label, 'Active focus');
    expect(active.title, 'Do the work');
    expect(active.activeStepIndex, 1);
    expect(active.activeStepNumber, 2);

    expect(done.label, 'Closure check');
    expect(done.title, 'Confirm outcome');
    expect(done.activeStepIndex, isNull);
    expect(done.marksAllStepsComplete, isTrue);
  });
}

const _steps = [
  DashboardActionPlaybookStep(
    title: 'Start well',
    description: 'Confirm the owner and first checkpoint.',
  ),
  DashboardActionPlaybookStep(
    title: 'Do the work',
    description: 'Remove blockers and keep the action moving.',
  ),
  DashboardActionPlaybookStep(
    title: 'Confirm outcome',
    description: 'Verify the dashboard signal moved.',
  ),
];
