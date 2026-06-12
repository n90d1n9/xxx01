import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_domain_readiness_service.dart';

void main() {
  test('portfolio domain readiness aggregates readiness across projects', () {
    final summary = buildProjectPortfolioDomainReadiness(
      projects: demoProjectPortfolio,
    );

    expect(summary.projectCount, 4);
    expect(summary.readyCount, 0);
    expect(summary.inProgressCount, 1);
    expect(summary.needsContextCount, 3);
    expect(summary.completedReadinessFieldCount, 9);
    expect(summary.readinessFieldCount, 16);
    expect(summary.completionPercent, 56);
    expect(summary.helperLabel, '3 need context - 0 ready');
  });

  test('portfolio domain readiness handles empty project views', () {
    final summary = buildProjectPortfolioDomainReadiness(projects: const []);

    expect(summary.hasProjects, isFalse);
    expect(summary.completionPercent, 0);
    expect(summary.helperLabel, 'No projects in view');
  });
}
