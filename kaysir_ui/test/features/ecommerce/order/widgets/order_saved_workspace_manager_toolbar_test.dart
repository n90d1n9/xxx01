import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_toolbar.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('manager toolbar emits search, scope, and sort changes', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    var query = '';
    OrderSavedWorkspaceManagerScope? selectedScope;
    OrderSavedWorkspaceManagerSort? selectedSort;

    await tester.pumpWidget(
      _ToolbarHarness(
        searchController: searchController,
        managerView: ecommerceOrderSavedWorkspaceManagerView(
          workspaces: savedWorkspaceManagerFixtures,
        ),
        scope: OrderSavedWorkspaceManagerScope.all,
        sortMode: OrderSavedWorkspaceManagerSort.defaultOrder,
        onQueryChanged: (value) => query = value,
        onScopeChanged: (value) => selectedScope = value,
        onSortChanged: (value) => selectedSort = value,
      ),
    );

    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('Pinned (1)'), findsOneWidget);
    expect(find.text('Notes (1)'), findsOneWidget);
    expect(find.text('Default order'), findsOneWidget);

    await tester.enterText(_searchField(), 'morning');
    await tester.pump();
    expect(query, 'morning');

    await tester.tap(
      _managerScopeButton(OrderSavedWorkspaceManagerScope.pinned),
    );
    await tester.pump();
    expect(selectedScope, OrderSavedWorkspaceManagerScope.pinned);

    await tester.tap(_managerSortButton());
    await tester.pumpAndSettle();
    await tester.tap(
      _managerSortOption(OrderSavedWorkspaceManagerSort.notesFirst),
    );
    await tester.pumpAndSettle();
    expect(selectedSort, OrderSavedWorkspaceManagerSort.notesFirst);
    expect(tester.takeException(), isNull);
  });
}

class _ToolbarHarness extends StatelessWidget {
  final OrderSavedWorkspaceManagerView managerView;
  final TextEditingController searchController;
  final OrderSavedWorkspaceManagerScope scope;
  final OrderSavedWorkspaceManagerSort sortMode;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<OrderSavedWorkspaceManagerScope> onScopeChanged;
  final ValueChanged<OrderSavedWorkspaceManagerSort> onSortChanged;

  const _ToolbarHarness({
    required this.managerView,
    required this.searchController,
    required this.scope,
    required this.sortMode,
    required this.onQueryChanged,
    required this.onScopeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 720,
          child: OrderSavedWorkspaceManagerToolbar(
            managerView: managerView,
            searchController: searchController,
            scope: scope,
            sortMode: sortMode,
            onQueryChanged: onQueryChanged,
            onScopeChanged: onScopeChanged,
            onSortChanged: onSortChanged,
          ),
        ),
      ),
    );
  }
}

Finder _searchField() {
  return find.byKey(const ValueKey('order_saved_workspace_manager_search'));
}

Finder _managerScopeButton(OrderSavedWorkspaceManagerScope scope) {
  return find.byKey(
    ValueKey('order_saved_workspace_manager_scope_${scope.name}'),
  );
}

Finder _managerSortButton() {
  return find.byKey(const ValueKey('order_saved_workspace_manager_sort'));
}

Finder _managerSortOption(OrderSavedWorkspaceManagerSort sortMode) {
  return find.byKey(
    ValueKey('order_saved_workspace_manager_sort_${sortMode.name}'),
  );
}
