import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/utils/product_form_draft.dart';

void main() {
  test('draft trims fields and creates new product with stock', () {
    final draft = ProductFormDraft.fromText(
      name: '  Coffee  ',
      sku: ' CF-001 ',
      category: ' Beverage ',
      price: '25000',
      initialStock: '12',
      description: '  Arabica blend  ',
      barcode: ' 8990001 ',
      unit: ' cup ',
      customAttributes: {' batch_number ': ' B-01 ', 'empty': ' '},
    );

    final product = draft.toProduct(id: 'p1');

    expect(product.name, 'Coffee');
    expect(product.sku, 'CF-001');
    expect(product.category, 'Beverage');
    expect(product.price, 25000);
    expect(product.currentStock, 12);
    expect(product.stockQuantity, 12);
    expect(product.description, 'Arabica blend');
    expect(product.barcode, '8990001');
    expect(product.unit, 'cup');
    expect(product.customAttributes, {'batch_number': 'B-01'});
  });

  test('draft applies edits without changing current stock', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      sku: 'CF-001',
      category: 'Beverage',
      price: 25000,
      currentStock: 7,
      stockQuantity: 7,
      description: 'Arabica',
    );
    final draft = ProductFormDraft(
      name: 'Iced Coffee',
      sku: 'CF-002',
      category: 'Beverage',
      price: 30000,
      initialStock: 0,
      description: 'Cold brew',
    );

    final edited = draft.applyTo(product);

    expect(edited.name, 'Iced Coffee');
    expect(edited.currentStock, 7);
    expect(edited.stockQuantity, 7);
  });

  test('draft creates initial stock movement only for positive stock', () {
    final draft = ProductFormDraft(
      name: 'Coffee',
      sku: 'CF-001',
      category: 'Beverage',
      price: 25000,
      initialStock: 4,
      description: 'Arabica',
    );
    final movement = draft.initialStockMovement(
      id: 'm1',
      productId: 'p1',
      date: DateTime(2026, 6, 2),
    );

    expect(movement, isNotNull);
    expect(movement!.quantity, 4);
    expect(movement.type, MovementType.inbound);
    expect(movement.reference, 'Initial');

    expect(
      draft
          .copyWith(initialStock: 0)
          .initialStockMovement(
            id: 'm2',
            productId: 'p1',
            date: DateTime(2026, 6, 2),
          ),
      isNull,
    );
  });

  test('validators reject missing, invalid, and negative numeric inputs', () {
    expect(validateRequiredProductField(' ', 'a product name'), isNotNull);
    expect(validateProductPriceInput('abc'), 'Please enter a valid price');
    expect(validateProductPriceInput('-1'), 'Price cannot be negative');
    expect(validateProductPriceInput('0'), isNull);
    expect(validateProductStockInput('1.5'), 'Please enter a whole number');
    expect(validateProductStockInput('-1'), 'Stock cannot be negative');
    expect(validateProductStockInput('0'), isNull);
    expect(
      validateProductManagementFieldInput(
        groceryFreshGoodsFields.first,
        'not a date',
      ),
      'Please enter a valid expiry date',
    );
    expect(
      validateProductManagementFieldInput(
        groceryFreshGoodsFields.last,
        'Stale',
      ),
      'Please select a valid freshness status',
    );
  });
}

extension on ProductFormDraft {
  ProductFormDraft copyWith({int? initialStock}) {
    return ProductFormDraft(
      name: name,
      sku: sku,
      category: category,
      price: price,
      initialStock: initialStock ?? this.initialStock,
      description: description,
    );
  }
}
