import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_playbook_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_session_playbook_strip.dart';

void main() {
  testWidgets('repair playbook strip renders playbook reviewer and evidence', (
    tester,
  ) async {
    final target = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'site-build',
        name: 'Site Build',
        businessDomain: 'Construction',
        health: ProjectHealth.blocked,
      ),
      column: _column(key: 'permit', label: 'Permit'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairSessionPlaybookStrip(
            summary: buildProjectDomainGapRepairSessionPlaybookSummary(
              plan: ProjectDomainGapRepairPlan.fromTargets([target]),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recovery checklist'), findsOneWidget);
    expect(find.text('Owner + sponsor'), findsOneWidget);
    expect(find.text('Minimum fields'), findsOneWidget);
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
  ProjectHealth health = ProjectHealth.onTrack,
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
