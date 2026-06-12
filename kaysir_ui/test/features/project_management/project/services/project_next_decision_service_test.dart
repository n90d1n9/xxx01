import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_next_decision_service.dart';

void main() {
  test(
    'project next decisions prioritize blockers and operating guardrails',
    () {
      final today = DateTime(2026, 5, 31);
      final dependency = _task(
        id: 'dependency',
        title: 'Vendor sign-off',
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 20),
        progress: 0.4,
      );
      final summary = buildProjectNextDecisionSummary(
        project: ProjectPortfolioItem(
          id: 'store-rollout',
          name: 'Store Rollout',
          owner: 'Rafi',
          client: 'Retail Ops',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 7, 1),
          progress: 0.2,
          budgetUsed: 0.52,
          health: ProjectHealth.blocked,
          milestones: [
            ProjectMilestone(
              label: 'Pilot Gate',
              dueDate: DateTime(2026, 6, 4),
              isComplete: false,
            ),
          ],
          risks: const [
            ProjectDeliveryRisk(
              title: 'Store readiness',
              detail: 'Pilot store owner has not signed the cutover window.',
              severity: ProjectHealth.blocked,
            ),
          ],
        ),
        timelineTasks: [
          _task(
            id: 'blocked',
            title: 'Cutover Prep',
            start: DateTime(2026, 6, 3),
            end: DateTime(2026, 6, 8),
            dependsOn: 'dependency',
          ),
          _task(
            id: 'overdue',
            title: 'Store Audit',
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 5, 20),
            progress: 0.4,
          ),
        ],
        dependencyTasks: [dependency],
        today: today,
      );

      expect(summary.level, ProjectNextDecisionLevel.critical);
      expect(summary.readinessScore, lessThan(55));
      expect(summary.timelineIssueCount, 2);
      expect(summary.briefText, startsWith('Store Rollout decision brief'));
      expect(summary.briefText, contains('Status: Decision Needed'));
      expect(summary.briefText, contains('Readiness:'));
      expect(
        summary.briefText,
        contains('[Critical / Timeline] Clear dependency block'),
      );
      expect(
        summary.decisions.map((decision) => decision.title),
        containsAll([
          'Clear dependency block',
          'Assign readiness owner',
          'Escalate delivery risk',
          'Reset budget baseline',
          'Confirm milestone gate',
        ]),
      );
      expect(summary.primaryDecision.task?.id, 'blocked');
    },
  );

  test('project next decisions keep healthy projects lightweight', () {
    final summary = buildProjectNextDecisionSummary(
      project: ProjectPortfolioItem(
        id: 'healthy',
        name: 'Healthy Program',
        owner: 'Maya',
        client: 'Operations',
        startDate: DateTime(2026, 5),
        endDate: DateTime(2026, 8),
        progress: 0.55,
        budgetUsed: 0.48,
        health: ProjectHealth.onTrack,
        milestones: const [],
        team: const [
          ProjectTeamMember(name: 'Maya', role: 'Lead', allocation: 0.6),
        ],
      ),
      timelineTasks: [
        _task(
          id: 'complete',
          title: 'Discovery',
          start: DateTime(2026, 5),
          end: DateTime(2026, 5, 10),
          progress: 1,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(summary.level, ProjectNextDecisionLevel.healthy);
    expect(summary.decisions, hasLength(1));
    expect(summary.primaryDecision.title, 'Keep delivery cadence');
    expect(summary.timelineIssueCount, 0);
    expect(summary.briefText, contains('Status: Steady'));
    expect(summary.briefText, contains('[Healthy / Cadence]'));
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
  );
}
