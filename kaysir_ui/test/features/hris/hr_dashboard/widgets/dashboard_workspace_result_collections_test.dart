import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_result_collections.dart';

void main() {
  test('workspace grid layout derives stable responsive columns', () {
    expect(DashboardWorkspaceGridLayout.fromMaxWidth(600).columns, 1);
    expect(
      DashboardWorkspaceGridLayout.fromMaxWidth(600).aspectRatio,
      closeTo(1.45, 0.001),
    );

    expect(DashboardWorkspaceGridLayout.fromMaxWidth(900).columns, 2);
    expect(
      DashboardWorkspaceGridLayout.fromMaxWidth(900).aspectRatio,
      closeTo(1.55, 0.001),
    );

    expect(DashboardWorkspaceGridLayout.fromMaxWidth(1300).columns, 3);
    expect(
      DashboardWorkspaceGridLayout.fromMaxWidth(1300).aspectRatio,
      closeTo(1.48, 0.001),
    );
  });

  testWidgets('workspace grid renders cards with the derived layout', (
    tester,
  ) async {
    final entries = [
      _entry(HrisWorkspaceId.peopleOps),
      _entry(HrisWorkspaceId.attendance),
      _entry(HrisWorkspaceId.payroll),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: DashboardWorkspaceGrid(entries: entries, maxWidth: 900),
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 2);
    expect(delegate.childAspectRatio, closeTo(1.55, 0.001));
    expect(
      find.byKey(const ValueKey('workspace-card-/hris-people-ops')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-card-/attendance')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-card-/payroll')),
      findsOneWidget,
    );
  });

  testWidgets('workspace list renders list items with separators', (
    tester,
  ) async {
    final entries = [
      _entry(HrisWorkspaceId.peopleOps),
      _entry(HrisWorkspaceId.attendance),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: DashboardWorkspaceList(entries: entries),
          ),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workspace-list-/hris-people-ops')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-list-/attendance')),
      findsOneWidget,
    );
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
  });
}

DashboardWorkspaceEntry _entry(HrisWorkspaceId id) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    metrics: const [
      DashboardWorkspaceMetric(
        icon: Icons.analytics_outlined,
        label: 'Metric',
        value: '1',
      ),
    ],
  );
}
