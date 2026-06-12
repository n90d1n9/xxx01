import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/utils/inventory_form_utils.dart';

void main() {
  test('parseInventoryInteger trims and parses whole numbers', () {
    expect(parseInventoryInteger(' 12 '), 12);
    expect(parseInventoryInteger(''), isNull);
    expect(parseInventoryInteger('1.5'), isNull);
    expect(parseInventoryInteger(null), isNull);
  });

  test('decimal parsers trim values and reject non-finite numbers', () {
    expect(parseInventoryDecimal(' 12.50 '), 12.5);
    expect(parseInventoryNumber(' 42 '), 42);
    expect(parseInventoryDecimal('NaN'), isNull);
    expect(parseInventoryNumber('Infinity'), isNull);
    expect(parseInventoryNumber('abc'), isNull);
  });

  test('validateInventoryRequiredText supports reusable messages', () {
    expect(validateInventoryRequiredText('Product'), isNull);
    expect(
      validateInventoryRequiredText(
        ' ',
        errorMessage: inventoryProductNameRequiredError,
      ),
      inventoryProductNameRequiredError,
    );
  });

  test('validateInventoryWholeNumber allows zero when requested', () {
    expect(validateInventoryWholeNumber('0', allowZero: true), isNull);
    expect(validateInventoryWholeNumber('4', allowZero: true), isNull);
    expect(
      validateInventoryWholeNumber('-1', allowZero: true),
      inventoryZeroOrMoreError,
    );
    expect(
      validateInventoryWholeNumber('abc', allowZero: true),
      inventoryWholeNumberError,
    );
  });

  test('validateInventoryWholeNumber can require at least one', () {
    expect(validateInventoryWholeNumber('1', allowZero: false), isNull);
    expect(
      validateInventoryWholeNumber('0', allowZero: false),
      inventoryAtLeastOneError,
    );
  });

  test('validateInventoryPositiveQuantity requires positive quantities', () {
    expect(validateInventoryPositiveQuantity(' 3 '), isNull);
    expect(
      validateInventoryPositiveQuantity('0'),
      inventoryPositiveQuantityError,
    );
    expect(
      validateInventoryPositiveQuantity('-1'),
      inventoryPositiveQuantityError,
    );
    expect(
      validateInventoryPositiveQuantity('abc'),
      inventoryPositiveQuantityError,
    );
  });

  test('validateInventoryPositiveDecimal requires finite positive values', () {
    expect(validateInventoryPositiveDecimal('12.5'), isNull);
    expect(
      validateInventoryPositiveDecimal(
        '0',
        errorMessage: inventoryProductUnitPriceError,
      ),
      inventoryProductUnitPriceError,
    );
    expect(
      validateInventoryPositiveDecimal(
        'Infinity',
        errorMessage: inventoryProductUnitPriceError,
      ),
      inventoryProductUnitPriceError,
    );
  });

  test(
    'validateInventoryOptionalNonNegativeNumber allows blank or positive',
    () {
      expect(validateInventoryOptionalNonNegativeNumber(''), isNull);
      expect(validateInventoryOptionalNonNegativeNumber('42'), isNull);
      expect(
        validateInventoryOptionalNonNegativeNumber(
          '-1',
          errorMessage: inventoryWarehouseCapacityError,
        ),
        inventoryWarehouseCapacityError,
      );
      expect(
        validateInventoryOptionalNonNegativeNumber(
          'NaN',
          errorMessage: inventoryWarehouseCapacityError,
        ),
        inventoryWarehouseCapacityError,
      );
    },
  );
}
