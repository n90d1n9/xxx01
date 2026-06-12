import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_portfolio_view_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_filter_bar.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_filter_selects.dart';

void main() {
  testWidgets('portfolio filter bar composes search and reusable selects', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var searchQuery = '';
    ProjectHealth? selectedHealth;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectPortfolioFilterBar(
            searchController: controller,
            searchFocusNode: focusNode,
            searchHintText: 'Search records',
            healthFilter: selectedHealth,
            domainReadinessFilter: ProjectDomainReadinessFilter.all,
            domainGapFocus: ProjectDomainGapFocus.all,
            sortOption: ProjectPortfolioSortOption.attention,
            leadingControls: const [Text('Profile control')],
            onSearchChanged: (query) => searchQuery = query,
            onHealthChanged: (health) => selectedHealth = health,
            onDomainReadinessChanged: (_) {},
            onDomainGapFocusChanged: (_) {},
            onSortChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Profile control'), findsOneWidget);
    expect(find.byType(ProjectHealthFilterSelect), findsOneWidget);
    expect(find.text('All Health'), findsOneWidget);
    expect(find.text('All Domains'), findsOneWidget);
    expect(find.text('All Projects'), findsOneWidget);
    expect(find.text('Needs Attention'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'mobile');
    await tester.pump();

    expect(searchQuery, 'mobile');

    await tester.tap(find.text('All Health'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blocked'));
    await tester.pumpAndSettle();

    expect(selectedHealth, ProjectHealth.blocked);
  });
}
