import 'package:flutter/material.dart';

import '../experiences/pos_experience_action_policy.dart';
import '../widgets/pos_ui.dart';
import 'pos_shell_shortcuts.dart';

enum POSCommandActionIntent {
  scan,
  startNewOrder,
  holdOrder,
  openHeldOrders,
  promotions,
  payment,
}

enum POSCommandActionRegistryIssueType {
  blankActionId,
  blankActionLabel,
  duplicateActionId,
  duplicateShortcut,
}

class POSCommandActionRegistryIssue {
  final POSCommandActionRegistryIssueType type;
  final String actionId;
  final String message;

  const POSCommandActionRegistryIssue({
    required this.type,
    required this.actionId,
    required this.message,
  });

  @override
  String toString() => message;
}

class POSCommandActionSpec {
  final String id;
  final String label;
  final IconData icon;
  final POSCommandActionIntent intent;
  final POSExperienceAction requiredAction;
  final POSActionButtonVariant variant;
  final bool requiresOrderItems;
  final bool showsHeldOrderCount;
  final ShortcutActivator? shortcutActivator;
  final String? emptyOrderDisabledReason;

  const POSCommandActionSpec({
    required this.id,
    required this.label,
    required this.icon,
    required this.intent,
    required this.requiredAction,
    this.variant = POSActionButtonVariant.outlined,
    this.requiresOrderItems = false,
    this.showsHeldOrderCount = false,
    this.shortcutActivator,
    this.emptyOrderDisabledReason,
  });

  bool isVisible(POSExperienceActionPolicy policy) {
    return policy.allows(requiredAction);
  }

  bool isEnabled({
    required POSExperienceActionPolicy policy,
    required int itemCount,
  }) {
    return isVisible(policy) && (!requiresOrderItems || itemCount > 0);
  }

  String? disabledReason({required int itemCount}) {
    if (requiresOrderItems && itemCount <= 0) {
      return emptyOrderDisabledReason ??
          'Add items to the order before using this action.';
    }

    return null;
  }

  String get tooltipLabel {
    final shortcut = shortcutActivator;
    if (shortcut == null) return label;

    return '$label (${formatPOSShellShortcutActivator(shortcut)})';
  }

  String tooltipLabelFor({String? disabledReason}) {
    final reason = disabledReason?.trim();
    if (reason == null || reason.isEmpty) return tooltipLabel;

    return '$tooltipLabel - $reason';
  }
}

class POSResolvedCommandAction {
  final POSCommandActionSpec spec;
  final VoidCallback? onPressed;
  final int heldOrderCount;
  final String? disabledReason;
  final String tooltipLabel;

  const POSResolvedCommandAction({
    required this.spec,
    required this.onPressed,
    required this.heldOrderCount,
    required this.disabledReason,
    required this.tooltipLabel,
  });

  bool get isEnabled => onPressed != null;
}

class POSCommandActionHandlers {
  final VoidCallback onScan;
  final VoidCallback onStartNewOrder;
  final VoidCallback onHoldOrder;
  final VoidCallback onOpenHeldOrders;
  final VoidCallback onPromotions;
  final VoidCallback onPayment;

  const POSCommandActionHandlers({
    required this.onScan,
    required this.onStartNewOrder,
    required this.onHoldOrder,
    required this.onOpenHeldOrders,
    required this.onPromotions,
    required this.onPayment,
  });

  VoidCallback resolve(POSCommandActionIntent intent) {
    switch (intent) {
      case POSCommandActionIntent.scan:
        return onScan;
      case POSCommandActionIntent.startNewOrder:
        return onStartNewOrder;
      case POSCommandActionIntent.holdOrder:
        return onHoldOrder;
      case POSCommandActionIntent.openHeldOrders:
        return onOpenHeldOrders;
      case POSCommandActionIntent.promotions:
        return onPromotions;
      case POSCommandActionIntent.payment:
        return onPayment;
    }
  }
}

class POSCommandActionRegistry {
  final List<POSCommandActionSpec> specs;

  const POSCommandActionRegistry({this.specs = defaultSpecs});

