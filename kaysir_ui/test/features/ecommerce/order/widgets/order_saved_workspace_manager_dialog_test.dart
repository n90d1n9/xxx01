import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_callbacks.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_dialog.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('manager dialog wires search and scope into visible rows', (
    tester,
  ) async {
    await tester.pumpWidget(const _DialogHarness(workspaces: _workspaces));

    expect(_managerItem(savedWorkspaceDeliveryToday.id), findsOneWidget);
    expect(_managerItem(savedWorkspacePinnedPickupPriority.id), findsOneWidget);

    await tester.enterText(_managerSearch(), 'delivery');
    await tester.pump();

    expect(_managerItem(savedWorkspaceDeliveryToday.id), findsOneWidget);
    expect(_managerItem(savedWorkspacePinnedPickupPriority.id), findsNothing);

    await tester.enterText(_managerSearch(), '');
    await tester.pump();
    await tester.tap(
      _managerScopeButton(OrderSavedWorkspaceManagerScope.pinned),
    );
    await tester.pumpAndSettle();

    expect(_managerItem(savedWorkspaceDeliveryToday.id), findsNothing);
    expect(_managerItem(savedWorkspacePinnedPickupPriority.id), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager dialog wires sort mode into row ordering', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _DialogHarness(workspaces: _unsortedWorkspaces),
    );

    expect(
      tester.getTopLeft(_managerItem(savedWorkspacePinnedPickupPriority.id)).dy,
      lessThan(
        tester.getTopLeft(_managerItem(savedWorkspaceDeliveryToday.id)).dy,
      ),
    );

    await tester.tap(_managerSortButton());
    await tester.pumpAndSettle();
    await tester.tap(
      _managerSortOption(OrderSavedWorkspaceManagerSort.labelAscending),
    );
    await tester.pumpAndSettle();

    expect(find.text('Label A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(_managerItem(savedWorkspaceDeliveryToday.id)).dy,
      lessThan(
        tester
            .getTopLeft(_managerItem(savedWorkspacePinnedPickupPriority.id))
            .dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

class _DialogHarness extends StatelessWidget {
  final List<OrderSavedWorkspace> workspaces;

  const _DialogHarness({required this.workspaces});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OrderSavedWorkspaceManagerDialog(
            workspaces: workspaces,
            activeWorkspaceId: null,
            callbacks: OrderSavedWorkspaceManagerCallbacks(
              onSelected: (_) {},
              onDeleted: (_) {},
              onDuplicated: (_) {},
              onPinnedChanged: (_, _) {},
              onRenamed: (_, _) {},
              onDescriptionChanged: (_, _) {},
              onDescriptionReset: (_) {},
              onMoved: (_, _) {},
            ),
          ),
        ),
      ),
    );
  }
}

Finder _managerSearch() {
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

Finder _managerItem(String id) {
  return find.byKey(ValueKey('order_saved_workspace_manager_$id'));
}

const _workspaces = [
  savedWorkspaceDeliveryToday,
  savedWorkspacePinnedPickupPriority,
];

const _unsortedWorkspaces = [
  savedWorkspacePinnedPickupPriority,
  savedWorkspaceDeliveryToday,
];
