import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_change_control_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project change control locks software release recovery', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectChangeControl(
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

    expect(summary.title, 'Software change control');
    expect(summary.level, ProjectChangeControlLevel.recovery);
    expect(summary.changeWindow, 'release change freeze');
    expect(titles, contains('Lock release scope recovery'));
    expect(titles, contains('Rebaseline release plan change'));
    expect(titles, contains('Keep dependency changes traceable'));
    expect(titles, contains('Escalate delivery risk change impact'));
    expect(titles, contains('Prepare sponsor approval route'));
    expect(summary.briefText, contains('Software change control brief'));
    expect(summary.briefText, contains('Window: release change freeze'));
    expect(summary.briefText, contains('Audience: sponsor decision update'));
    expect(summary.briefText, contains('Primary control'));
    expect(summary.briefText, contains('Change rule'));
  });

  test('project change control freezes dependency-blocked release changes', () {
    final summary = buildProjectChangeControl(
      project: _softwareProject,
      timelineTasks: [
        gantt.GanttTask(
          id: 'qa',
          title: 'QA Sign-off',
          startDate: DateTime(2026, 5, 20),
          endDate: DateTime(2026, 6, 10),
          progress: 0.4,
          dependsOn: 'api',
          color: Colors.blue,
        ),
      ],
      dependencyTasks: [
        gantt.GanttTask(
          id: 'api',
          title: 'API Contract',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 12),
          progress: 0.7,
          color: Colors.orange,
        ),
      ],
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.team,
      today: DateTime(2026, 5, 31),
    );
    final dependencyItem = summary.items.firstWhere(
      (item) => item.kind == ProjectChangeControlKind.dependency,
    );

    expect(summary.level, ProjectChangeControlLevel.recovery);
    expect(summary.changeWindow, 'release change freeze');
    expect(dependencyItem.title, 'Gate release plan dependencies');
    expect(dependencyItem.level, ProjectChangeControlLevel.recovery);
    expect(
      dependencyItem.detail,
      contains('1 blocked dependency signal should stop unmanaged scope'),
    );
    expect(
      summary.briefText,
      contains('Gate release plan dependencies: 1 blocked dependency signal'),
    );
  });

  test('project change control adapts to wedding planning monitor', () {
    final summary = buildProjectChangeControl(
      project: _weddingProject,
      timelineTasks: const [],
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Wedding change control');
    expect(summary.level, ProjectChangeControlLevel.monitor);
    expect(summary.changeWindow, 'planning watch window');
    expect(titles, contains('Monitor wedding planning changes'));
    expect(titles, contains('Declare wedding timeline baseline'));
    expect(titles, contains('Track vendor risk change impact'));
    expect(titles, contains('Prepare client-visible change note'));
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

final _softwareProject = ProjectPortfolioItem(
  id: 'software-release',
  name: 'Software Release',
  owner: 'Nadia Prasetya',
  client: 'Retail Ops',
  sponsor: 'Ari Wibowo',
  startDate: DateTime(2026, 5, 1),
  endDate: DateTime(2026, 6, 30),
  progress: 0.52,
  budgetUsed: 0.54,
  health: ProjectHealth.onTrack,
  milestones: [
    ProjectMilestone(
      label: 'Launch readiness',
      dueDate: DateTime(2026, 6, 25),
      isComplete: false,
    ),
  ],
  risks: const [],
  team: const [
    ProjectTeamMember(
      name: 'Nadia Prasetya',
      role: 'Delivery Lead',
      allocation: 0.7,
    ),
  ],
);
