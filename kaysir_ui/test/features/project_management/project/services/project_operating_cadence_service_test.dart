import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_operating_cadence_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project operating cadence escalates software recovery rhythm', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectOperatingCadence(
      project: project,
      timelineTasks: [
        gantt.GanttTask(
          id: '3',
          title: 'Development',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 20),
          progress: 0.35,
          color: Colors.orange,
        ),
      ],
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Software operating cadence');
    expect(summary.level, ProjectOperatingCadenceLevel.recovery);
    expect(summary.recommendedCadence, 'daily until stable');
    expect(titles, contains('Run release recovery standup'));
    expect(titles, contains('Shape release plan agenda'));
    expect(titles, contains('Open unblock window'));
    expect(titles, contains('Capture delivery review notes'));
    expect(titles, contains('Close sponsor loop'));
  });

  test('project operating cadence adapts to wedding planning rhythm', () {
    final summary = buildProjectOperatingCadence(
      project: _weddingProject,
      timelineTasks: const [],
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Wedding operating cadence');
    expect(summary.level, ProjectOperatingCadenceLevel.rhythm);
    expect(summary.recommendedCadence, 'weekly planning checkpoint');
    expect(titles, contains('Run planning checkpoint'));
    expect(titles, contains('Shape wedding timeline agenda'));
    expect(titles, contains('Keep decision window visible'));
    expect(titles, contains('Capture client planning update notes'));
    expect(titles, contains('Close client loop'));
  });
}

final _weddingProject = ProjectPortfolioItem(
  id: 'wedding-showcase',
  name: 'Wedding Showcase',
  owner: 'Alya Rahman',
  client: 'Nadia and Raka',
  sponsor: 'Family Committee',
  startDate: DateTime(2026, 4, 1),
  endDate: DateTime(2026, 6, 14),
  progress: 0.54,
  budgetUsed: 0.58,
  health: ProjectHealth.atRisk,
  milestones: [
    ProjectMilestone(
      label: 'Vendor lock',
      dueDate: DateTime(2026, 5, 20),
      isComplete: true,
    ),
    ProjectMilestone(
      label: 'Final walkthrough',
      dueDate: DateTime(2026, 6, 14),
      isComplete: false,
    ),
  ],
  risks: const [
    ProjectDeliveryRisk(
      title: 'Vendor response',
      detail: 'Decor confirmation is waiting on the final guest count.',
      severity: ProjectHealth.atRisk,
    ),
  ],
  team: const [
    ProjectTeamMember(name: 'Alya Rahman', role: 'Planner', allocation: 0.6),
  ],
);
