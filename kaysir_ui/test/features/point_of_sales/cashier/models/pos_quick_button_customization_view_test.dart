import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization_view.dart';

void main() {
  test('customization view resolves pinned hidden and unknown button ids', () {
    final view = POSQuickButtonCustomizationView.fromButtons(
      buttons: _buttons,
      customization: const POSQuickButtonCustomization(
        pinnedButtonIds: ['payment', 'missing_pin'],
        hiddenButtonIds: ['hold', 'missing_hidden'],
      ),
    );

    expect(view.pinnedButtons.map((button) => button.id), ['payment']);
    expect(view.hiddenButtons.map((button) => button.id), ['hold']);
    expect(view.unknownPinnedButtonIds, ['missing_pin']);
    expect(view.unknownHiddenButtonIds, ['missing_hidden']);
    expect(view.visibleButtons.map((button) => button.id), ['payment', 'scan']);
    expect(view.hasCustomization, isTrue);
    expect(view.pinnedCount, 2);
    expect(view.hiddenCount, 2);
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
