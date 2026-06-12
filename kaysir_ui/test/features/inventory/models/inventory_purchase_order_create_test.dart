import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_create.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('purchase order create draft totals and converts to order', () {
    final draft = InventoryPurchaseOrderCreateDraft(
      supplierName: '  Jakarta Supply  ',
      expectedDeliveryDate: DateTime(2026, 6, 5),
      notes: '  Priority receiving  ',
      items: [
        PurchaseOrderItem(
          id: 'p1',
          name: 'Laptop',
          quantity: 2,
          unitPrice: 100,
        ),
        PurchaseOrderItem(id: 'p2', name: 'Cable', quantity: 4, unitPrice: 25),
      ],
    );

    expect(draft.itemCount, 2);
    expect(draft.totalQuantity, 6);
    expect(draft.totalAmount, 300);
    expect(draft.canCreate, isTrue);

    final order = draft.toPurchaseOrder(
      id: 'PO-001',
      orderDate: DateTime(2026, 5, 31),
      status: OrderStatus.confirmed,
    );

    expect(order.id, 'PO-001');
    expect(order.supplierName, 'Jakarta Supply');
    expect(order.vendorName, 'Jakarta Supply');
    expect(order.notes, 'Priority receiving');
    expect(order.totalAmount, 300);
    expect(order.items, hasLength(2));
  });

  test('purchase order create draft validates supplier and items', () {
    expect(
      validateInventoryPurchaseOrderCreateDraft(
        const InventoryPurchaseOrderCreateDraft(supplierName: '', items: []),
      ),
      InventoryPurchaseOrderCreateIssue.missingSupplier,
    );
    expect(
      validateInventoryPurchaseOrderCreateDraft(
        const InventoryPurchaseOrderCreateDraft(
          supplierName: 'Jakarta Supply',
          items: [],
        ),
      ),
      InventoryPurchaseOrderCreateIssue.emptyItems,
    );
    expect(
      inventoryPurchaseOrderCreateIssueLabel(
        InventoryPurchaseOrderCreateIssue.emptyItems,
      ),
      contains('Add at least one item'),
    );
  });

  test('purchase order line draft validates and creates item from product', () {
    final products = [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
    ];

    expect(
      validateInventoryPurchaseOrderLineDraft(
        InventoryPurchaseOrderLineDraft(products: products),
      ),
      InventoryPurchaseOrderLineIssue.missingProduct,
    );
    expect(
      validateInventoryPurchaseOrderLineDraft(
        InventoryPurchaseOrderLineDraft(
          products: products,
          productId: 'p1',
          quantityText: '0',
          unitPriceText: '100',
        ),
      ),
      InventoryPurchaseOrderLineIssue.invalidQuantity,
    );
    expect(
      validateInventoryPurchaseOrderLineDraft(
        InventoryPurchaseOrderLineDraft(
          products: products,
          productId: 'p1',
          quantityText: '3',
          unitPriceText: 'Infinity',
        ),
      ),
      InventoryPurchaseOrderLineIssue.invalidUnitPrice,
    );

    final draft = InventoryPurchaseOrderLineDraft(
      products: products,
      productId: 'p1',
      quantityText: '3',
      unitPriceText: '95.50',
    );

    expect(validateInventoryPurchaseOrderLineDraft(draft), isNull);
    expect(draft.total, 286.5);

    final item = draft.toPurchaseOrderItem();
    expect(item.id, 'p1');
    expect(item.name, 'Laptop');
    expect(item.sku, 'LT-001');
    expect(item.quantity, 3);
    expect(item.unitPrice, 95.5);
  });

  test('inventoryPurchaseOrderIdForDate creates stable PO suffix', () {
    expect(
      inventoryPurchaseOrderIdForDate(
        DateTime.fromMillisecondsSinceEpoch(123456789),
      ),
      'PO-456789',
    );
  });
}
