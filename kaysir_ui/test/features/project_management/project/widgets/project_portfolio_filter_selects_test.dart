import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_filter_selects.dart';

void main() {
  testWidgets('health filter select emits nullable health values', (
    tester,
  ) async {
    ProjectHealth? selectedHealth;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectHealthFilterSelect(
            fieldKey: const ValueKey('project-health-filter-select'),
            value: selectedHealth,
            onChanged: (health) => selectedHealth = health,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('project-health-filter-select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blocked'));
    await tester.pumpAndSettle();

    expect(selectedHealth, ProjectHealth.blocked);
  });

  testWidgets('domain readiness filter select emits readiness values', (
    tester,
  ) async {
    var selectedFilter = ProjectDomainReadinessFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainReadinessFilterSelect(
            fieldKey: const ValueKey('project-domain-filter-select'),
            value: selectedFilter,
            onChanged: (filter) => selectedFilter = filter,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('project-domain-filter-select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Needs Context'));
    await tester.pumpAndSettle();

    expect(selectedFilter, ProjectDomainReadinessFilter.needsContext);
  });

  testWidgets('portfolio sort select emits sort values', (tester) async {
    var selectedSort = ProjectPortfolioSortOption.attention;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectPortfolioSortSelect(
            fieldKey: const ValueKey('project-sort-select'),
            value: selectedSort,
            onChanged: (sort) => selectedSort = sort,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('project-sort-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budget Used'));
    await tester.pumpAndSettle();

    expect(selectedSort, ProjectPortfolioSortOption.budget);
  });
}
