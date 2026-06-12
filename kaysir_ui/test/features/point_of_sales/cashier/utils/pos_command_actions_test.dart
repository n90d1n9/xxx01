import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_action_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_actions.dart';

void main() {
  test('registry exposes the standard cashier command action order', () {
    final policy = POSExperienceActionPolicy(experience: defaultPOSExperience);

    final specs = defaultPOSCommandActionRegistry.visibleSpecs(policy);

    expect(specs.map((spec) => spec.id), [
      'scan',
      'new_order',
      'hold_order',
      'open_held_orders',
      'promotions',
      'payment',
    ]);
  });

  test('registry exposes shortcut-aware operator tooltip labels', () {
    final policy = POSExperienceActionPolicy(experience: defaultPOSExperience);

    final specs = defaultPOSCommandActionRegistry.visibleSpecs(policy);

    expect(specs.map((spec) => spec.tooltipLabel), [
      'Scan (F4)',
      'New (Ctrl+N)',
      'Hold (F6)',
      'Holds (F7)',
      'Promo',
      'Pay (F9)',
    ]);
  });

  test('default command action registry validates cleanly', () {
    expect(defaultPOSCommandActionRegistry.validate(), isEmpty);
    expect(defaultPOSCommandActionRegistry.throwIfInvalid, returnsNormally);
  });

  test('registry reports extension metadata mistakes', () {
    final registry = POSCommandActionRegistry(
      specs: const [
        POSCommandActionSpec(
          id: ' ',
          label: ' ',
          icon: Icons.warning_amber_outlined,
          intent: POSCommandActionIntent.scan,
          requiredAction: POSExperienceAction.barcodeScanning,
          shortcutActivator: SingleActivator(LogicalKeyboardKey.f4),
        ),
        POSCommandActionSpec(
          id: 'duplicate',
          label: 'Duplicate A',
          icon: Icons.qr_code_scanner,
          intent: POSCommandActionIntent.scan,
          requiredAction: POSExperienceAction.barcodeScanning,
          shortcutActivator: SingleActivator(LogicalKeyboardKey.f6),
        ),
        POSCommandActionSpec(
          id: 'duplicate',
          label: 'Duplicate B',
          icon: Icons.payments_outlined,
          intent: POSCommandActionIntent.payment,
          requiredAction: POSExperienceAction.payments,
          shortcutActivator: SingleActivator(LogicalKeyboardKey.f6),
        ),
      ],
    );

    final issueTypes = registry.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSCommandActionRegistryIssueType.blankActionId,
        POSCommandActionRegistryIssueType.blankActionLabel,
        POSCommandActionRegistryIssueType.duplicateActionId,
        POSCommandActionRegistryIssueType.duplicateShortcut,
      ]),
    );
    expect(registry.throwIfInvalid, throwsStateError);
  });

  test('registry removes actions disabled by a vertical POS mode', () {
    final policy = POSExperienceActionPolicy(
      experience: quickCheckoutPOSExperience,
    );

    final specs = defaultPOSCommandActionRegistry.visibleSpecs(policy);

    expect(specs.map((spec) => spec.id), ['scan', 'payment']);
  });

  test('registry removes channel-restricted actions', () {
    final marketplace = defaultPOSCommerceChannelRegistry.channelForId(
      'marketplace',
    );
    final policy = POSExperienceActionPolicy(
      experience: defaultPOSExperience,
      commerceChannel: marketplace,
    );

    final specs = defaultPOSCommandActionRegistry.visibleSpecs(policy);

    expect(specs.map((spec) => spec.id), [
      'scan',
      'new_order',
      'hold_order',
      'open_held_orders',
    ]);
  });

  test(
    'registry keeps hold visible but disabled until the order has items',
    () {
      final policy = POSExperienceActionPolicy(
        experience: defaultPOSExperience,
      );
      final invoked = <String>[];

      final emptyOrderActions = defaultPOSCommandActionRegistry.resolve(
        policy: policy,
        itemCount: 0,
        heldOrderCount: 0,
        handlers: _handlers(onHoldOrder: () => invoked.add('hold')),
      );
      final filledOrderActions = defaultPOSCommandActionRegistry.resolve(
        policy: policy,
        itemCount: 1,
        heldOrderCount: 0,
        handlers: _handlers(onHoldOrder: () => invoked.add('hold')),
      );

      final emptyHold = emptyOrderActions.singleWhere(
        (action) => action.spec.id == 'hold_order',
      );
      final filledHold = filledOrderActions.singleWhere(
        (action) => action.spec.id == 'hold_order',
      );

      expect(emptyHold.onPressed, isNull);
      expect(
        emptyHold.disabledReason,
        'Add items to the order before holding it.',
      );
      expect(
        emptyHold.tooltipLabel,
        'Hold (F6) - Add items to the order before holding it.',
      );

      filledHold.onPressed?.call();
      expect(invoked, ['hold']);
    },
  );

  test('registry dispatches actions through their shared handlers', () {
    final policy = POSExperienceActionPolicy(experience: defaultPOSExperience);
    final invoked = <String>[];

    final actions = defaultPOSCommandActionRegistry.resolve(
      policy: policy,
      itemCount: 1,
      heldOrderCount: 2,
      handlers: _handlers(
        onScan: () => invoked.add('scan'),
        onPayment: () => invoked.add('payment'),
      ),
    );

    actions.singleWhere((action) => action.spec.id == 'scan').onPressed?.call();
    actions
        .singleWhere((action) => action.spec.id == 'payment')
        .onPressed
        ?.call();

    expect(invoked, ['scan', 'payment']);
    expect(
      actions
          .singleWhere((action) => action.spec.id == 'open_held_orders')
          .heldOrderCount,
      2,
    );
  });
}

POSCommandActionHandlers _handlers({
  void Function()? onScan,
  void Function()? onStartNewOrder,
  void Function()? onHoldOrder,
  void Function()? onOpenHeldOrders,
  void Function()? onPromotions,
  void Function()? onPayment,
}) {
  return POSCommandActionHandlers(
    onScan: onScan ?? () {},
    onStartNewOrder: onStartNewOrder ?? () {},
    onHoldOrder: onHoldOrder ?? () {},
    onOpenHeldOrders: onOpenHeldOrders ?? () {},
    onPromotions: onPromotions ?? () {},
    onPayment: onPayment ?? () {},
  );
}
