import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_governance_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project decision governance escalates blocked software release', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectDecisionGovernance(
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

    expect(summary.title, 'Software decision governance');
    expect(summary.level, ProjectDecisionGovernanceLevel.escalate);
    expect(summary.decisionRoute, 'release council escalation');
    expect(titles, contains('Escalate release governance'));
    expect(titles, contains('Approve release plan recovery'));
    expect(titles, contains('Delegate burn plan guardrail'));
    expect(titles, contains('Escalate delivery risk decision'));
    expect(titles, contains('Coordinate API Ready decision path'));
    expect(titles, contains('Prepare sponsor decision agenda'));
    expect(summary.briefText, contains('Software decision governance brief'));
    expect(summary.briefText, contains('Route: release council escalation'));
    expect(summary.briefText, contains('Primary governance route'));
    expect(summary.briefText, contains('Decision rule'));
  });

  test('project decision governance escalates blocked dependencies', () {
    final summary = buildProjectDecisionGovernance(
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
    final scheduleItem = summary.items.firstWhere(
      (item) => item.kind == ProjectDecisionGovernanceKind.schedule,
    );

    expect(summary.level, ProjectDecisionGovernanceLevel.escalate);
    expect(summary.decisionRoute, 'release council escalation');
    expect(scheduleItem.title, 'Escalate release plan authority');
    expect(scheduleItem.level, ProjectDecisionGovernanceLevel.escalate);
    expect(scheduleItem.detail, contains('1 blocked dependency decision'));
    expect(
      summary.briefText,
      contains(
        'Escalate release plan authority: 1 blocked dependency decision',
      ),
    );
  });

  test('project decision governance adapts to wedding coordination', () {
    final summary = buildProjectDecisionGovernance(
      project: _weddingProject,
      timelineTasks: const [],
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Wedding decision governance');
    expect(summary.level, ProjectDecisionGovernanceLevel.coordinate);
    expect(summary.decisionRoute, 'planner coordination route');
    expect(titles, contains('Coordinate wedding planning governance'));
    expect(titles, contains('Assign wedding timeline decision map'));
    expect(titles, contains('Coordinate vendor risk decision'));
    expect(titles, contains('Coordinate Final walkthrough decision path'));
    expect(titles, contains('Prepare client decision confirmation'));
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
