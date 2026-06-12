import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/utils/inventory_search_utils.dart';

void main() {
  test('normalizeInventorySearchQuery trims and lowercases search text', () {
    expect(
      normalizeInventorySearchQuery('  North Warehouse  '),
      'north warehouse',
    );
    expect(normalizeInventorySearchQuery(null), isEmpty);
    expect(normalizeInventorySearchQuery('   '), isEmpty);
  });

  test('inventorySearchMatchesAny treats blank queries as matches', () {
    expect(inventorySearchMatchesAny('', const []), isTrue);
    expect(inventorySearchMatchesAny('   ', const ['Adapter']), isTrue);
  });

  test('inventorySearchMatchesAny compares candidates consistently', () {
    expect(
      inventorySearchMatchesAny('north', const ['Main Warehouse', 'North Hub']),
      isTrue,
    );
    expect(
      inventorySearchMatchesAny('  HUB  ', const [
        'Main Warehouse',
        'North Hub',
      ]),
      isTrue,
    );
    expect(inventorySearchMatchesAny('south', const ['North Hub']), isFalse);
  });

  test('inventorySearchMatchesAnyNormalized reuses a normalized query', () {
    final normalized = normalizeInventorySearchQuery(' AD-001 ');

    expect(
      inventorySearchMatchesAnyNormalized(normalized, const [
        'Adapter',
        'ad-001',
      ]),
      isTrue,
    );
    expect(
      inventorySearchMatchesAnyNormalized(normalized, const ['Adapter', null]),
      isFalse,
    );
  });
}
