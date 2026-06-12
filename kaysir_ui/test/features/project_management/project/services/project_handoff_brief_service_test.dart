import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_handoff_brief_service.dart';

void main() {
  test('project handoff brief prioritizes blocked project context', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final brief = buildProjectHandoffBrief(
      project: project,
      timelineTasks: [
        gantt.GanttTask(
          id: '3',
          title: 'Development',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 20),
          progress: 0.35,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(brief.urgency, ProjectHandoffUrgency.blocked);
    expect(brief.title, 'Handoff blocked delivery');
    expect(brief.topRisk?.title, 'API contract drift');
    expect(brief.nextMilestone?.label, 'API Ready');
    expect(brief.nextMilestone?.dueLabel, 'Due in 11d');
    expect(brief.timelineTaskCount, 1);
    expect(brief.overdueTaskCount, 1);
    expect(brief.ownerLine, contains('Nadia Putri'));
    expect(brief.briefText, contains('Mobile Field App handoff brief'));
    expect(brief.briefText, contains('Status: Blocked'));
    expect(
      brief.briefText,
      contains('Timeline: 1 linked task, 1 overdue task'),
    );
    expect(brief.briefText, contains('Primary handoff'));
    expect(brief.briefText, contains('Next action'));
  });

  test('project handoff brief marks upcoming milestones as watch items', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'retail-modernization',
    );
    final brief = buildProjectHandoffBrief(
      project: project,
      timelineTasks: const [],
      today: DateTime(2026, 6, 14),
    );

    expect(brief.urgency, ProjectHandoffUrgency.watch);
    expect(brief.title, 'Handoff watch items');
    expect(brief.nextMilestone?.label, 'Pilot');
    expect(brief.nextMilestone?.dueLabel, 'Due in 7d');
    expect(brief.briefText, contains('Milestone'));
  });
}
