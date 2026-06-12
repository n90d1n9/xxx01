import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_dialog.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_badge.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('details dialog renders shared status badges', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsDialog(
            workspace: savedWorkspacePinnedDeliveryToday,
          ),
        ),
      ),
    );

    expect(find.text('Workspace details'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text('Custom note'), findsOneWidget);
    expect(find.text('Auto summary preview'), findsOneWidget);
    expect(find.byType(OrderSavedWorkspaceManagerBadge), findsNWidgets(2));
    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details dialog hides auto summary preview for auto notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsDialog(
            workspace: savedWorkspaceWebOverdue,
          ),
        ),
      ),
    );

    expect(find.text('Auto summary'), findsOneWidget);
    expect(find.text('Auto summary preview'), findsNothing);
    expect(find.text('Shortcut id'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details dialog renders actions outside details content', (
    tester,
  ) async {
    final selectedActions = <OrderSavedWorkspaceAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsDialog(
            workspace: savedWorkspacePinnedDeliveryToday,
            actionEntries: const [
              OrderSavedWorkspaceActionEntry(
                action: OrderSavedWorkspaceAction.rename,
              ),
            ],
            onActionSelected: (action) async => selectedActions.add(action),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_actions')),
      findsOneWidget,
    );
    final renameAction = find.byKey(
      ValueKey(
        'order_saved_workspace_details_action_rename_'
        '${savedWorkspacePinnedDeliveryToday.id}',
      ),
    );
    await tester.tap(renameAction);
    await tester.pump();

    expect(selectedActions, [OrderSavedWorkspaceAction.rename]);
    expect(tester.takeException(), isNull);
  });
}
