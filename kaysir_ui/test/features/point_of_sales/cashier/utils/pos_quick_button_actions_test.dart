import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_quick_button_actions.dart';

void main() {
  test('quick button action handlers resolve supported intent callbacks', () {
    String? selectedCategory;
    final handlers = POSQuickButtonActionHandlers(
      onCategorySelected: (categoryId) => selectedCategory = categoryId,
    );
    const button = POSQuickButton(
      id: 'coffee_espresso',
      label: 'Espresso',
      description: 'Open espresso drinks.',
      intent: POSQuickButtonIntent.category('espresso'),
      surface: POSQuickButtonSurface.primaryGrid,
    );

    final callback = handlers.resolve(button);
    callback?.call();

    expect(selectedCategory, 'espresso');
    expect(handlers.canHandle(button), isTrue);
  });

  test('quick button action handlers leave unsupported intents disabled', () {
    const handlers = POSQuickButtonActionHandlers();
    const button = POSQuickButton(
      id: 'weigh_item',
      label: 'Weigh',
      description: 'Start weighing flow.',
      intent: POSQuickButtonIntent.customFlow(targetId: 'weigh_item'),
      surface: POSQuickButtonSurface.primaryGrid,
    );

    expect(handlers.resolve(button), isNull);
    expect(handlers.canHandle(button), isFalse);
  });
}
