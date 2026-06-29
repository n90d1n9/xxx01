import 'dashboard_action_impact_estimate.dart';
import 'dashboard_action_playbook_step.dart';
import 'dashboard_action_summary.dart';

DashboardActionDetailContent dashboardActionDetailContentFor(
  DashboardActionRecommendation action,
) {
  return switch (action.id) {
    'critical-risk' => const DashboardActionDetailContent(
      rationale:
          'Critical risk and total-risk pressure are high enough to require leadership attention before routine HR work.',
      nextStep:
          'Open the linked workspace, confirm accountable leadership, and agree the first stabilization move.',
      impactEstimate: DashboardActionImpactEstimate(
        title: 'Critical risk exposure',
        currentLabel: 'Current signal',
        currentValue: 'Critical pressure',
        targetLabel: 'Target outcome',
        targetValue: 'Lower critical workspace count',
        timeframe: 'Today',
        description:
            'The fastest win is visible reduction in critical exposure before routine HR work continues.',
      ),
      playbookSteps: [
        DashboardActionPlaybookStep(
          title: 'Confirm risk owner',
          description:
              'Match the highest-risk workspace to accountable leadership and document who clears blockers.',
        ),
        DashboardActionPlaybookStep(
          title: 'Sequence stabilization work',
          description:
              'Pick the first workspace move that reduces critical exposure before routine work resumes.',
        ),
        DashboardActionPlaybookStep(
          title: 'Set review checkpoint',
          description:
              'Book the next same-day checkpoint and keep the action in progress until risk pressure moves.',
        ),
      ],
    ),
    'time-sensitive' => const DashboardActionDetailContent(
      rationale:
          'Due-soon HR signals are concentrated enough to threaten service levels if the queue is left unmanaged.',
      nextStep:
          'Review the queue, remove blockers, and assign the oldest due items before the next sync.',
      impactEstimate: DashboardActionImpactEstimate(
        title: 'Service level recovery',
        currentLabel: 'Current signal',
        currentValue: 'Due-soon queue',
        targetLabel: 'Target outcome',
        targetValue: 'Oldest items assigned',
        timeframe: 'This week',
        description:
            'Clearing the oldest work protects response time and keeps People Ops from accumulating preventable backlog.',
      ),
      playbookSteps: [
        DashboardActionPlaybookStep(
          title: 'Age the queue',
          description:
              'Separate overdue, due-this-week, and blocked items before assigning capacity.',
        ),
        DashboardActionPlaybookStep(
          title: 'Remove bottlenecks',
          description:
              'Escalate the blocker with the widest service-level impact and assign a named resolver.',
        ),
        DashboardActionPlaybookStep(
          title: 'Lock follow-up',
          description:
              'Confirm which items must be cleared before the next People Ops sync.',
        ),
      ],
    ),
    'scale-momentum' => const DashboardActionDetailContent(
      rationale:
          'Several KPIs are moving in the right direction, which creates a short window to repeat the best playbooks.',
      nextStep:
          'Compare the strongest departments, identify the reusable habit, and schedule the next adoption check.',
      impactEstimate: DashboardActionImpactEstimate(
        title: 'Momentum replication',
        currentLabel: 'Current signal',
        currentValue: 'Improving KPIs',
        targetLabel: 'Target outcome',
        targetValue: 'Reusable habit adopted',
        timeframe: 'Next sync',
        description:
            'The goal is to turn isolated improvement into a repeatable operating habit across another team.',
      ),
      playbookSteps: [
        DashboardActionPlaybookStep(
          title: 'Name the winning habit',
          description:
              'Identify the behavior behind the strongest KPI movement and make it repeatable.',
        ),
        DashboardActionPlaybookStep(
          title: 'Pair teams',
          description:
              'Connect the strongest department with the next team most likely to benefit.',
        ),
        DashboardActionPlaybookStep(
          title: 'Measure adoption',
          description:
              'Choose the adoption signal to review at the next dashboard refresh.',
        ),
      ],
    ),
    'recover-momentum' => const DashboardActionDetailContent(
      rationale:
          'KPI momentum is weaker than expected, so the dashboard needs a deliberate recovery review.',
      nextStep:
          'Inspect the declining drivers, select one corrective action, and review movement within 48 hours.',
      impactEstimate: DashboardActionImpactEstimate(
        title: 'KPI recovery signal',
        currentLabel: 'Current signal',
        currentValue: 'Weak momentum',
        targetLabel: 'Target outcome',
        targetValue: 'One driver corrected',
        timeframe: '48 hours',
        description:
            'A narrow recovery move should create enough signal to decide whether to close or escalate.',
      ),
      playbookSteps: [
        DashboardActionPlaybookStep(
          title: 'Find the weak driver',
          description:
              'Use the KPI pulse to isolate the department or metric losing the most momentum.',
        ),
        DashboardActionPlaybookStep(
          title: 'Choose one correction',
          description:
              'Select the smallest action that can move the driver before the next refresh.',
        ),
        DashboardActionPlaybookStep(
          title: 'Review movement',
          description:
              'Recheck the signal within 48 hours and either close or escalate the action.',
        ),
      ],
    ),
    _ => const DashboardActionDetailContent(
      rationale:
          'This recommendation combines dashboard risk, timing, owner, and KPI signals into a focused next step.',
      nextStep:
          'Confirm the owner, review the supporting signal, and decide whether to start or defer the action.',
      impactEstimate: DashboardActionImpactEstimate(
        title: 'Action clarity',
        currentLabel: 'Current signal',
        currentValue: 'Unreviewed action',
        targetLabel: 'Target outcome',
        targetValue: 'Owner and next step confirmed',
        timeframe: 'Next review',
        description:
            'The outcome is a clear owner, visible next step, and a dashboard status that reflects reality.',
      ),
      playbookSteps: [
        DashboardActionPlaybookStep(
          title: 'Validate signal',
          description:
              'Confirm the dashboard metric still reflects the current operational reality.',
        ),
        DashboardActionPlaybookStep(
          title: 'Assign owner',
          description:
              'Name the team that can move the action and agree the first checkpoint.',
        ),
        DashboardActionPlaybookStep(
          title: 'Close the loop',
          description:
              'Update the action status when the owner has started or completed the work.',
        ),
      ],
    ),
  };
}

class DashboardActionDetailContent {
  final String rationale;
  final String nextStep;
  final DashboardActionImpactEstimate impactEstimate;
  final List<DashboardActionPlaybookStep> playbookSteps;

  const DashboardActionDetailContent({
    required this.rationale,
    required this.nextStep,
    required this.impactEstimate,
    required this.playbookSteps,
  });
}
