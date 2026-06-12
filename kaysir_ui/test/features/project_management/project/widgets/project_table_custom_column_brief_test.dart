import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_table_custom_column_brief.dart';

void main() {
  testWidgets('brief renders aggregate and per-field coverage gaps', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProjectTableCustomColumnBrief(columns: columns)),
      ),
    );

    expect(find.text('Domain Gap Workbench'), findsOneWidget);
    expect(find.text('50% complete across 4 adaptive fields'), findsOneWidget);
    expect(find.text('6/12 filled'), findsOneWidget);
    expect(find.text('Any gaps: 6'), findsOneWidget);
    expect(find.text('Required gaps: 3'), findsOneWidget);
    expect(find.text('Recommended gaps: 3'), findsOneWidget);
    expect(find.text('Risk gaps: 2'), findsOneWidget);
    expect(find.text('Workstream: 1 required gap'), findsOneWidget);
    expect(find.text('Priority: 2 required gaps'), findsOneWidget);
    expect(find.text('Region: 2 recommended gaps'), findsOneWidget);
    expect(find.text('KPI Owner: 1 recommended gap'), findsOneWidget);
  });

  testWidgets('brief gap chips request a domain gap focus', (tester) async {
    final columns = buildProjectTableCustomColumns(
      projects: [
        _project('alpha', [_attribute('workstream', 'Workstream', 'Ops')]),
        _project('beta', [_attribute('kpi-owner', 'KPI Owner', 'Leila')]),
      ],
      maxColumns: 4,
    );
    var selectedFocus = ProjectDomainGapFocus.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectTableCustomColumnBrief(
            columns: columns,
            domainGapFocus: selectedFocus,
            onDomainGapFocusChanged: (focus) => selectedFocus = focus,
          ),
        ),
      ),
    );

    expect(find.text('All Fields'), findsOneWidget);
    expect(find.text('Any Gaps (6)'), findsOneWidget);
    expect(find.text('Required (3)'), findsOneWidget);
    expect(find.text('Recommended (3)'), findsOneWidget);
    expect(find.text('Risk (2)'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-table-brief-any-gap-focus')),
    );

    expect(selectedFocus, ProjectDomainGapFocus.missingAny);
  });

  testWidgets('brief renders no chrome when no columns are selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProjectTableCustomColumnBrief(columns: [])),
      ),
    );

    expect(find.text('Domain Gap Workbench'), findsNothing);
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
