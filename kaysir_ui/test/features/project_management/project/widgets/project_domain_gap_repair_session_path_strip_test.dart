import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_path_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_session_path_strip.dart';

void main() {
  testWidgets('repair session path strip opens any visible step', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(id: 'field-app', name: 'Field App'),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(id: 'wedding', name: 'Wedding Plan'),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairSessionPathStrip(
            summary: buildProjectDomainGapRepairSessionPathSummary(
              plan: ProjectDomainGapRepairPlan.fromTargets([first, second]),
            ),
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('1 Repository - Field App'), findsOneWidget);
    expect(find.text('2 Venue - Wedding Plan'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-session-step-2')),
    );

    expect(repairedTarget, second);
  });
}

ProjectPortfolioItem _project({required String id, required String name}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.blocked,
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
