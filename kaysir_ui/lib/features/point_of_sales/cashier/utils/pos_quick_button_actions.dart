import 'package:flutter/foundation.dart';

import '../models/pos_quick_button.dart';

/// Callback registry used by POS quick-button surfaces to dispatch intents.
///
/// The resolver keeps widgets independent from cashier workflows so domain
/// modules can provide only the handlers they actually support.
class POSQuickButtonActionHandlers {
  final ValueChanged<String>? onCommandAction;
  final ValueChanged<String>? onProductSelected;
  final ValueChanged<String>? onCategorySelected;
  final ValueChanged<String>? onDiscountSelected;
  final ValueChanged<String>? onModifierSetSelected;
  final ValueChanged<String>? onCustomerAction;
  final ValueChanged<String>? onLayoutProfileSelected;
  final ValueChanged<POSQuickButtonIntent>? onCustomFlow;

  const POSQuickButtonActionHandlers({
    this.onCommandAction,
    this.onProductSelected,
    this.onCategorySelected,
    this.onDiscountSelected,
    this.onModifierSetSelected,
    this.onCustomerAction,
    this.onLayoutProfileSelected,
    this.onCustomFlow,
  });

  VoidCallback? resolve(POSQuickButton button) {
    if (!button.enabled) return null;

    final intent = button.intent;
    if (!intent.isComplete) return null;

    switch (intent.kind) {
      case POSQuickButtonIntentKind.commandAction:
        return _targetCallback(onCommandAction, intent.targetId);
      case POSQuickButtonIntentKind.product:
        return _targetCallback(onProductSelected, intent.targetId);
      case POSQuickButtonIntentKind.category:
        return _targetCallback(onCategorySelected, intent.targetId);
      case POSQuickButtonIntentKind.discount:
        return _targetCallback(onDiscountSelected, intent.targetId);
      case POSQuickButtonIntentKind.modifierSet:
        return _targetCallback(onModifierSetSelected, intent.targetId);
      case POSQuickButtonIntentKind.customerAction:
        return _targetCallback(onCustomerAction, intent.targetId);
      case POSQuickButtonIntentKind.layoutProfile:
        return _targetCallback(onLayoutProfileSelected, intent.targetId);
      case POSQuickButtonIntentKind.customFlow:
        final handler = onCustomFlow;
        if (handler == null) return null;
        return () => handler(intent);
    }
  }

  bool canHandle(POSQuickButton button) => resolve(button) != null;

  VoidCallback? _targetCallback(
    ValueChanged<String>? handler,
    String targetId,
  ) {
    if (handler == null) return null;
    final normalizedTargetId = targetId.trim();
    if (normalizedTargetId.isEmpty) return null;
    return () => handler(normalizedTargetId);
  }
}
