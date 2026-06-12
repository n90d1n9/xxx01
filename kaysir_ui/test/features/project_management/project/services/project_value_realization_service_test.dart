import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';
import 'package:kaysir/features/project_management/project/services/project_value_realization_service.dart';

void main() {
  test('project value realization recovers blocked software release value', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectValueRealization(
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

    expect(summary.title, 'Software value realization');
    expect(summary.level, ProjectValueRealizationLevel.recover);
    expect(summary.valueThesis, contains('release adoption'));
    expect(titles, contains('Recover release adoption value'));
    expect(titles, contains('Recover delayed release plan value path'));
    expect(titles, contains('Keep burn plan value healthy'));
    expect(titles, contains('Validate API Ready value proof'));
    expect(titles, contains('Confirm sponsor value decision'));
    expect(summary.briefText, contains('Software value realization brief'));
    expect(summary.briefText, contains('Status: Recover'));
    expect(summary.briefText, contains('Primary value signal'));
    expect(summary.briefText, contains('Value rule'));
  });

  test('project value realization freezes blocked dependency value path', () {
    final summary = buildProjectValueRealization(
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
    final deliveryItem = summary.items.firstWhere(
      (item) => item.kind == ProjectValueRealizationKind.deliveryPath,
    );

    expect(summary.level, ProjectValueRealizationLevel.recover);
    expect(deliveryItem.title, 'Recover blocked release plan value path');
    expect(deliveryItem.level, ProjectValueRealizationLevel.recover);
    expect(deliveryItem.detail, contains('1 dependency blocker'));
    expect(
      summary.briefText,
      contains('Recover blocked release plan value path: 1 dependency blocker'),
    );
  });

  test('project value realization adapts to wedding experience protection', () {
    final summary = buildProjectValueRealization(
      project: _weddingProject,
      timelineTasks: const [],
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Wedding value realization');
    expect(summary.level, ProjectValueRealizationLevel.protect);
    expect(summary.valueThesis, contains('client confidence'));
    expect(titles, contains('Protect wedding experience'));
    expect(titles, contains('Map value workstream'));
    expect(titles, contains('Validate Final walkthrough value proof'));
    expect(titles, contains('Confirm client value story'));
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
