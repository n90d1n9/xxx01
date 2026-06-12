import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_catalog.dart';

void main() {
  test(
    'runtime pack catalog groups packs by product line without reordering',
    () {
      final cafePack = defaultPOSProductRuntimePack.copyWith(
        id: 'cafe_pack',
        label: 'Cafe Pack',
        productLine: 'Kaysir Cafe',
      );
      final retailPack = defaultPOSProductRuntimePack.copyWith(
        id: 'retail_pack',
        label: 'Retail Pack',
      );

      final catalog = POSProductRuntimePackCatalog.fromPacks([
        defaultPOSProductRuntimePack,
        cafePack,
        retailPack,
      ]);

      expect(catalog.isEmpty, isFalse);
      expect(catalog.isSinglePack, isFalse);
      expect(catalog.sections.map((section) => section.productLine), [
        'Kaysir Core',
        'Kaysir Cafe',
      ]);
      expect(catalog.sections.first.packCount, 2);
      expect(catalog.sections.first.packs.map((pack) => pack.id), [
        defaultPOSProductRuntimePack.id,
        retailPack.id,
      ]);
      expect(catalog.sections.last.packs.single, same(cafePack));
    },
  );

  test('runtime pack catalog treats blank product lines as unassigned', () {
    final unassignedPack = defaultPOSProductRuntimePack.copyWith(
      id: 'unassigned_pack',
      productLine: ' ',
    );

    final catalog = POSProductRuntimePackCatalog.fromPacks([unassignedPack]);

    expect(catalog.isSinglePack, isTrue);
    expect(catalog.sections.single.productLine, 'Unassigned');
  });
}
