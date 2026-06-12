import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_playbook_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('project domain playbook adapts to software blockers', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final summary = buildProjectDomainPlaybook(
      project: project,
      vocabulary: ProjectStatusUpdateVocabulary.software,
      audience: ProjectStatusUpdateAudience.sponsor,
      today: DateTime(2026, 5, 31),
      timelineTasks: [
        gantt.GanttTask(
          id: 'api',
          title: 'API contract',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 20),
          progress: 0.35,
        ),
      ],
    );

    expect(summary.title, 'Software operating playbook');
    expect(summary.level, ProjectDomainPlaybookLevel.critical);
    expect(summary.criticalCount, greaterThanOrEqualTo(2));
    expect(
      summary.items.map((item) => item.title),
      contains('Confirm release controls'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Recover release plan'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Unblock delivery risk'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Prepare sponsor decision path'),
    );
  });

  test('project domain playbook adapts to wedding client operations', () {
    final summary = buildProjectDomainPlaybook(
      project: _weddingProject(),
      vocabulary: ProjectStatusUpdateVocabulary.wedding,
      audience: ProjectStatusUpdateAudience.client,
      timelineTasks: const [],
      today: DateTime(2026, 5, 31),
    );

    expect(summary.title, 'Wedding operating playbook');
    expect(
      summary.items.map((item) => item.title),
      contains('Confirm wedding controls'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Link wedding timeline'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Prepare client-facing note'),
    );
    expect(summary.attentionCount, greaterThanOrEqualTo(1));
  });

  test('project domain playbook adapts to retail rollout controls', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'retail-modernization',
    );
    final summary = buildProjectDomainPlaybook(
      project: project,
      vocabulary: ProjectStatusUpdateVocabulary.retailOperations,
      audience: ProjectStatusUpdateAudience.team,
      timelineTasks: [
        gantt.GanttTask(
          id: 'store-readiness',
          title: 'Store launch readiness',
          startDate: DateTime(2026, 5, 20),
          endDate: DateTime(2026, 6, 12),
          progress: 0.42,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(summary.title, 'Retail operating playbook');
    expect(
      summary.items.map((item) => item.title),
      contains('Confirm retail rollout controls'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Maintain rollout calendar rhythm'),
    );
    expect(
      summary.items.map((item) => item.title),
      contains('Run team execution sync'),
    );
  });
}

ProjectPortfolioItem _weddingProject() {
  return ProjectPortfolioItem(
    id: 'grand-hall-wedding',
    name: 'Grand Hall Wedding',
    owner: 'Ayu Prameswari',
    client: 'Sari & Bagas',
    sponsor: 'Family Committee',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 6, 20),
    progress: 0.52,
    budgetUsed: 0.73,
    health: ProjectHealth.blocked,
    milestones: [
      ProjectMilestone(
        label: 'Vendor Lock',
        dueDate: DateTime(2026, 6, 4),
        isComplete: false,
      ),
    ],
    risks: const [
      ProjectDeliveryRisk(
        title: 'Catering confirmation',
        detail: 'Menu and guest count need a signed final order.',
        severity: ProjectHealth.blocked,
      ),
    ],
  );
}
