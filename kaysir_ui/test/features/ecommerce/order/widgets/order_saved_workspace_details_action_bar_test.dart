import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_action_bar.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('details action bar renders enabled and disabled actions', (
    tester,
  ) async {
    final selectedActions = <OrderSavedWorkspaceAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsActionBar(
            workspace: savedWorkspacePinnedDeliveryToday,
            actionEntries: const [
              OrderSavedWorkspaceActionEntry(
                action: OrderSavedWorkspaceAction.rename,
              ),
              OrderSavedWorkspaceActionEntry(
                action: OrderSavedWorkspaceAction.moveLater,
                enabled: false,
              ),
              OrderSavedWorkspaceActionEntry(
                action: OrderSavedWorkspaceAction.delete,
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
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Move later'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(
              ValueKey(
                'order_saved_workspace_details_action_move_later_'
                '${savedWorkspacePinnedDeliveryToday.id}',
              ),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(
      find.byKey(
        ValueKey(
          'order_saved_workspace_details_action_rename_'
          '${savedWorkspacePinnedDeliveryToday.id}',
        ),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(
        ValueKey(
          'order_saved_workspace_details_action_delete_'
          '${savedWorkspacePinnedDeliveryToday.id}',
        ),
      ),
    );
    await tester.pump();

    expect(selectedActions, [
      OrderSavedWorkspaceAction.rename,
      OrderSavedWorkspaceAction.delete,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details action bar hides without runnable actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsActionBar(
            workspace: savedWorkspacePinnedDeliveryToday,
            actionEntries: [
              OrderSavedWorkspaceActionEntry(
                action: OrderSavedWorkspaceAction.rename,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_actions')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
