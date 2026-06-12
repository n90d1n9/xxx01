import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action_handler.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  testWidgets('handler dispatches direct actions with workspace context', (
    tester,
  ) async {
    await tester.pumpWidget(const _HandlerHarness());

    final handledActions = <OrderSavedWorkspaceAction>[];
    OrderSavedWorkspace? deletedWorkspace;
    OrderSavedWorkspace? duplicatedWorkspace;
    OrderSavedWorkspace? pinnedWorkspace;
    bool? pinnedState;
    OrderSavedWorkspace? resetWorkspace;
    final moveDirections = <OrderSavedWorkspaceMoveDirection>[];

    Future<bool> handle(OrderSavedWorkspaceAction action) {
      return handleOrderSavedWorkspaceAction(
        context: _hostContext(tester),
        workspace: savedWorkspacePinnedDeliveryToday,
        action: action,
        onDeleted: (workspace) => deletedWorkspace = workspace,
        onDuplicated: (workspace) => duplicatedWorkspace = workspace,
        onPinnedChanged: (workspace, isPinned) {
          pinnedWorkspace = workspace;
          pinnedState = isPinned;
        },
        onDescriptionReset: (workspace) => resetWorkspace = workspace,
        onMoved: (workspace, direction) => moveDirections.add(direction),
        onActionHandled: () => handledActions.add(action),
      );
    }

    expect(await handle(OrderSavedWorkspaceAction.togglePin), true);
    expect(pinnedWorkspace, savedWorkspacePinnedDeliveryToday);
    expect(pinnedState, false);

    expect(await handle(OrderSavedWorkspaceAction.duplicate), true);
    expect(duplicatedWorkspace, savedWorkspacePinnedDeliveryToday);

    expect(await handle(OrderSavedWorkspaceAction.resetNote), true);
    expect(resetWorkspace, savedWorkspacePinnedDeliveryToday);

    expect(await handle(OrderSavedWorkspaceAction.moveEarlier), true);
    expect(await handle(OrderSavedWorkspaceAction.moveLater), true);
    expect(moveDirections, [
      OrderSavedWorkspaceMoveDirection.earlier,
      OrderSavedWorkspaceMoveDirection.later,
    ]);

    expect(await handle(OrderSavedWorkspaceAction.delete), true);
    expect(deletedWorkspace, savedWorkspacePinnedDeliveryToday);
    expect(handledActions, [
      OrderSavedWorkspaceAction.togglePin,
      OrderSavedWorkspaceAction.duplicate,
      OrderSavedWorkspaceAction.resetNote,
      OrderSavedWorkspaceAction.moveEarlier,
      OrderSavedWorkspaceAction.moveLater,
      OrderSavedWorkspaceAction.delete,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('handler ignores unavailable actions without handled hook', (
    tester,
  ) async {
    await tester.pumpWidget(const _HandlerHarness());

    var moved = false;
    var handledCount = 0;

    final blockedMove = await handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.moveEarlier,
      onMoved: (_, _) => moved = true,
      canMoveEarlier: false,
      onActionHandled: () => handledCount += 1,
    );

    final missingCallback = await handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.delete,
      onActionHandled: () => handledCount += 1,
    );

    expect(blockedMove, false);
    expect(missingCallback, false);
    expect(moved, false);
    expect(handledCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('handler dispatches actions from a reusable action context', (
    tester,
  ) async {
    await tester.pumpWidget(const _HandlerHarness());

    OrderSavedWorkspace? deletedWorkspace;
    var handledCount = 0;

    final handled = await handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.delete,
      actionContext: OrderSavedWorkspaceActionContext(
        onDeleted: (workspace) => deletedWorkspace = workspace,
        onActionHandled: () => handledCount += 1,
      ),
    );

    expect(handled, true);
    expect(deletedWorkspace, savedWorkspacePinnedDeliveryToday);
    expect(handledCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'handler exposes details quick actions and dispatches selection',
    (tester) async {
      await tester.pumpWidget(const _HandlerHarness());

      OrderSavedWorkspace? duplicatedWorkspace;
      final handledActions = <OrderSavedWorkspaceAction>[];

      final detailsFuture = handleOrderSavedWorkspaceAction(
        context: _hostContext(tester),
        workspace: savedWorkspacePinnedDeliveryToday,
        action: OrderSavedWorkspaceAction.details,
        onDuplicated: (workspace) => duplicatedWorkspace = workspace,
        onActionHandled:
            () => handledActions.add(OrderSavedWorkspaceAction.duplicate),
      );

      await tester.pumpAndSettle();
      expect(find.text('Workspace details'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('order_saved_workspace_details_actions')),
        findsOneWidget,
      );

      final duplicateAction = find.byKey(
        ValueKey(
          'order_saved_workspace_details_action_duplicate_'
          '${savedWorkspacePinnedDeliveryToday.id}',
        ),
      );
      await tester.ensureVisible(duplicateAction);
      await tester.pumpAndSettle();
      await tester.tap(duplicateAction);
      await tester.pumpAndSettle();

      expect(await detailsFuture, true);
      expect(duplicatedWorkspace, savedWorkspacePinnedDeliveryToday);
      expect(handledActions, [OrderSavedWorkspaceAction.duplicate]);
      expect(find.text('Workspace details'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('handler dispatches dialog actions after confirmed input', (
    tester,
  ) async {
    await tester.pumpWidget(const _HandlerHarness());

    String? renamedLabel;
    String? description;
    var handledCount = 0;

    final renameFuture = handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.rename,
      onRenamed: (_, label) => renamedLabel = label,
      onActionHandled: () => handledCount += 1,
    );

    await tester.pumpAndSettle();
    expect(find.text('Rename workspace'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_rename_field')),
      '  Handler courier  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_rename_save')),
    );
    await tester.pumpAndSettle();

    expect(await renameFuture, true);
    expect(renamedLabel, 'Handler courier');
    expect(handledCount, 1);

    final descriptionFuture = handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.editNote,
      onDescriptionChanged: (_, value) => description = value,
      onActionHandled: () => handledCount += 1,
    );

    await tester.pumpAndSettle();
    expect(find.text('Edit workspace note'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('order_saved_workspace_description_field')),
      '  Handler note  ',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('order_saved_workspace_description_save')),
    );
    await tester.pumpAndSettle();

    expect(await descriptionFuture, true);
    expect(description, 'Handler note');
    expect(handledCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('handler keeps cancelled dialog actions inert', (tester) async {
    await tester.pumpWidget(const _HandlerHarness());

    String? renamedLabel;
    var handledCount = 0;

    final renameFuture = handleOrderSavedWorkspaceAction(
      context: _hostContext(tester),
      workspace: savedWorkspacePinnedDeliveryToday,
      action: OrderSavedWorkspaceAction.rename,
      onRenamed: (_, label) => renamedLabel = label,
      onActionHandled: () => handledCount += 1,
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await renameFuture, false);
    expect(renamedLabel, isNull);
    expect(handledCount, 0);
    expect(tester.takeException(), isNull);
  });
}

class _HandlerHarness extends StatelessWidget {
  const _HandlerHarness();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: SizedBox(key: _hostKey)));
  }
}

BuildContext _hostContext(WidgetTester tester) {
  return tester.element(find.byKey(_hostKey));
}

const _hostKey = ValueKey('order_saved_workspace_action_handler_host');
