import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_impact.dart';

void main() {
  test('mode switch impact reports disabled capabilities', () {
    final impact = POSModeSwitchImpact.evaluate(
      currentExperience: defaultPOSExperience,
      targetExperience: quickCheckoutPOSExperience,
    );

    expect(impact.hasChanges, isTrue);
    expect(impact.enabledCount, 0);
    expect(impact.disabledCount, 5);
    expect(impact.summaryLabel, '5 off');
    expect(
      impact.disabledItems.map((item) => item.id),
      containsAll([
        'customer_selection',
        'held_orders',
        'promotions',
        'new_orders',
        'layout_switching',
      ]),
    );
    expect(impact.previewItems().map((item) => item.statusLabel), [
      'Customer off',
      'Holds off',
      'Promos off',
    ]);
  });

  test('mode switch impact hides current and same-feature modes', () {
    final currentImpact = POSModeSwitchImpact.evaluate(
      currentExperience: defaultPOSExperience,
      targetExperience: defaultPOSExperience,
    );
    expect(currentImpact.isCurrentMode, isTrue);
    expect(currentImpact.hasChanges, isFalse);
    expect(currentImpact.summaryLabel, 'Current feature set');

    final sameFeatureMode = defaultPOSExperience.copyWith(
      id: 'same_features',
      label: 'Same Features',
    );
    final sameImpact = POSModeSwitchImpact.evaluate(
      currentExperience: defaultPOSExperience,
      targetExperience: sameFeatureMode,
    );
    expect(sameImpact.isCurrentMode, isFalse);
    expect(sameImpact.hasChanges, isFalse);
    expect(sameImpact.summaryLabel, 'Same feature set');
  });
}
