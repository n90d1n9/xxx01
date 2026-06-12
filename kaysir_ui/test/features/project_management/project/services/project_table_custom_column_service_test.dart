import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('builds custom table columns from pinned filled project attributes', () {
    final columns = buildProjectTableCustomColumns(
      projects: [
        _project('retail', [
          _attribute('workstream', 'Workstream', 'Retail ops'),
          _attribute('launch-wave', 'Launch Wave', 'Wave 2'),
        ]),
        _project('finance', [
          _attribute('workstream', 'Workstream', 'Finance close'),
          _attribute('kpi-owner', 'KPI Owner', 'Controller'),
        ]),
        _project('software', [
          _attribute('target-environment', 'Target Environment', 'Prod'),
          _attribute('release-train', 'Release Train', 'Q3', isPinned: false),
        ]),
      ],
      maxColumns: 3,
    );

    expect(columns.map((column) => column.key), [
      'workstream',
      'priority',
      'kpi-owner',
    ]);
    expect(columns.first.filledProjectCount, 2);
    expect(columns.first.pinnedProjectCount, 2);
    expect(columns.first.requiredProjectCount, 3);
    expect(columns.first.coverageLabel, '2/3 filled');
    expect(columns.first.coveragePercent, 67);
    expect(columns.first.summaryLabel, '2/3 filled - Required');
    expect(columns.first.gapSummaryLabel, '1 required gap');
    expect(columns[1].summaryLabel, '0/3 filled - Required - Risk signal in 3');
    expect(columns[1].gapSummaryLabel, '3 required gaps');
    expect(columns.first.valueFor(_project('x', [])), 'Not set');
    expect(columns[1].isRequiredFor(_project('retail', [])), isTrue);
    expect(
      columns[1].displayValueFor(_project('retail', [])),
      'Missing required',
    );
    expect(
      columns[1].tooltipFor(_project('retail', [])),
      'Priority: Missing required',
    );
  });

  test('returns no custom table columns when disabled or no projects', () {
    expect(buildProjectTableCustomColumns(projects: const []), isEmpty);
    expect(
      buildProjectTableCustomColumns(
        projects: [
          _project('x', [_attribute('workstream', 'Workstream', 'Retail')]),
        ],
        maxColumns: 0,
      ),
      isEmpty,
    );
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

ProjectCustomAttribute _attribute(
  String key,
  String label,
  String value, {
  bool isPinned = true,
}) {
  return ProjectCustomAttribute(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    value: value,
    isPinned: isPinned,
  );
}
