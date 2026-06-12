import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_action_presentation.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test(
    'chip action entries preserve shortcut menu order and enabled state',
    () {
      final entries = orderSavedWorkspaceActionEntries(
        workspace: savedWorkspacePinnedDeliveryToday,
        order: orderSavedWorkspaceChipActionOrder,
        capabilities: const OrderSavedWorkspaceActionCapabilities(
          includeDetails: true,
          canEditNote: true,
          canResetNote: true,
          canMove: true,
          canMoveEarlier: false,
          canMoveLater: true,
          canRename: true,
          canDuplicate: true,
          canTogglePin: true,
          canDelete: true,
        ),
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
      expect(
        _entry(entries, OrderSavedWorkspaceAction.moveLater).enabled,
        true,
      );
    },
  );

  test('action entries hide custom note reset for auto summaries', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePickupPriority,
      order: orderSavedWorkspaceChipActionOrder,
      capabilities: const OrderSavedWorkspaceActionCapabilities(
        includeDetails: true,
        canEditNote: true,
        canResetNote: true,
        canMove: false,
        canRename: true,
        canDuplicate: false,
        canTogglePin: false,
        canDelete: false,
      ),
    );

    expect(_actions(entries), [
      OrderSavedWorkspaceAction.details,
      OrderSavedWorkspaceAction.editNote,
      OrderSavedWorkspaceAction.rename,
    ]);
    expect(
      _actions(entries),
      isNot(contains(OrderSavedWorkspaceAction.resetNote)),
    );
  });

  test('manager action entries preserve manager row action order', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceManagerActionOrder,
      capabilities: const OrderSavedWorkspaceActionCapabilities(
        canEditNote: true,
        canResetNote: true,
        canMove: true,
        canMoveEarlier: true,
        canMoveLater: false,
        canRename: true,
        canDuplicate: true,
        canTogglePin: true,
        canDelete: true,
      ),
    );

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
      true,
    );
    expect(_entry(entries, OrderSavedWorkspaceAction.moveLater).enabled, false);
  });

  test('details action entries preserve details surface order', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceDetailsActionOrder,
      capabilities: const OrderSavedWorkspaceActionCapabilities(
        canEditNote: true,
        canResetNote: true,
        canMove: true,
        canMoveEarlier: true,
        canMoveLater: false,
        canRename: true,
        canDuplicate: true,
        canTogglePin: true,
        canDelete: true,
      ),
    );

    expect(_actions(entries), [
      OrderSavedWorkspaceAction.editNote,
      OrderSavedWorkspaceAction.resetNote,
      OrderSavedWorkspaceAction.rename,
      OrderSavedWorkspaceAction.duplicate,
      OrderSavedWorkspaceAction.togglePin,
      OrderSavedWorkspaceAction.moveEarlier,
      OrderSavedWorkspaceAction.moveLater,
      OrderSavedWorkspaceAction.delete,
    ]);
    expect(
      _entry(entries, OrderSavedWorkspaceAction.moveEarlier).enabled,
      true,
    );
    expect(_entry(entries, OrderSavedWorkspaceAction.moveLater).enabled, false);
  });

  test('action entries default to no available actions', () {
    final entries = orderSavedWorkspaceActionEntries(
      workspace: savedWorkspacePinnedDeliveryToday,
      order: orderSavedWorkspaceChipActionOrder,
    );

    expect(entries, isEmpty);
  });

  test('action presentation adapts pin and delete labels', () {
    final pinPresentation = orderSavedWorkspaceActionPresentation(
      action: OrderSavedWorkspaceAction.togglePin,
      workspace: savedWorkspacePickupPriority,
    );
    final unpinPresentation = orderSavedWorkspaceActionPresentation(
      action: OrderSavedWorkspaceAction.togglePin,
      workspace: savedWorkspacePinnedDeliveryToday,
    );
    final deletePresentation = orderSavedWorkspaceActionPresentation(
      action: OrderSavedWorkspaceAction.delete,
      workspace: savedWorkspacePickupPriority,
      deleteLabel: 'Remove',
      isDeleteDestructive: true,
    );

    expect(pinPresentation.label, 'Pin');
    expect(unpinPresentation.label, 'Unpin');
    expect(deletePresentation.label, 'Remove');
    expect(deletePresentation.isDestructive, true);
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
