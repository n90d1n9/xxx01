import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_shell_shortcuts.dart';

void main() {
  test('shortcut formatter keeps operator-facing key labels compact', () {
    expect(
      formatPOSShellShortcutActivator(POSShellShortcutActivators.scan),
      'F4',
    );
    expect(
      formatPOSShellShortcutActivator(POSShellShortcutActivators.startNewOrder),
      'Ctrl+N',
    );
  });

  test('registry exposes every standard cashier shortcut', () {
    final policy = POSExperienceActionPolicy(experience: defaultPOSExperience);

    final specs = defaultPOSShellShortcutRegistry.enabledSpecs(policy);

    expect(specs.map((spec) => spec.id), [
      'focus_search',
      'scan',
      'hold_order',
      'open_held_orders',
      'open_payment',
      'start_new_order',
      'auto_layout',
      'counter_layout',
      'compact_layout',
      'checkout_layout',
    ]);
  });

  test('default shortcut registry validates cleanly', () {
    expect(defaultPOSShellShortcutRegistry.validate(), isEmpty);
    expect(defaultPOSShellShortcutRegistry.throwIfInvalid, returnsNormally);
  });

  test('registry reports extension shortcut metadata mistakes', () {
    final registry = POSShellShortcutRegistry(
      specs: const [
        POSShellShortcutSpec(
          id: ' ',
          label: ' ',
          activator: POSShellShortcutActivators.scan,
          intent: POSShellShortcutIntent.scan,
        ),
        POSShellShortcutSpec(
          id: 'duplicate',
          label: 'Duplicate A',
          activator: POSShellShortcutActivators.holdOrder,
          intent: POSShellShortcutIntent.holdOrder,
        ),
        POSShellShortcutSpec(
          id: 'duplicate',
          label: 'Duplicate B',
          activator: POSShellShortcutActivators.holdOrder,
          intent: POSShellShortcutIntent.openHeldOrders,
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSShellShortcutRegistryIssueType.blankShortcutId,
        POSShellShortcutRegistryIssueType.blankShortcutLabel,
        POSShellShortcutRegistryIssueType.duplicateShortcutId,
        POSShellShortcutRegistryIssueType.duplicateShortcutActivator,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('registry removes shortcuts for disabled experience capabilities', () {
    final policy = POSExperienceActionPolicy(
      experience: quickCheckoutPOSExperience,
    );

    final bindings = defaultPOSShellShortcutRegistry.resolve(
      policy: policy,
      handlers: _noopHandlers(),
    );

    expect(bindings, contains(POSShellShortcutActivators.focusSearch));
    expect(bindings, contains(POSShellShortcutActivators.scan));
    expect(bindings, contains(POSShellShortcutActivators.openPayment));
    expect(bindings, isNot(contains(POSShellShortcutActivators.holdOrder)));
    expect(
      bindings,
      isNot(contains(POSShellShortcutActivators.openHeldOrders)),
    );
    expect(bindings, isNot(contains(POSShellShortcutActivators.startNewOrder)));
    expect(bindings, isNot(contains(POSShellShortcutActivators.autoLayout)));
  });

  test(
    'registry resolves layout shortcuts through the shared layout handler',
    () {
      final policy = POSExperienceActionPolicy(
        experience: defaultPOSExperience,
      );
      final selectedLayouts = <POSLayoutPreference>[];

      final bindings = defaultPOSShellShortcutRegistry.resolve(
        policy: policy,
        handlers: _noopHandlers(onLayoutChanged: selectedLayouts.add),
      );

      bindings[POSShellShortcutActivators.checkoutLayout]?.call();

      expect(selectedLayouts, [POSLayoutPreference.checkout]);
    },
  );

  test('registry dispatches operational shortcuts to their handlers', () {
    final policy = POSExperienceActionPolicy(experience: defaultPOSExperience);
    final invoked = <String>[];

    final bindings = defaultPOSShellShortcutRegistry.resolve(
      policy: policy,
      handlers: _noopHandlers(
        onFocusSearch: () => invoked.add('search'),
        onScan: () => invoked.add('scan'),
        onOpenPayment: () => invoked.add('payment'),
      ),
    );

    bindings[POSShellShortcutActivators.focusSearch]?.call();
    bindings[POSShellShortcutActivators.scan]?.call();
    bindings[POSShellShortcutActivators.openPayment]?.call();

    expect(invoked, ['search', 'scan', 'payment']);
  });
}

POSShellShortcutHandlers _noopHandlers({
  void Function()? onFocusSearch,
  void Function()? onScan,
  void Function()? onHoldOrder,
  void Function()? onOpenHeldOrders,
  void Function()? onOpenPayment,
  void Function()? onStartNewOrder,
  void Function(POSLayoutPreference)? onLayoutChanged,
}) {
  return POSShellShortcutHandlers(
    onFocusSearch: onFocusSearch ?? () {},
    onScan: onScan ?? () {},
    onHoldOrder: onHoldOrder ?? () {},
    onOpenHeldOrders: onOpenHeldOrders ?? () {},
    onOpenPayment: onOpenPayment ?? () {},
    onStartNewOrder: onStartNewOrder ?? () {},
    onLayoutChanged: onLayoutChanged ?? (_) {},
  );
}
