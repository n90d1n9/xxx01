import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_resource_capacity_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_resource_capacity_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('project resource capacity panel renders capacity signals', (
    tester,
  ) async {
    String? openedProjectId;
    final summary = ProjectResourceCapacitySummary(
      items: [
        ProjectResourceCapacityItem(
          name: 'Maya Santoso',
          primaryRole: 'Delivery Lead',
          totalAllocation: 1.15,
          state: ProjectResourceCapacityState.overallocated,
          assignments: const [
            ProjectResourceAssignment(
              projectId: 'retail',
              projectName: 'Retail Modernization',
              role: 'Delivery Lead',
              allocation: 0.7,
              health: ProjectHealth.onTrack,
            ),
            ProjectResourceAssignment(
              projectId: 'mobile',
              projectName: 'Mobile Field App',
              role: 'Program Advisor',
              allocation: 0.45,
              health: ProjectHealth.blocked,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectResourceCapacityPanel(
                summary: summary,
                onOpenProject: (projectId) => openedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Contributors'), findsOneWidget);
    expect(find.text('Overallocated'), findsWidgets);
    expect(find.text('Maya Santoso'), findsOneWidget);
    expect(find.textContaining('115% allocated'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsOneWidget);
    expect(find.textContaining('70% assignment'), findsOneWidget);

    await tester.tap(find.text('Open'));
    expect(openedProjectId, 'retail');
  });

  testWidgets('project resource capacity panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectResourceCapacityPanel(
            summary: ProjectResourceCapacitySummary(items: []),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No capacity data'), findsOneWidget);
  });
}
