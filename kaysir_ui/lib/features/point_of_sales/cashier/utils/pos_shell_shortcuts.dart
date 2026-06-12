import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../experiences/pos_experience_action_policy.dart';
import '../states/pos_layout_provider.dart';

enum POSShellShortcutIntent {
  focusSearch,
  scan,
  holdOrder,
  openHeldOrders,
  openPayment,
  startNewOrder,
  autoLayout,
  counterLayout,
  compactLayout,
  checkoutLayout,
}

enum POSShellShortcutRegistryIssueType {
  blankShortcutId,
  blankShortcutLabel,
  duplicateShortcutId,
  duplicateShortcutActivator,
}

class POSShellShortcutRegistryIssue {
  final POSShellShortcutRegistryIssueType type;
  final String shortcutId;
  final String message;

  const POSShellShortcutRegistryIssue({
    required this.type,
    required this.shortcutId,
    required this.message,
  });

  @override
  String toString() => message;
}

class POSShellShortcutSpec {
  final String id;
  final String label;
  final ShortcutActivator activator;
  final POSShellShortcutIntent intent;
  final POSExperienceAction? requiredAction;

  const POSShellShortcutSpec({
    required this.id,
    required this.label,
    required this.activator,
    required this.intent,
    this.requiredAction,
  });

  bool isEnabled(POSExperienceActionPolicy policy) {
    final action = requiredAction;
    return action == null || policy.allows(action);
  }
}

String formatPOSShellShortcutActivator(ShortcutActivator activator) {
  if (activator is! SingleActivator) return activator.toString();

  final parts = [
    if (activator.control) 'Ctrl',
    if (activator.alt) 'Alt',
    if (activator.shift) 'Shift',
    if (activator.meta) 'Meta',
    _formatLogicalKeyboardKey(activator.trigger),
  ];

  return parts.join('+');
}

String _formatLogicalKeyboardKey(LogicalKeyboardKey key) {
  final label = key.keyLabel.trim();
  if (label.isNotEmpty) return label.toUpperCase();

  if (key == LogicalKeyboardKey.space) return 'Space';
  if (key == LogicalKeyboardKey.enter) return 'Enter';
  if (key == LogicalKeyboardKey.escape) return 'Esc';

  return key.debugName ?? key.keyId.toRadixString(16).toUpperCase();
}

class POSShellShortcutHandlers {
  final VoidCallback onFocusSearch;
  final VoidCallback onScan;
  final VoidCallback onHoldOrder;
  final VoidCallback onOpenHeldOrders;
  final VoidCallback onOpenPayment;
  final VoidCallback onStartNewOrder;
  final ValueChanged<POSLayoutPreference> onLayoutChanged;

  const POSShellShortcutHandlers({
    required this.onFocusSearch,
    required this.onScan,
    required this.onHoldOrder,
    required this.onOpenHeldOrders,
    required this.onOpenPayment,
    required this.onStartNewOrder,
    required this.onLayoutChanged,
  });

  VoidCallback resolve(POSShellShortcutIntent intent) {
    switch (intent) {
      case POSShellShortcutIntent.focusSearch:
        return onFocusSearch;
      case POSShellShortcutIntent.scan:
        return onScan;
      case POSShellShortcutIntent.holdOrder:
        return onHoldOrder;
      case POSShellShortcutIntent.openHeldOrders:
        return onOpenHeldOrders;
      case POSShellShortcutIntent.openPayment:
        return onOpenPayment;
      case POSShellShortcutIntent.startNewOrder:
        return onStartNewOrder;
      case POSShellShortcutIntent.autoLayout:
        return () => onLayoutChanged(POSLayoutPreference.auto);
      case POSShellShortcutIntent.counterLayout:
        return () => onLayoutChanged(POSLayoutPreference.counter);
      case POSShellShortcutIntent.compactLayout:
        return () => onLayoutChanged(POSLayoutPreference.compact);
      case POSShellShortcutIntent.checkoutLayout:
        return () => onLayoutChanged(POSLayoutPreference.checkout);
    }
  }
}

abstract final class POSShellShortcutActivators {
  static const focusSearch = SingleActivator(LogicalKeyboardKey.f2);
  static const scan = SingleActivator(LogicalKeyboardKey.f4);
  static const holdOrder = SingleActivator(LogicalKeyboardKey.f6);
  static const openHeldOrders = SingleActivator(LogicalKeyboardKey.f7);
  static const openPayment = SingleActivator(LogicalKeyboardKey.f9);
  static const startNewOrder = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: true,
  );
  static const autoLayout = SingleActivator(
    LogicalKeyboardKey.digit0,
    control: true,
  );
  static const counterLayout = SingleActivator(
    LogicalKeyboardKey.digit1,
    control: true,
  );
  static const compactLayout = SingleActivator(
    LogicalKeyboardKey.digit2,
    control: true,
  );
  static const checkoutLayout = SingleActivator(
    LogicalKeyboardKey.digit3,
    control: true,
  );
}

class POSShellShortcutRegistry {
  final List<POSShellShortcutSpec> specs;

  const POSShellShortcutRegistry({this.specs = defaultSpecs});

