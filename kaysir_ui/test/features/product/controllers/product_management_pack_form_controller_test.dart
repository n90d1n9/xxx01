import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/controllers/product_management_pack_form_controller.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('management pack controller initializes editable pack fields', () {
    final controller = ProductManagementPackFormController(
      product: Product(
        id: 'p1',
        name: 'Spinach',
        barcode: '8990001',
        unit: 'bunch',
        customAttributes: const {
          'expiry_date': '2026-07-01',
          'batch_number': 'B-01',
          'weighted_unit': 'yes',
          'freshness_status': 'Monitor',
        },
      ),
    );
    addTearDown(controller.dispose);

    controller.ensurePackFields(groceryFreshGoodsProductManagementPack);

    expect(
      controller.textControllers[ProductManagementFieldId.barcode]?.text,
      '8990001',
    );
    expect(
      controller.textControllers[ProductManagementFieldId.unit]?.text,
      'bunch',
    );
    expect(
      controller.textControllers[ProductManagementFieldId.expiryDate]?.text,
      '2026-07-01',
    );
    expect(
      controller.textControllers[ProductManagementFieldId.batchNumber]?.text,
      'B-01',
    );
    expect(
      controller
          .textControllers[ProductManagementFieldId.freshnessStatus]
          ?.text,
      'Monitor',
    );
    expect(
      controller.toggleValues[ProductManagementFieldId.weightedUnit],
      isTrue,
    );
  });

  test('management pack controller attaches listener to lazy controllers', () {
    final controller = ProductManagementPackFormController();
    addTearDown(controller.dispose);
    var changeCount = 0;

    controller.attachListener(() {
      changeCount += 1;
    });
    controller.ensurePackFields(groceryFreshGoodsProductManagementPack);
    controller.textControllers[ProductManagementFieldId.barcode]?.text =
        '8990001';

    expect(changeCount, 1);

    controller.detachListener();
    controller.textControllers[ProductManagementFieldId.unit]?.text = 'bunch';

    expect(changeCount, 1);
  });

  test('management pack controller exposes progress and custom attributes', () {
    final controller = ProductManagementPackFormController();
    addTearDown(controller.dispose);

    controller.ensurePackFields(groceryFreshGoodsProductManagementPack);
    controller.textControllers[ProductManagementFieldId.barcode]?.text =
        '8990001';
    controller.textControllers[ProductManagementFieldId.unit]?.text = 'bunch';
    controller.textControllers[ProductManagementFieldId.expiryDate]?.text =
        '2026-07-01';
    controller.textControllers[ProductManagementFieldId.batchNumber]?.text =
        'B-01';
    controller.textControllers[ProductManagementFieldId.shelfLifeDays]?.text =
        '5';
    controller.textControllers[ProductManagementFieldId.freshnessStatus]?.text =
        'Monitor';
    controller.setToggleValue(
      groceryFreshGoodsProductManagementPack.fieldOrNull(
        ProductManagementFieldId.weightedUnit,
      )!,
      true,
    );

    expect(controller.barcodeText, '8990001');
    expect(controller.unitText, 'bunch');
    expect(controller.progressValues(groceryFreshGoodsProductManagementPack), {
      'barcode': '8990001',
      'unit': 'bunch',
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
      'weighted_unit': 'true',
      'shelf_life_days': '5',
      'freshness_status': 'Monitor',
    });
    expect(
      controller.customAttributes(groceryFreshGoodsProductManagementPack),
      {
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
        'weighted_unit': 'true',
        'shelf_life_days': '5',
        'freshness_status': 'Monitor',
      },
    );
  });
}
