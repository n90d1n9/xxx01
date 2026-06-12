import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_surface_frame.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_surface_header.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('surface header emits close and can hide close control', (
    tester,
  ) async {
    var closeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsSurfaceHeader(
            title: 'Workspace details',
            onClose: () => closeCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_header')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
    );
    await tester.pump();
    expect(closeCount, 1);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsSurfaceHeader(
            title: 'Workspace details',
            showCloseButton: false,
          ),
        ),
      ),
    );

    expect(find.text('Workspace details'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_close')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('surface frame renders shared chrome, content, and actions', (
    tester,
  ) async {
    final selectedActions = <OrderSavedWorkspaceAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            height: 640,
            child: OrderSavedWorkspaceDetailsSurfaceFrame(
              workspace: savedWorkspacePinnedDeliveryToday,
              padding: const EdgeInsets.all(12),
              contentMaxWidth: 460,
              showDragHandle: true,
              showDivider: true,
              actionEntries: const [
                OrderSavedWorkspaceActionEntry(
                  action: OrderSavedWorkspaceAction.rename,
                ),
              ],
              onActionSelected: (action) async => selectedActions.add(action),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_drag_handle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_saved_workspace_details_header')),
      findsOneWidget,
    );
    expect(find.text('Workspace details'), findsOneWidget);
    expect(find.text('Exact filters'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('order_saved_workspace_details_sticky_actions'),
      ),
      findsOneWidget,
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
