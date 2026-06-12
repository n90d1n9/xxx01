import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/order_workspace_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('OrderWorkspaceChip renders compact route signal', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      OrderWorkspaceChip(profile: ProductProfile.marketplaceOperations),
    );

    expect(
      find.byKey(const ValueKey('order_workspace_chip_marketplace_operations')),
      findsOneWidget,
    );
    expect(find.text('Orders: Marketplace'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
