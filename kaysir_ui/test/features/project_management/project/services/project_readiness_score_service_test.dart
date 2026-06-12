import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_readiness_score_service.dart';

void main() {
  test('project readiness score summarizes blockers and confidence', () {
    final summary = buildProjectReadinessScoreSummary(
      today: DateTime(2026, 5, 31),
      project: _project(
        health: ProjectHealth.blocked,
        progress: 0.2,
        budgetUsed: 0.52,
        risks: const [
          ProjectDeliveryRisk(
            title: 'API contract drift',
            detail: 'Payload contract is not signed.',
            severity: ProjectHealth.blocked,
          ),
          ProjectDeliveryRisk(
            title: 'Offline cache scope',
            detail: 'Cache limits need confirmation.',
            severity: ProjectHealth.atRisk,
          ),
        ],
      ),
      timelineTasks: [
        _task(
          id: 'development',
          title: 'Development',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 20),
        ),
      ],
    );

    expect(summary.level, ProjectReadinessLevel.blocked);
    expect(summary.score, lessThan(55));
    expect(summary.criticalCount, greaterThanOrEqualTo(4));
    expect(summary.warningCount, 1);
    expect(
      summary.factors.map((factor) => factor.title),
      containsAll([
        'Delivery blocker',
        'Critical risk exposure',
        'Schedule recovery',
        'Budget pressure',
      ]),
    );
  });

  test('project readiness score reports strong healthy delivery', () {
    final summary = buildProjectReadinessScoreSummary(
      today: DateTime(2026, 5, 31),
      project: _project(),
      timelineTasks: [
        _task(
          id: 'active',
          title: 'Active Work',
          start: DateTime(2026, 5, 28),
          end: DateTime(2026, 6, 12),
          progress: 0.5,
        ),
      ],
    );

    expect(summary.level, ProjectReadinessLevel.strong);
    expect(summary.score, 100);
    expect(summary.positiveCount, 1);
    expect(summary.factors.single.title, 'Delivery cadence');
  });
}

ProjectPortfolioItem _project({
  ProjectHealth health = ProjectHealth.onTrack,
  double progress = 0.55,
  double budgetUsed = 0.48,
  List<ProjectDeliveryRisk> risks = const [],
}) {
  return ProjectPortfolioItem(
    id: 'project',
    name: 'Project',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 7, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    risks: risks,
    team: const [
      ProjectTeamMember(name: 'Owner', role: 'Lead', allocation: 0.7),
    ],
    milestones: [
      ProjectMilestone(
        label: 'Release',
        dueDate: DateTime(2026, 6, 20),
        isComplete: false,
      ),
    ],
  );
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  double progress = 0.4,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
  );
}
