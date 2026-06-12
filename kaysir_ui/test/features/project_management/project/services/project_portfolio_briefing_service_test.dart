import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_briefing_service.dart';

void main() {
  test('project portfolio briefing prioritizes blocked delivery work', () {
    final summary = buildProjectPortfolioBriefing(
      projects: demoProjectPortfolio,
      totalProjectCount: demoProjectPortfolio.length,
      today: DateTime(2026, 5, 31),
    );

    expect(summary.signal, ProjectPortfolioBriefingSignal.blocked);
    expect(summary.visibleCount, 4);
    expect(summary.attentionCount, 2);
    expect(summary.blockedCount, 1);
    expect(summary.budgetPressureCount, 1);
    expect(summary.domainContextGapCount, 4);
    expect(summary.recommendedProject?.id, 'mobile-field-app');
    expect(summary.strongestRisk?.title, 'API contract drift');
    expect(summary.nextMilestone?.label, 'API Ready');
    expect(summary.nextMilestone?.daysUntilDue, 11);
    expect(summary.domainGap?.projectId, 'mobile-field-app');
    expect(summary.domainGap?.completionLabel, '2/4');
    expect(summary.domainGap?.missingFieldLabel, 'Repository, API Contract');
    expect(summary.actionTitle, 'Unblock Mobile Field App');
  });

  test('project portfolio briefing handles filtered healthy views', () {
    final summary = buildProjectPortfolioBriefing(
      projects: demoProjectPortfolio.where(
        (project) => project.id == 'retail-modernization',
      ),
      totalProjectCount: demoProjectPortfolio.length,
      today: DateTime(2026, 5, 31),
    );

    expect(summary.signal, ProjectPortfolioBriefingSignal.clear);
    expect(summary.visibleCount, 1);
    expect(summary.attentionCount, 0);
    expect(summary.blockedCount, 0);
    expect(summary.domainContextGapCount, 1);
    expect(summary.strongestRisk?.title, 'Store readiness');
    expect(summary.nextMilestone?.label, 'Pilot');
    expect(summary.nextMilestone?.dueLabel, 'Due in 21d');
    expect(summary.domainGap?.projectId, 'retail-modernization');
    expect(summary.domainGap?.statusLabel, 'In Progress');
    expect(summary.domainGap?.missingFieldLabel, 'Omnichannel Impact');
    expect(summary.actionTitle, 'Complete domain context');
  });

  test('project portfolio briefing reports empty board views', () {
    final summary = buildProjectPortfolioBriefing(
      projects: const [],
      totalProjectCount: demoProjectPortfolio.length,
    );

    expect(summary.signal, ProjectPortfolioBriefingSignal.clear);
    expect(summary.hasProjects, isFalse);
    expect(summary.actionTitle, 'No projects in view');
    expect(summary.domainContextGapCount, 0);
    expect(summary.recommendedProject, isNull);
    expect(summary.strongestRisk, isNull);
    expect(summary.nextMilestone, isNull);
    expect(summary.domainGap, isNull);
  });
}
