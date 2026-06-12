import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/product_sourcing_management.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_sourcing_management_panel.dart';

void main() {
  testWidgets(
    'sourcing management panel renders suppliers and delegates review',
    (tester) async {
      ProductSourcingManagementEntry? selectedSupplier;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductSourcingManagementPanel(
                overview: _overview,
                onSupplierSelected: (supplier) => selectedSupplier = supplier,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sourcing management'), findsOneWidget);
      expect(find.text('Supplier coverage'), findsOneWidget);
      expect(find.text('2/3 assigned'), findsOneWidget);
      expect(find.text(productUnassignedSupplierLabel), findsOneWidget);
      expect(find.text('Assign supplier'), findsOneWidget);

      await tester.tap(find.text('Assign supplier'));
      await tester.pump();

      expect(selectedSupplier?.id, 'unassigned_supplier');
    },
  );
}

const _unassigned = ProductSourcingManagementEntry(
  id: 'unassigned_supplier',
  title: productUnassignedSupplierLabel,
  productCount: 1,
  attentionProductCount: 1,
  untrackedProductCount: 0,
  costedProductCount: 0,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(),
  isUnassigned: true,
);

const _acme = ProductSourcingManagementEntry(
  id: 'acme_supply',
  title: 'Acme Supply',
  productCount: 2,
  attentionProductCount: 0,
  untrackedProductCount: 0,
  costedProductCount: 1,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(query: 'Acme Supply'),
);

final _overview = ProductSourcingManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductSourcingManagementSummary(
    supplierCount: 1,
    productCount: 3,
    assignedProductCount: 2,
    unassignedProductCount: 1,
    attentionProductCount: 1,
    untrackedProductCount: 0,
    costedProductCount: 1,
    totalInventoryValue: 1200,
  ),
  suppliers: const [_unassigned, _acme],
);
