import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_table.dart';

void main() {
  testWidgets('project table exposes remove action for created records only', (
    tester,
  ) async {
    ProjectPortfolioItem? removedProject;
    ProjectPortfolioItem? editedProject;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProjectPortfolioTable(
              projects: [_project('campus-renovation'), _project('demo')],
              removableProjectIds: const {'campus-renovation'},
              onEditProject: (project) => editedProject = project,
              onRemoveProject: (project) => removedProject = project,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Remove Campus Renovation'), findsOneWidget);
    expect(find.byTooltip('Edit Campus Renovation'), findsOneWidget);
    expect(find.byTooltip('Remove Demo'), findsNothing);
    expect(find.byTooltip('Edit Demo'), findsNothing);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-1300, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(editedProject?.id, 'campus-renovation');

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));

    expect(removedProject?.id, 'campus-renovation');
  });

  testWidgets('project table summarizes domain extension readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProjectPortfolioTable(projects: [_softwareProject()]),
          ),
        ),
      ),
    );

    expect(find.text('3/4 Needs Context'), findsOneWidget);
    expect(find.text('API Contract: No'), findsOneWidget);
    expect(find.text('Extensions'), findsOneWidget);
  });

  testWidgets('project table applies adaptive column profiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProjectPortfolioTable(
              projects: [_softwareProject()],
              visibleColumns: ProjectTableColumnProfile.domainContext.columns,
              customColumns: buildProjectTableCustomColumns(
                projects: [_softwareProject()],
                maxColumns: 3,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Project'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Extensions'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Progress'), findsNothing);
    expect(find.text('Budget'), findsNothing);
    expect(find.text('Open Milestones'), findsNothing);
    expect(find.text('API Contract'), findsOneWidget);
    expect(find.text('Target Environment'), findsOneWidget);
    expect(find.text('Repository'), findsOneWidget);
    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Missing required'), findsOneWidget);
    expect(find.text('API Contract: No'), findsOneWidget);
    expect(
      find.byTooltip('1/1 filled - Required - Risk signal in 1'),
      findsNWidgets(2),
    );
    expect(
      find.byTooltip('0/1 filled - Required - Risk signal in 1'),
      findsOneWidget,
    );
    expect(find.byTooltip('Repository: Missing required'), findsOneWidget);
  });

  testWidgets('project table exposes custom attribute repair action', (
    tester,
  ) async {
    ProjectPortfolioItem? repairedProject;
    ProjectTableCustomColumn? repairedColumn;
    final project = _softwareProject();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProjectPortfolioTable(
              projects: [project],
              visibleColumns: ProjectTableColumnProfile.domainContext.columns,
              customColumns: buildProjectTableCustomColumns(
                projects: [project],
                maxColumns: 3,
              ),
              removableProjectIds: const {'field-app'},
              onEditProjectCustomAttribute: (project, column) {
                repairedProject = project;
                repairedColumn = column;
              },
            ),
          ),
        ),
      ),
    );

    final repairAction = find.byKey(
      const ValueKey('project-custom-attribute-fix-field-app-repository'),
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-1300, 0),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(repairAction);

    expect(repairAction, findsOneWidget);
    expect(find.byTooltip('Edit Repository for Field App'), findsOneWidget);

    await tester.tap(repairAction);

    expect(repairedProject?.id, 'field-app');
    expect(repairedColumn?.key, 'repository');
  });
}

ProjectPortfolioItem _project(String id) {
  final isDemo = id == 'demo';
  return ProjectPortfolioItem(
    id: id,
    name: isDemo ? 'Demo' : 'Campus Renovation',
    owner: 'Dewi Lestari',
    client: 'Education Office',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.onTrack,
    milestones: const [],
  );
}

ProjectPortfolioItem _softwareProject() {
  return ProjectPortfolioItem(
    id: 'field-app',
    name: 'Field App',
    owner: 'Nadia Putri',
    client: 'Service Team',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.4,
    budgetUsed: 0.3,
    health: ProjectHealth.atRisk,
    milestones: const [],
    customAttributes: const [
      ProjectCustomAttribute(
        key: 'api-contract',
        label: 'API Contract',
        type: ProjectCustomAttributeType.boolean,
        value: 'No',
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'target-environment',
        label: 'Target Environment',
        type: ProjectCustomAttributeType.choice,
        value: 'Production',
        options: ['Development', 'Staging', 'Production'],
        isPinned: true,
      ),
      ProjectCustomAttribute(
        key: 'release-train',
        label: 'Release Train',
        type: ProjectCustomAttributeType.text,
        value: 'Q3 Mobile',
      ),
    ],
  );
}
