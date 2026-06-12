import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';

void main() {
  test('data trait registry resolves stable vertical trait keys', () {
    expect(
      POSDataTraits.resolve(POSDataTraitKeys.modifierGroups),
      POSDataTraits.modifierGroups,
    );
    expect(
      POSDataTraits.resolve(POSDataTraitKeys.weightedItems)?.area,
      POSDataTraitArea.inventory,
    );
    expect(POSDataTraits.isKnown(POSDataTraitKeys.serialTracked), isTrue);
  });

  test('data trait labels turn keys into operator-friendly names', () {
    expect(
      POSDataTraits.labelFor(POSDataTraitKeys.modifierGroups),
      'Modifier groups',
    );
    expect(POSDataTraits.labelFor('custom_trait'), 'Custom Trait');
    expect(
      POSDataTraits.labelsFor([
        POSDataTraitKeys.catalog,
        POSDataTraitKeys.tableService,
        POSDataTraitKeys.deposits,
      ]),
      ['Catalog', 'Table service', 'Deposits'],
    );
  });

  test('data trait helpers expose keys for manifest declarations', () {
    expect(
      POSDataTraits.keysOf([
        POSDataTraits.menu,
        POSDataTraits.modifierGroups,
        POSDataTraits.payments,
      ]),
      [
        POSDataTraitKeys.menu,
        POSDataTraitKeys.modifierGroups,
        POSDataTraitKeys.payments,
      ],
    );
  });
}
