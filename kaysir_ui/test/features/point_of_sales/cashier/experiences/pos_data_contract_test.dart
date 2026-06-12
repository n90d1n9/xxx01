import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';

void main() {
  test('data contracts resolve required fields for vertical traits', () {
    final contract = POSDataTraitContracts.resolve(
      POSDataTraitKeys.modifierGroups,
    );

    expect(contract, POSDataTraitContracts.modifierGroups);
    expect(contract?.traitLabel, 'Modifier groups');
    expect(contract?.requiredFieldLabels, [
      'Group id',
      'Option id',
      'Price delta',
    ]);
  });

  test('custom contracts can extend built-in data trait coverage', () {
    const contract = POSDataTraitContract(
      traitKey: 'membership',
      requiredFields: [
        POSDataContractField(
          'member_id',
          'Member id',
          'Stable member identifier.',
        ),
      ],
    );

    expect(
      POSDataTraitContracts.resolve(
        'membership',
        extraContracts: const [contract],
      ),
      contract,
    );
    expect(
      POSDataTraitContracts.missingContractLabels(
        ['membership'],
        extraContracts: const [contract],
      ),
      isEmpty,
    );
  });

  test('adapter coverage reports missing required fields', () {
    const adapter = POSDataTraitAdapter(
      id: 'cafe_api',
      label: 'Cafe API',
      fieldsByTrait: {
        POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
      },
    );

    final coverage =
        POSDataTraitContracts.evaluateCoverage(
          traitKeys: const [POSDataTraitKeys.modifierGroups],
          adapters: const [adapter],
        ).single;

    expect(coverage.traitLabel, 'Modifier groups');
    expect(coverage.hasAdapter, isTrue);
    expect(coverage.satisfied, isFalse);
    expect(coverage.missingRequiredFields.map((field) => field.key), [
      'price_delta',
    ]);
    expect(coverage.detail, contains('Price delta'));
  });

  test('adapter coverage can be evaluated as documentation only', () {
    final coverage =
        POSDataTraitContracts.evaluateCoverage(
          traitKeys: const [POSDataTraitKeys.weightedItems],
          requireAdapters: false,
        ).single;

    expect(coverage.hasContract, isTrue);
    expect(coverage.hasAdapter, isFalse);
    expect(coverage.satisfied, isTrue);
    expect(coverage.detail, contains('required fields documented'));
  });
}
