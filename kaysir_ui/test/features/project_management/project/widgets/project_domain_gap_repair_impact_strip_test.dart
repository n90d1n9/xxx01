import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_impact_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_impact_strip.dart';

void main() {
  testWidgets('repair impact strip renders reusable triage context', (
    tester,
  ) async {
    final summary = buildProjectDomainGapRepairImpactSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'field-app',
            name: 'Field App',
            businessDomain: 'Software Development',
            health: ProjectHealth.blocked,
          ),
          column: _column(key: 'repository', label: 'Repository'),
          priority: ProjectDomainGapRepairPriority.requiredField,
        ),
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'wedding',
            name: 'Wedding Plan',
            businessDomain: 'Wedding Organizer',
            health: ProjectHealth.atRisk,
          ),
          column: _column(key: 'venue', label: 'Venue'),
          priority: ProjectDomainGapRepairPriority.riskSignal,
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairImpactStrip(summary: summary),
        ),
      ),
    );

    expect(find.text('Next: Repository - Field App'), findsOneWidget);
    expect(find.text('2 projects'), findsOneWidget);
    expect(find.text('2 fields'), findsOneWidget);
    expect(find.text('2 domains'), findsOneWidget);
    expect(find.text('1 blocked project'), findsOneWidget);
  });

  testWidgets('repair impact strip hides when summary is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairImpactStrip(
            summary: buildProjectDomainGapRepairImpactSummary(
              plan: ProjectDomainGapRepairPlan.empty(),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Next:'), findsNothing);
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
  required ProjectHealth health,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: health,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column({required String key, required String label}) {
  return ProjectTableCustomColumn(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: const {},
    filledProjectIds: const {},
    pinnedProjectIds: const {},
    requiredProjectIds: const {},
    recommendedProjectIds: const {},
    riskWatchedProjectIds: const {},
  );
}
