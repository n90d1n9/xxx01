import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';

void main() {
  test('quick button customization pins buttons before preset order', () {
    const customization = POSQuickButtonCustomization(
      pinnedButtonIds: ['payment'],
    );

    final arranged = customization.applyTo(_buttons);

    expect(arranged.map((button) => button.id), ['payment', 'scan', 'hold']);
  });

  test('quick button customization hides and unpins buttons', () {
    const customization = POSQuickButtonCustomization(
      pinnedButtonIds: ['hold'],
    );

    final hidden = customization.toggleHidden('hold');

    expect(hidden.isHidden('hold'), isTrue);
    expect(hidden.isPinned('hold'), isFalse);
    expect(hidden.applyTo(_buttons).map((button) => button.id), [
      'scan',
      'payment',
    ]);
  });

  test('quick button customization moves pinned shortcuts in order', () {
    const customization = POSQuickButtonCustomization(
      pinnedButtonIds: ['scan', 'hold', 'payment'],
    );

    final movedDown = customization.movePinned('scan', 1);
    expect(movedDown.pinnedButtonIds, ['hold', 'scan', 'payment']);

    final movedUp = movedDown.movePinned('payment', -1);
    expect(movedUp.pinnedButtonIds, ['hold', 'payment', 'scan']);

    expect(movedUp.movePinned('missing', 1), same(movedUp));
    expect(movedUp.movePinned('hold', -1).pinnedButtonIds, [
      'hold',
      'payment',
      'scan',
    ]);
  });

  test('quick button customization can reset to empty state', () {
    const customization = POSQuickButtonCustomization(
      hiddenButtonIds: ['scan'],
      pinnedButtonIds: ['payment'],
    );

    expect(customization.isEmpty, isFalse);
    expect(customization.reset().isEmpty, isTrue);
  });

  test('quick button customization serializes normalized operator choices', () {
    final customization = POSQuickButtonCustomization.fromJson({
      'hiddenButtonIds': [' scan ', 'scan', ''],
      'pinnedButtonIds': ['payment', 'scan', ' payment '],
      'densityOverride': 'spacious',
    });

    expect(customization.hiddenButtonIds, ['scan']);
    expect(customization.pinnedButtonIds, ['payment']);
    expect(customization.densityOverride, POSTouchLayoutDensity.spacious);
    expect(customization.toJson(), {
      'hiddenButtonIds': ['scan'],
      'pinnedButtonIds': ['payment'],
      'densityOverride': 'spacious',
    });
  });

  test('quick button customization resolves profile density override', () {
    const customization = POSQuickButtonCustomization(
      densityOverride: POSTouchLayoutDensity.kiosk,
    );

    expect(
      customization.effectiveDensityFor(POSTouchLayoutDensity.comfortable),
      POSTouchLayoutDensity.kiosk,
    );
    expect(
      customization
          .withDensityOverride(null)
          .effectiveDensityFor(POSTouchLayoutDensity.comfortable),
      POSTouchLayoutDensity.comfortable,
    );
  });
}

const _buttons = [
  POSQuickButton(
    id: 'scan',
    label: 'Scan',
    description: 'Scan item.',
    intent: POSQuickButtonIntent.commandAction('scan'),
    surface: POSQuickButtonSurface.commandBar,
  ),
  POSQuickButton(
    id: 'hold',
    label: 'Hold',
    description: 'Hold order.',
    intent: POSQuickButtonIntent.commandAction('hold_order'),
    surface: POSQuickButtonSurface.commandBar,
  ),
  POSQuickButton(
    id: 'payment',
    label: 'Pay',
    description: 'Open payment.',
    intent: POSQuickButtonIntent.commandAction('payment'),
    surface: POSQuickButtonSurface.commandBar,
  ),
];
