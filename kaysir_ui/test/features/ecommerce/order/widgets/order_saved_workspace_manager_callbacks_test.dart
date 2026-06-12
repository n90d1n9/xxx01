import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_callbacks.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('manager callbacks expose row action capabilities', () {
    final callbacks = OrderSavedWorkspaceManagerCallbacks(
      onSelected: (_) {},
      onDeleted: (_) {},
      onDuplicated: (_) {},
      onPinnedChanged: (_, _) {},
      onRenamed: (_, _) {},
      onDescriptionChanged: (_, _) {},
      onDescriptionReset: (_) {},
      onMoved: (_, _) {},
    );

    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceManagerActionOrder,
      capabilities: callbacks.actionCapabilities(
        canMoveEarlier: false,
        canMoveLater: true,
      ),
    );

    expect(callbacks.canSelect, true);
    expect(callbacks.hasRowActions, true);
    expect(_actions(entries), [
      OrderSavedWorkspaceAction.togglePin,
      OrderSavedWorkspaceAction.duplicate,
      OrderSavedWorkspaceAction.rename,
      OrderSavedWorkspaceAction.editNote,
      OrderSavedWorkspaceAction.resetNote,
      OrderSavedWorkspaceAction.moveEarlier,
      OrderSavedWorkspaceAction.moveLater,
      OrderSavedWorkspaceAction.delete,
    ]);
    expect(
      _entry(entries, OrderSavedWorkspaceAction.moveEarlier).enabled,
      false,
    );
    expect(_entry(entries, OrderSavedWorkspaceAction.moveLater).enabled, true);
  });

  test('manager callbacks create reusable action context', () {
    var handledCount = 0;
    final callbacks = OrderSavedWorkspaceManagerCallbacks(
      onDeleted: (_) {},
      onMoved: (_, _) {},
    );

    final context = callbacks.actionContext(
      canMoveEarlier: false,
      canMoveLater: true,
      onActionHandled: () => handledCount += 1,
    );

    expect(context.onDeleted, isNotNull);
    expect(context.onMoved, isNotNull);
    expect(context.capabilities.canDelete, true);
    expect(context.capabilities.canMoveEarlier, false);
    expect(context.capabilities.canMoveLater, true);

    context.onActionHandled?.call();
    expect(handledCount, 1);
  });

  test('empty manager callbacks expose no row actions', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceManagerActionOrder,
      capabilities: OrderSavedWorkspaceManagerCallbacks.empty
          .actionCapabilities(canMoveEarlier: true, canMoveLater: true),
    );

    expect(OrderSavedWorkspaceManagerCallbacks.empty.canSelect, false);
    expect(OrderSavedWorkspaceManagerCallbacks.empty.hasRowActions, false);
    expect(entries, isEmpty);
  });
}

List<OrderSavedWorkspaceAction> _actions(
  List<OrderSavedWorkspaceActionEntry> entries,
) {
  return entries.map((entry) => entry.action).toList(growable: false);
}

OrderSavedWorkspaceActionEntry _entry(
  List<OrderSavedWorkspaceActionEntry> entries,
  OrderSavedWorkspaceAction action,
) {
  return entries.singleWhere((entry) => entry.action == action);
}
