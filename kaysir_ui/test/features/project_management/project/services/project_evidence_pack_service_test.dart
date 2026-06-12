import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_evidence_pack_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project evidence pack adapts to software blockers', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectEvidencePack(
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

    expect(summary.title, 'Software evidence pack');
    expect(summary.status, ProjectEvidenceStatus.needsReview);
    expect(summary.reviewCount, greaterThanOrEqualTo(3));
    expect(titles, contains('QA and acceptance pack'));
    expect(titles, contains('Recover release plan evidence'));
    expect(titles, contains('Update delivery risk evidence'));
    expect(titles, contains('Prepare sponsor sign-off'));
  });

  test('project evidence pack flags missing wedding timeline evidence', () {
    final summary = buildProjectEvidencePack(
      project: _weddingProject,
      timelineTasks: const [],
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      today: DateTime(2026, 5, 31),
    );
    final titles = summary.items.map((item) => item.title);

    expect(summary.title, 'Wedding evidence pack');
    expect(summary.status, ProjectEvidenceStatus.missing);
    expect(summary.missingCount, 1);
    expect(titles, contains('Vendor and day-of pack'));
    expect(titles, contains('Link wedding timeline evidence'));
    expect(titles, contains('Prepare client acceptance route'));
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
      dueDate: DateTime(2026, 6, 5),
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
    ProjectTeamMember(name: 'Alya Rahman', role: 'Planner', allocation: 0.8),
  ],
);
