import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/widgets/product_fresh_goods_table_column_contributions.dart';

void main() {
  testWidgets('fresh goods freshness cells summarize expiry and batch state', (
    tester,
  ) async {
    final today = DateTime(2026, 6, 15);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ProductFreshGoodsFreshnessTableCell(
                record: _record(
                  id: 'fresh',
                  attributes: const {
                    'expiry_date': '2026-06-24',
                    'batch_number': 'B-100',
                    'freshness_status': 'Fresh',
                  },
                ),
                today: today,
              ),
              ProductFreshGoodsFreshnessTableCell(
                record: _record(
                  id: 'today',
                  attributes: const {
                    'expiry_date': '2026-06-15',
                    'batch_number': 'B-101',
                  },
                ),
                today: today,
              ),
              ProductFreshGoodsFreshnessTableCell(
                record: _record(
                  id: 'missing-expiry',
                  attributes: const {'batch_number': 'B-102'},
                ),
                today: today,
              ),
              ProductFreshGoodsFreshnessTableCell(
                record: _record(
                  id: 'pull',
                  attributes: const {
                    'expiry_date': '2026-06-28',
                    'freshness_status': 'Pull',
                  },
                ),
                today: today,
              ),
              ProductFreshGoodsFreshnessTableCell(
                record: _record(
                  id: 'batch',
                  attributes: const {'expiry_date': '2026-06-30'},
                ),
                today: today,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Fresh'), findsOneWidget);
    expect(find.text('Expires today'), findsOneWidget);
    expect(find.text('No expiry'), findsOneWidget);
    expect(find.text('Pull stock'), findsOneWidget);
    expect(find.text('Add batch'), findsOneWidget);
  });

  test('fresh goods freshness signal marks invalid and due-soon dates', () {
    final today = DateTime(2026, 6, 15);

    expect(
      productFreshGoodsFreshnessSignalForRecord(
        _record(id: 'invalid', attributes: const {'expiry_date': '15/06/2026'}),
        today: today,
      ).label,
      'Check date',
    );
    expect(
      productFreshGoodsFreshnessSignalForRecord(
        _record(
          id: 'soon',
          attributes: const {
            'expiry_date': '2026-06-17',
            'batch_number': 'B-200',
          },
        ),
        today: today,
      ).label,
      'Due soon',
    );
    expect(
      productFreshGoodsFreshnessSignalForRecord(
        _record(
          id: 'expired',
          attributes: const {
            'expiry_date': '2026-06-14',
            'batch_number': 'B-201',
          },
        ),
        today: today,
      ).label,
      'Expired',
    );
  });
}

InventoryProductCatalogRecord _record({
  required String id,
  required Map<String, String> attributes,
}) {
  return InventoryProductCatalogRecord(
    product: Product(
      id: id,
      name: 'Fresh item $id',
      sku: 'FR-$id',
      category: 'Produce',
      price: 12000,
      customAttributes: attributes,
    ),
    stockRecords: const [],
  );
}
