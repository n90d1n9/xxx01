import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_reason_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_reason_chips.dart';

void main() {
  testWidgets('repair reason chips render reusable priority rationale', (
    tester,
  ) async {
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final reasonSet = buildProjectDomainGapRepairReasonSet(
      target: target,
      today: DateTime(2026, 6, 1),
      dueSoonDays: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairReasonChips(reasonSet: reasonSet),
        ),
      ),
    );

    expect(find.text('Mandatory context'), findsOneWidget);
    expect(find.text('Blocked project'), findsOneWidget);
    expect(find.text('Due in 7d'), findsOneWidget);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'field-app',
    name: 'Field App',
    owner: 'Owner',
    client: 'Client',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 5),
    endDate: DateTime(2026, 6, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column() {
  return const ProjectTableCustomColumn(
    key: 'repository',
    label: 'Repository',
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: {},
    filledProjectIds: {},
    pinnedProjectIds: {},
    requiredProjectIds: {},
    recommendedProjectIds: {},
    riskWatchedProjectIds: {},
  );
}