  static const defaultSpecs = [
    POSCommandActionSpec(
      id: 'scan',
      label: 'Scan',
      icon: Icons.qr_code_scanner,
      intent: POSCommandActionIntent.scan,
      requiredAction: POSExperienceAction.barcodeScanning,
      shortcutActivator: POSShellShortcutActivators.scan,
    ),
    POSCommandActionSpec(
      id: 'new_order',
      label: 'New',
      icon: Icons.add_shopping_cart,
      intent: POSCommandActionIntent.startNewOrder,
      requiredAction: POSExperienceAction.newOrders,
      shortcutActivator: POSShellShortcutActivators.startNewOrder,
    ),
    POSCommandActionSpec(
      id: 'hold_order',
      label: 'Hold',
      icon: Icons.pause_circle_outline,
      intent: POSCommandActionIntent.holdOrder,
      requiredAction: POSExperienceAction.heldOrders,
      requiresOrderItems: true,
      emptyOrderDisabledReason: 'Add items to the order before holding it.',
      shortcutActivator: POSShellShortcutActivators.holdOrder,
    ),
    POSCommandActionSpec(
      id: 'open_held_orders',
      label: 'Holds',
      icon: Icons.bookmark_border,
      intent: POSCommandActionIntent.openHeldOrders,
      requiredAction: POSExperienceAction.heldOrders,
      variant: POSActionButtonVariant.tonal,
      showsHeldOrderCount: true,
      shortcutActivator: POSShellShortcutActivators.openHeldOrders,
    ),
    POSCommandActionSpec(
      id: 'promotions',
      label: 'Promo',
      icon: Icons.discount_outlined,
      intent: POSCommandActionIntent.promotions,
      requiredAction: POSExperienceAction.promotions,
      variant: POSActionButtonVariant.tonal,
    ),
    POSCommandActionSpec(
      id: 'payment',
      label: 'Pay',
      icon: Icons.payments_outlined,
      intent: POSCommandActionIntent.payment,
      requiredAction: POSExperienceAction.payments,
      variant: POSActionButtonVariant.filled,
      shortcutActivator: POSShellShortcutActivators.openPayment,
    ),
  ];

  List<POSCommandActionSpec> visibleSpecs(POSExperienceActionPolicy policy) {
    return specs.where((spec) => spec.isVisible(policy)).toList();
  }

  List<POSCommandActionRegistryIssue> validate() {
    final issues = <POSCommandActionRegistryIssue>[];
    final idCounts = <String, int>{};
    final shortcutCounts = <String, int>{};

    for (final spec in specs) {
      final id = spec.id.trim();
      if (id.isNotEmpty) idCounts[id] = (idCounts[id] ?? 0) + 1;

      final shortcut = spec.shortcutActivator;
      if (shortcut != null) {
        final shortcutLabel = formatPOSShellShortcutActivator(shortcut);
        shortcutCounts[shortcutLabel] =
            (shortcutCounts[shortcutLabel] ?? 0) + 1;
      }
    }

    for (final spec in specs) {
      final id = spec.id.trim();
      if (id.isEmpty) {
        issues.add(
          POSCommandActionRegistryIssue(
            type: POSCommandActionRegistryIssueType.blankActionId,
            actionId: spec.id,
            message: 'POS command action id cannot be blank.',
          ),
        );
      }

      if (spec.label.trim().isEmpty) {
        issues.add(
          POSCommandActionRegistryIssue(
            type: POSCommandActionRegistryIssueType.blankActionLabel,
            actionId: spec.id,
            message: 'POS command action "$id" label cannot be blank.',
          ),
        );
      }
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSCommandActionRegistryIssue(
          type: POSCommandActionRegistryIssueType.duplicateActionId,
          actionId: entry.key,
          message: 'Duplicate POS command action id "${entry.key}" found.',
        ),
      );
    }

    for (final entry in shortcutCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSCommandActionRegistryIssue(
          type: POSCommandActionRegistryIssueType.duplicateShortcut,
          actionId: entry.key,
          message: 'Duplicate POS command shortcut "${entry.key}" found.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(issues.map((issue) => issue.message).join('\n'));
  }

  List<POSResolvedCommandAction> resolve({
    required POSExperienceActionPolicy policy,
    required int itemCount,
    required int heldOrderCount,
    required POSCommandActionHandlers handlers,
  }) {
    return [
      for (final spec in visibleSpecs(policy))
        _resolveAction(
          spec: spec,
          policy: policy,
          itemCount: itemCount,
          heldOrderCount: heldOrderCount,
          handlers: handlers,
        ),
    ];
  }

  POSResolvedCommandAction _resolveAction({
    required POSCommandActionSpec spec,
    required POSExperienceActionPolicy policy,
    required int itemCount,
    required int heldOrderCount,
    required POSCommandActionHandlers handlers,
  }) {
    final isEnabled = spec.isEnabled(policy: policy, itemCount: itemCount);
    final disabledReason =
        isEnabled ? null : spec.disabledReason(itemCount: itemCount);

    return POSResolvedCommandAction(
      spec: spec,
      heldOrderCount: heldOrderCount,
      disabledReason: disabledReason,
      tooltipLabel: spec.tooltipLabelFor(disabledReason: disabledReason),
      onPressed: isEnabled ? handlers.resolve(spec.intent) : null,
    );
  }
}

const defaultPOSCommandActionRegistry = POSCommandActionRegistry();
