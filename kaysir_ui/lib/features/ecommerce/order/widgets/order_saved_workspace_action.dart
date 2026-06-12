import '../models/order_saved_workspace.dart';

enum OrderSavedWorkspaceAction {
  details,
  editNote,
  resetNote,
  moveEarlier,
  moveLater,
  duplicate,
  rename,
  togglePin,
  delete,
}

const orderSavedWorkspaceChipActionOrder = [
  OrderSavedWorkspaceAction.details,
  OrderSavedWorkspaceAction.editNote,
  OrderSavedWorkspaceAction.resetNote,
  OrderSavedWorkspaceAction.moveEarlier,
  OrderSavedWorkspaceAction.moveLater,
  OrderSavedWorkspaceAction.rename,
  OrderSavedWorkspaceAction.duplicate,
  OrderSavedWorkspaceAction.togglePin,
  OrderSavedWorkspaceAction.delete,
];

const orderSavedWorkspaceManagerActionOrder = [
  OrderSavedWorkspaceAction.togglePin,
  OrderSavedWorkspaceAction.duplicate,
  OrderSavedWorkspaceAction.rename,
  OrderSavedWorkspaceAction.editNote,
  OrderSavedWorkspaceAction.resetNote,
  OrderSavedWorkspaceAction.moveEarlier,
  OrderSavedWorkspaceAction.moveLater,
  OrderSavedWorkspaceAction.delete,
];

const orderSavedWorkspaceDetailsActionOrder = [
  OrderSavedWorkspaceAction.editNote,
  OrderSavedWorkspaceAction.resetNote,
  OrderSavedWorkspaceAction.rename,
  OrderSavedWorkspaceAction.duplicate,
  OrderSavedWorkspaceAction.togglePin,
  OrderSavedWorkspaceAction.moveEarlier,
  OrderSavedWorkspaceAction.moveLater,
  OrderSavedWorkspaceAction.delete,
];

extension OrderSavedWorkspaceActionKey on OrderSavedWorkspaceAction {
  String get keySuffix {
    return switch (this) {
      OrderSavedWorkspaceAction.details => 'details',
      OrderSavedWorkspaceAction.editNote => 'edit_note',
      OrderSavedWorkspaceAction.resetNote => 'reset_note',
      OrderSavedWorkspaceAction.moveEarlier => 'move_earlier',
      OrderSavedWorkspaceAction.moveLater => 'move_later',
      OrderSavedWorkspaceAction.duplicate => 'duplicate',
      OrderSavedWorkspaceAction.rename => 'rename',
      OrderSavedWorkspaceAction.togglePin => 'pin',
      OrderSavedWorkspaceAction.delete => 'delete',
    };
  }
}

class OrderSavedWorkspaceActionEntry {
  final OrderSavedWorkspaceAction action;
  final bool enabled;

  const OrderSavedWorkspaceActionEntry({
    required this.action,
    this.enabled = true,
  });
}

class OrderSavedWorkspaceActionCapabilities {
  final bool includeDetails;
  final bool canEditNote;
  final bool canResetNote;
  final bool canMove;
  final bool canMoveEarlier;
  final bool canMoveLater;
  final bool canDuplicate;
  final bool canRename;
  final bool canTogglePin;
  final bool canDelete;

  const OrderSavedWorkspaceActionCapabilities({
    this.includeDetails = false,
    this.canEditNote = false,
    this.canResetNote = false,
    this.canMove = false,
    this.canMoveEarlier = false,
    this.canMoveLater = false,
    this.canDuplicate = false,
    this.canRename = false,
    this.canTogglePin = false,
    this.canDelete = false,
  });
}

List<OrderSavedWorkspaceActionEntry> orderSavedWorkspaceActionEntries({
  required OrderSavedWorkspace workspace,
  required List<OrderSavedWorkspaceAction> order,
  OrderSavedWorkspaceActionCapabilities capabilities =
      const OrderSavedWorkspaceActionCapabilities(),
}) {
  final entries = <OrderSavedWorkspaceActionEntry>[];

  for (final action in order) {
    if (!_isSavedWorkspaceActionVisible(
      action: action,
      workspace: workspace,
      capabilities: capabilities,
    )) {
      continue;
    }

    entries.add(
      OrderSavedWorkspaceActionEntry(
        action: action,
        enabled: _isSavedWorkspaceActionEnabled(
          action: action,
          capabilities: capabilities,
        ),
      ),
    );
  }

  return List.unmodifiable(entries);
}

bool _isSavedWorkspaceActionVisible({
  required OrderSavedWorkspaceAction action,
  required OrderSavedWorkspace workspace,
  required OrderSavedWorkspaceActionCapabilities capabilities,
}) {
  return switch (action) {
    OrderSavedWorkspaceAction.details => capabilities.includeDetails,
    OrderSavedWorkspaceAction.editNote => capabilities.canEditNote,
    OrderSavedWorkspaceAction.resetNote =>
      workspace.isDescriptionCustom && capabilities.canResetNote,
    OrderSavedWorkspaceAction.moveEarlier ||
    OrderSavedWorkspaceAction.moveLater => capabilities.canMove,
    OrderSavedWorkspaceAction.duplicate => capabilities.canDuplicate,
    OrderSavedWorkspaceAction.rename => capabilities.canRename,
    OrderSavedWorkspaceAction.togglePin => capabilities.canTogglePin,
    OrderSavedWorkspaceAction.delete => capabilities.canDelete,
  };
}

bool _isSavedWorkspaceActionEnabled({
  required OrderSavedWorkspaceAction action,
  required OrderSavedWorkspaceActionCapabilities capabilities,
}) {
  return switch (action) {
    OrderSavedWorkspaceAction.moveEarlier => capabilities.canMoveEarlier,
    OrderSavedWorkspaceAction.moveLater => capabilities.canMoveLater,
    _ => true,
  };
}
