import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_draft.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('product draft normalizes and converts to product', () {
    const draft = InventoryProductDraft(
      name: '  Scanner  ',
      sku: '  SC-001  ',
      category: '  Hardware  ',
      price: 80,
      description: '  Barcode scanner  ',
      barcode: '  8990001  ',
      shortcutKey: '  F1  ',
    );

    expect(validateInventoryProductDraft(draft), isNull);

    final product = draft.toProduct(id: 'p1');
    expect(product.id, 'p1');
    expect(product.name, 'Scanner');
    expect(product.sku, 'SC-001');
    expect(product.category, 'Hardware');
    expect(product.price, 80);
    expect(product.description, 'Barcode scanner');
    expect(product.barcode, '8990001');
    expect(product.shortcutKey, 'F1');
  });

  test('product draft converts empty description to null for new products', () {
    const draft = InventoryProductDraft(
      name: 'Scanner',
      sku: 'SC-001',
      category: 'Hardware',
      price: 80,
    );

    expect(draft.toProduct(id: 'p1').description, isNull);
  });

  test('product draft preloads from product and validates required fields', () {
    final draft = InventoryProductDraft.fromProduct(
      Product(
        id: 'p1',
        name: 'Laptop',
        sku: 'LT-001',
        category: 'Electronics',
        price: 100,
        description: 'Workstation',
        barcode: '8990001',
        shortcutKey: 'F2',
      ),
    );

    expect(draft.name, 'Laptop');
    expect(draft.sku, 'LT-001');
    expect(draft.category, 'Electronics');
    expect(draft.price, 100);
    expect(draft.description, 'Workstation');
    expect(draft.barcode, '8990001');
    expect(draft.shortcutKey, 'F2');

    expect(
      validateInventoryProductDraft(
        const InventoryProductDraft(name: '', sku: 'SC-001', category: 'HW'),
      ),
      InventoryProductDraftIssue.missingName,
    );
    expect(
      validateInventoryProductDraft(
        const InventoryProductDraft(name: 'Scanner', sku: '', category: 'HW'),
      ),
      InventoryProductDraftIssue.missingSku,
    );
    expect(
      validateInventoryProductDraft(
        const InventoryProductDraft(
          name: 'Scanner',
          sku: 'SC-001',
          category: '',
        ),
      ),
      InventoryProductDraftIssue.missingCategory,
    );
    expect(
      validateInventoryProductDraft(
        const InventoryProductDraft(
          name: 'Scanner',
          sku: 'SC-001',
          category: 'HW',
          price: 0,
        ),
      ),
      InventoryProductDraftIssue.invalidPrice,
    );
  });

  test('product draft applies edits while preserving inventory fields', () {
    final product = Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      description: 'Old copy',
      barcode: '8990001',
      shortcutKey: 'F2',
      price: 100,
      currentStock: 12,
      systemStock: 10,
      actualStock: 11,
      quantity: 3,
    );
    const draft = InventoryProductDraft(
      name: '  Laptop Pro  ',
      sku: '  LT-PRO  ',
      category: '  Devices  ',
      description: '',
      barcode: '',
      shortcutKey: '',
      price: 140,
    );

    final updatedProduct = draft.apply(product);

    expect(updatedProduct.id, 'p1');
    expect(updatedProduct.name, 'Laptop Pro');
    expect(updatedProduct.sku, 'LT-PRO');
    expect(updatedProduct.category, 'Devices');
    expect(updatedProduct.description, isNull);
    expect(updatedProduct.barcode, isNull);
    expect(updatedProduct.shortcutKey, '');
    expect(updatedProduct.price, 140);
    expect(updatedProduct.currentStock, 12);
    expect(updatedProduct.systemStock, 10);
    expect(updatedProduct.actualStock, 11);
    expect(updatedProduct.quantity, 3);
  });

  test('inventoryProductIdForDate creates stable product suffix', () {
    expect(
      inventoryProductIdForDate(DateTime.fromMillisecondsSinceEpoch(123456789)),
      'PRD-456789',
    );
  });
}
