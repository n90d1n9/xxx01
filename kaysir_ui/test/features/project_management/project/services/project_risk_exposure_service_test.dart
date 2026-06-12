import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_exposure_service.dart';

void main() {
  test('project risk exposure prioritizes active portfolio risk', () {
    final summary = buildProjectRiskExposureSummary(
      projects: [
        _project(
          id: 'retail',
          name: 'Retail Modernization',
          health: ProjectHealth.onTrack,
          risks: const [
            ProjectDeliveryRisk(
              title: 'Store readiness',
              detail: 'Training schedule needs coverage.',
              severity: ProjectHealth.atRisk,
            ),
            ProjectDeliveryRisk(
              title: 'Inventory feed',
              detail: 'Daily sync is monitored.',
              severity: ProjectHealth.onTrack,
            ),
          ],
        ),
        _project(
          id: 'mobile',
          name: 'Mobile Field App',
          health: ProjectHealth.blocked,
          risks: const [
            ProjectDeliveryRisk(
              title: 'API contract drift',
              detail: 'Payload contract is not signed.',
              severity: ProjectHealth.blocked,
            ),
          ],
        ),
      ],
    );

    expect(summary.totalCount, 3);
    expect(summary.activeCount, 2);
    expect(summary.criticalCount, 1);
    expect(summary.warningCount, 1);
    expect(summary.monitoredCount, 1);
    expect(summary.projectCount, 2);
    expect(summary.exposureScore, 6);
    expect(summary.signal, ProjectHealth.blocked);
    expect(summary.prioritizedItems.first.title, 'API contract drift');
    expect(
      projectRiskExposureDetail(summary.prioritizedItems.first),
      contains('Mobile Field App needs attention'),
    );
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required ProjectHealth health,
  required List<ProjectDeliveryRisk> risks,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 6, 30),
    progress: 0.5,
    budgetUsed: 0.5,
    health: health,
    milestones: const [],
    risks: risks,
  );
}
