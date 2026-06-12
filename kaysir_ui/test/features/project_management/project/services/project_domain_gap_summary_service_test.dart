import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_summary_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('domain gap summary counts reusable focus totals', () {
    final columns = buildProjectTableCustomColumns(
      projects: [
        _project('alpha', [
          _attribute('workstream', 'Workstream', 'Operations'),
          _attribute('priority', 'Priority', 'High'),
          _attribute('kpi-owner', 'KPI Owner', 'Leila'),
        ]),
        _project('beta', [
          _attribute('workstream', 'Workstream', 'Finance'),
          _attribute('region', 'Region', 'West'),
        ]),
        _project('gamma', [_attribute('kpi-owner', 'KPI Owner', 'Sam')]),
      ],
      maxColumns: 4,
    );

    final summary = buildProjectDomainGapSummary(columns: columns);

    expect(summary.columnCount, 4);
    expect(summary.applicableFieldCount, 12);
    expect(summary.filledFieldCount, 6);
    expect(summary.missingFieldCount, 6);
    expect(summary.missingRequiredCount, 3);
    expect(summary.missingRecommendedCount, 3);
    expect(summary.missingRiskSignalCount, 2);
    expect(summary.hasGaps, isTrue);
    expect(summary.isComplete, isFalse);
    expect(summary.coveragePercent, 50);
    expect(summary.coverageLabel, '6/12 filled');
    expect(summary.countFor(ProjectDomainGapFocus.all), 4);
    expect(summary.countFor(ProjectDomainGapFocus.missingAny), 6);
    expect(summary.countFor(ProjectDomainGapFocus.missingRequired), 3);
    expect(summary.countFor(ProjectDomainGapFocus.missingRecommended), 3);
    expect(summary.countFor(ProjectDomainGapFocus.missingRiskSignals), 2);
  });
}

ProjectPortfolioItem _project(
  String id,
  List<ProjectCustomAttribute> customAttributes,
) {
  return ProjectPortfolioItem(
    id: id,
    name: id,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.onTrack,
    milestones: const [],
    customAttributes: customAttributes,
  );
}

ProjectCustomAttribute _attribute(String key, String label, String value) {
  return ProjectCustomAttribute(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    value: value,
    isPinned: true,
  );
}
