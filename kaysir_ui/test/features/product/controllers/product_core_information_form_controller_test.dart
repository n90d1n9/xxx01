import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/controllers/product_core_information_form_controller.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_core_information_field_ids.dart';

void main() {
  test('core information controller initializes from product', () {
    final controller = ProductCoreInformationFormController.fromProduct(
      Product(
        id: 'p1',
        name: 'Spinach',
        sku: 'SP-001',
        category: 'Fresh',
        price: 12,
        currentStock: 8,
        description: 'Leafy greens',
      ),
    );
    addTearDown(controller.dispose);

    expect(controller.nameController.text, 'Spinach');
    expect(controller.skuController.text, 'SP-001');
    expect(controller.categoryController.text, 'Fresh');
    expect(controller.priceController.text, '12.0');
    expect(controller.stockController.text, '8');
    expect(controller.descriptionController.text, 'Leafy greens');
    expect(controller.progressValues(), {
      ProductCoreInformationFieldIds.name: 'Spinach',
      ProductCoreInformationFieldIds.sku: 'SP-001',
      ProductCoreInformationFieldIds.category: 'Fresh',
      ProductCoreInformationFieldIds.price: '12.0',
      ProductCoreInformationFieldIds.initialStock: '8',
      ProductCoreInformationFieldIds.description: 'Leafy greens',
    });
  });

  test('core information controller attaches and detaches listener', () {
    final controller = ProductCoreInformationFormController.fromProduct(null);
    addTearDown(controller.dispose);
    var changeCount = 0;

    controller.attachListener(() {
      changeCount += 1;
    });
    controller.nameController.text = 'Spinach';

    expect(changeCount, 1);

    controller.detachListener();
    controller.skuController.text = 'SP-001';

    expect(changeCount, 1);
  });

  test('core information controller builds draft with extension values', () {
    final controller = ProductCoreInformationFormController.fromProduct(null);
    addTearDown(controller.dispose);

    controller.nameController.text = ' Spinach ';
    controller.skuController.text = ' SP-001 ';
    controller.categoryController.text = ' Fresh ';
    controller.priceController.text = '12';
    controller.stockController.text = '8';
    controller.descriptionController.text = ' Leafy greens ';

    final draft = controller.toDraft(
      barcode: ' 8990001 ',
      unit: ' bunch ',
      customAttributes: const {' batch_number ': ' B-01 '},
    );

    expect(draft.name, 'Spinach');
    expect(draft.sku, 'SP-001');
    expect(draft.category, 'Fresh');
    expect(draft.price, 12);
    expect(draft.initialStock, 8);
    expect(draft.description, 'Leafy greens');
    expect(draft.barcode, '8990001');
    expect(draft.unit, 'bunch');
    expect(draft.customAttributes, {'batch_number': 'B-01'});
  });
}
