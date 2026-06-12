import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_active_discovery_chips.dart';

void main() {
  testWidgets('active discovery chips render all active constraints', (
    tester,
  ) async {
    final cleared = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardWorkspaceActiveDiscoveryChips(
            query: const DashboardWorkspaceQuery(
              searchText: 'payroll',
              filter: DashboardWorkspaceFilter.operational,
              sort: DashboardWorkspaceSort.name,
            ),
            emphasized: true,
            onClearSearch: () => cleared.add('search'),
            onClearFilter: () => cleared.add('filter'),
            onClearSort: () => cleared.add('sort'),
          ),
        ),
      ),
    );

    expect(find.text('Search: payroll'), findsOneWidget);
    expect(find.text('Filter: Operational'), findsOneWidget);
    expect(find.text('Name A-Z order'), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.sort_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Remove search constraint'));
    await tester.tap(find.byTooltip('Remove workspace filter'));
    await tester.tap(find.byTooltip('Remove workspace sort'));

    expect(cleared, ['search', 'filter', 'sort']);
  });

  testWidgets('active discovery chips stay empty without active discovery', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardWorkspaceActiveDiscoveryChips(
            query: const DashboardWorkspaceQuery(),
            onClearSearch: () {},
            onClearFilter: () {},
            onClearSort: () {},
          ),
        ),
      ),
    );

    expect(find.byType(DashboardWorkspaceActiveDiscoveryChips), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsNothing);
    expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
    expect(find.byIcon(Icons.sort_rounded), findsNothing);
  });
}
