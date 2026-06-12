import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter_counts.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_filter.dart';

void main() {
  testWidgets('workspace filter bar disables unavailable filters', (
    tester,
  ) async {
    var selectedFilter = DashboardWorkspaceFilter.all;
    final changes = <DashboardWorkspaceFilter>[];
    const counts = DashboardWorkspaceFilterCounts(
      totalCount: 2,
      strategicCount: 1,
      operationalCount: 1,
      attentionCount: 1,
      timeSensitiveCount: 1,
      criticalCount: 0,
      elevatedCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1400,
            child: StatefulBuilder(
              builder: (context, setState) {
                return DashboardWorkspaceFilterBar(
                  selectedFilter: selectedFilter,
                  counts: counts,
                  onChanged: (filter) {
                    changes.add(filter);
                    setState(() => selectedFilter = filter);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Critical 0'), findsOneWidget);
    expect(find.text('Elevated 0'), findsOneWidget);

    await tester.ensureVisible(find.text('Critical 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Critical 0'));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(selectedFilter, DashboardWorkspaceFilter.all);

    await tester.ensureVisible(find.text('Strategic 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Strategic 1'));
    await tester.pumpAndSettle();

    expect(changes, [DashboardWorkspaceFilter.strategic]);
    expect(selectedFilter, DashboardWorkspaceFilter.strategic);
  });
}
