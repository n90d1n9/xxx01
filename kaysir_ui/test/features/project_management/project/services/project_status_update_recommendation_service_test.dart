import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_recommendation_service.dart';
import 'package:kaysir/features/project_management/project/services/project_status_update_service.dart';

void main() {
  test('status update recommendation detects software delivery context', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final recommendation = recommendProjectStatusUpdateProfile(
      project: project,
      timelineTasks: [
        gantt.GanttTask(
          id: 'api',
          title: 'API release validation',
          startDate: DateTime(2026, 5, 20),
          endDate: DateTime(2026, 6, 12),
          progress: 0.2,
        ),
      ],
    );

    expect(recommendation.vocabulary, ProjectStatusUpdateVocabulary.software);
    expect(recommendation.audience, ProjectStatusUpdateAudience.sponsor);
    expect(recommendation.confidencePercent, greaterThanOrEqualTo(70));
    expect(recommendation.reasons.join(' '), contains('Software signals'));
    expect(recommendation.reasons.join(' '), contains('Blocked'));
  });

  test('status update recommendation handles client-facing event domains', () {
    final recommendation = recommendProjectStatusUpdateProfile(
      project: _weddingProject(),
      timelineTasks: [
        gantt.GanttTask(
          id: 'vendor',
          title: 'Vendor and catering confirmation',
          startDate: DateTime(2026, 5, 20),
          endDate: DateTime(2026, 5, 29),
          progress: 0.35,
        ),
      ],
      availableVocabularies: const [
        ProjectStatusUpdateVocabulary.general,
        ProjectStatusUpdateVocabulary.wedding,
      ],
    );

    expect(recommendation.vocabulary, ProjectStatusUpdateVocabulary.wedding);
    expect(recommendation.audience, ProjectStatusUpdateAudience.client);
    expect(recommendation.reasons.join(' '), contains('Client-facing'));
  });

  test('status update recommendation detects retail operations attributes', () {
    final recommendation = recommendProjectStatusUpdateProfile(
      project: _retailProject(),
      timelineTasks: const [],
    );

    expect(
      recommendation.vocabulary,
      ProjectStatusUpdateVocabulary.retailOperations,
    );
    expect(recommendation.audience, ProjectStatusUpdateAudience.team);
    expect(recommendation.confidencePercent, greaterThanOrEqualTo(70));
    expect(recommendation.reasons.join(' '), contains('Retail signals'));
    expect(recommendation.reasons.join(' '), contains('store cluster'));
  });

  test('status update recommendation respects available vocabularies', () {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final recommendation = recommendProjectStatusUpdateProfile(
      project: project,
      timelineTasks: const [],
      availableVocabularies: const [
        ProjectStatusUpdateVocabulary.general,
        ProjectStatusUpdateVocabulary.construction,
      ],
      availableAudiences: const [ProjectStatusUpdateAudience.team],
    );

    expect(recommendation.vocabulary, ProjectStatusUpdateVocabulary.general);
    expect(recommendation.audience, ProjectStatusUpdateAudience.team);
  });
}

ProjectPortfolioItem _retailProject() {
  return ProjectPortfolioItem(
    id: 'retail-wave-2',
    name: 'Launch Wave Two',
    owner: 'Maya Santoso',
    client: 'Kaysir Retail',
    sponsor: 'Store Operations',
    businessDomain: 'Retail Operations',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 7, 15),
    progress: 0.28,
    budgetUsed: 0.31,
    health: ProjectHealth.onTrack,
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'store-cluster',
        label: 'Store Cluster',
        type: ProjectCustomAttributeType.text,
        value: 'Jakarta pilot',
      ),
      ProjectCustomAttribute(
        key: 'launch-wave',
        label: 'Launch Wave',
        type: ProjectCustomAttributeType.text,
        value: 'Wave 2 rollout',
      ),
    ],
    milestones: [
      ProjectMilestone(
        label: 'Store Readiness',
        dueDate: DateTime(2026, 6, 18),
        isComplete: false,
      ),
    ],
  );
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