  static const defaultSpecs = [
    POSShellShortcutSpec(
      id: 'focus_search',
      label: 'Focus product search',
      activator: POSShellShortcutActivators.focusSearch,
      intent: POSShellShortcutIntent.focusSearch,
    ),
    POSShellShortcutSpec(
      id: 'scan',
      label: 'Scan or enter barcode/SKU',
      activator: POSShellShortcutActivators.scan,
      intent: POSShellShortcutIntent.scan,
      requiredAction: POSExperienceAction.barcodeScanning,
    ),
    POSShellShortcutSpec(
      id: 'hold_order',
      label: 'Hold the current order',
      activator: POSShellShortcutActivators.holdOrder,
      intent: POSShellShortcutIntent.holdOrder,
      requiredAction: POSExperienceAction.heldOrders,
    ),
    POSShellShortcutSpec(
      id: 'open_held_orders',
      label: 'Open held orders',
      activator: POSShellShortcutActivators.openHeldOrders,
      intent: POSShellShortcutIntent.openHeldOrders,
      requiredAction: POSExperienceAction.heldOrders,
    ),
    POSShellShortcutSpec(
      id: 'open_payment',
      label: 'Open payment',
      activator: POSShellShortcutActivators.openPayment,
      intent: POSShellShortcutIntent.openPayment,
      requiredAction: POSExperienceAction.payments,
    ),
    POSShellShortcutSpec(
      id: 'start_new_order',
      label: 'Start a new order',
      activator: POSShellShortcutActivators.startNewOrder,
      intent: POSShellShortcutIntent.startNewOrder,
      requiredAction: POSExperienceAction.newOrders,
    ),
    POSShellShortcutSpec(
      id: 'auto_layout',
      label: 'Auto layout',
      activator: POSShellShortcutActivators.autoLayout,
      intent: POSShellShortcutIntent.autoLayout,
      requiredAction: POSExperienceAction.layoutSwitching,
    ),
    POSShellShortcutSpec(
      id: 'counter_layout',
      label: 'Counter layout',
      activator: POSShellShortcutActivators.counterLayout,
      intent: POSShellShortcutIntent.counterLayout,
      requiredAction: POSExperienceAction.layoutSwitching,
    ),
    POSShellShortcutSpec(
      id: 'compact_layout',
      label: 'Compact layout',
      activator: POSShellShortcutActivators.compactLayout,
      intent: POSShellShortcutIntent.compactLayout,
      requiredAction: POSExperienceAction.layoutSwitching,
    ),
    POSShellShortcutSpec(
      id: 'checkout_layout',
      label: 'Checkout layout',
      activator: POSShellShortcutActivators.checkoutLayout,
      intent: POSShellShortcutIntent.checkoutLayout,
      requiredAction: POSExperienceAction.layoutSwitching,
    ),
  ];

  List<POSShellShortcutSpec> enabledSpecs(POSExperienceActionPolicy policy) {
    return specs.where((spec) => spec.isEnabled(policy)).toList();
  }

  List<POSShellShortcutRegistryIssue> validate() {
    final issues = <POSShellShortcutRegistryIssue>[];
    final idCounts = <String, int>{};
    final activatorCounts = <String, int>{};

    for (final spec in specs) {
      final id = spec.id.trim();
      if (id.isNotEmpty) idCounts[id] = (idCounts[id] ?? 0) + 1;

      final activatorLabel = formatPOSShellShortcutActivator(spec.activator);
      activatorCounts[activatorLabel] =
          (activatorCounts[activatorLabel] ?? 0) + 1;
    }

    for (final spec in specs) {
      final id = spec.id.trim();
      if (id.isEmpty) {
        issues.add(
          POSShellShortcutRegistryIssue(
            type: POSShellShortcutRegistryIssueType.blankShortcutId,
            shortcutId: spec.id,
            message: 'POS shell shortcut id cannot be blank.',
          ),
        );
      }

      if (spec.label.trim().isEmpty) {
        issues.add(
          POSShellShortcutRegistryIssue(
            type: POSShellShortcutRegistryIssueType.blankShortcutLabel,
            shortcutId: spec.id,
            message: 'POS shell shortcut "$id" label cannot be blank.',
          ),
        );
      }
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSShellShortcutRegistryIssue(
          type: POSShellShortcutRegistryIssueType.duplicateShortcutId,
          shortcutId: entry.key,
          message: 'Duplicate POS shell shortcut id "${entry.key}" found.',
        ),
      );
    }

    for (final entry in activatorCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSShellShortcutRegistryIssue(
          type: POSShellShortcutRegistryIssueType.duplicateShortcutActivator,
          shortcutId: entry.key,
          message: 'Duplicate POS shell shortcut binding "${entry.key}" found.',
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

  Map<ShortcutActivator, VoidCallback> resolve({
    required POSExperienceActionPolicy policy,
    required POSShellShortcutHandlers handlers,
  }) {
    return {
      for (final spec in enabledSpecs(policy))
        spec.activator: handlers.resolve(spec.intent),
    };
  }
}

const defaultPOSShellShortcutRegistry = POSShellShortcutRegistry();
