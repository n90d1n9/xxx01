import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action_context.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('action context derives reusable capabilities', () {
    final context = OrderSavedWorkspaceActionContext(
      onDeleted: (_) {},
      onDuplicated: (_) {},
      onPinnedChanged: (_, _) {},
      onRenamed: (_, _) {},
      onDescriptionChanged: (_, _) {},
      onDescriptionReset: (_) {},
      onMoved: (_, _) {},
      canMoveEarlier: false,
      canMoveLater: true,
    );

    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceChipActionOrder,
      capabilities: context.toCapabilities(includeDetails: true),
    );

    expect(_actions(entries), [
      OrderSavedWorkspaceAction.details,
      OrderSavedWorkspaceAction.editNote,
      OrderSavedWorkspaceAction.resetNote,
      OrderSavedWorkspaceAction.moveEarlier,
      OrderSavedWorkspaceAction.moveLater,
      OrderSavedWorkspaceAction.rename,
      OrderSavedWorkspaceAction.duplicate,
      OrderSavedWorkspaceAction.togglePin,
      OrderSavedWorkspaceAction.delete,
    ]);
    expect(
      _entry(entries, OrderSavedWorkspaceAction.moveEarlier).enabled,
      false,
    );
    expect(_entry(entries, OrderSavedWorkspaceAction.moveLater).enabled, true);
  });

  test('empty action context exposes no capabilities', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceDetailsActionOrder,
      capabilities: OrderSavedWorkspaceActionContext.empty.capabilities,
    );

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
