import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_field_hint_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair field hint describes URL targets', () {
    final hint = buildProjectDomainGapRepairFieldHint(
      target: _target(type: ProjectCustomAttributeType.url),
    );

    expect(hint.type, ProjectCustomAttributeType.url);
    expect(hint.label, 'URL value');
    expect(hint.detail, contains('Repository'));
    expect(hint.detail, contains('source of truth'));
  });

  test('repair field hint distinguishes choice and yes/no targets', () {
    expect(
      buildProjectDomainGapRepairFieldHint(
        target: _target(type: ProjectCustomAttributeType.choice),
      ).label,
      'Choice value',
    );
    expect(
      buildProjectDomainGapRepairFieldHint(
        target: _target(type: ProjectCustomAttributeType.boolean),
      ).label,
      'Yes/No value',
    );
  });
}

ProjectDomainGapRepairTarget _target({
  required ProjectCustomAttributeType type,
}) {
  return ProjectDomainGapRepairTarget(
    project: ProjectPortfolioItem(
      id: 'field-app',
      name: 'Field App',
      owner: 'Owner',
      client: 'Client',
      businessDomain: 'Software Development',
      startDate: DateTime(2026, 5),
      endDate: DateTime(2026, 6),
      progress: 0.4,
      budgetUsed: 0.2,
      health: ProjectHealth.onTrack,
      milestones: const [],
    ),
    column: ProjectTableCustomColumn(
      key: 'repository',
      label: 'Repository',
      type: type,
      applicableProjectIds: const {'field-app'},
      filledProjectIds: const {},
      pinnedProjectIds: const {},
      requiredProjectIds: const {'field-app'},
      recommendedProjectIds: const {},
      riskWatchedProjectIds: const {},
    ),
    priority: ProjectDomainGapRepairPriority.requiredField,
  );
}
