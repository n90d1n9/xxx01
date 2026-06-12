import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_promotions_panel.dart';
import 'package:kaysir/features/point_of_sales/promotion/models/promotion.dart';

void main() {
  testWidgets('OrderPromotionsPanel can render applied promotions read-only', (
    tester,
  ) async {
    var managed = false;
    var removedId = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderPromotionsPanel(
            order: _order(),
            canManagePromotions: false,
            onManagePromotions: () => managed = true,
            onRemovePromotion: (id) => removedId = id,
          ),
        ),
      ),
    );

    expect(find.text('Promotions'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Manage'), findsNothing);
    expect(find.byTooltip('Remove promotion'), findsNothing);
    expect(managed, isFalse);
    expect(removedId, isEmpty);
  });

  testWidgets('OrderPromotionsPanel exposes management actions when allowed', (
    tester,
  ) async {
    var managed = false;
    var removedId = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderPromotionsPanel(
            order: _order(),
            onManagePromotions: () => managed = true,
            onRemovePromotion: (id) => removedId = id,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Manage'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove promotion'));
    await tester.pumpAndSettle();

    expect(managed, isTrue);
    expect(removedId, 'welcome');
  });
}

Order _order() {
  return Order(
    id: 'temp_order',
    items: const [],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: [
      Promotion(
        id: 'welcome',
        name: 'Welcome',
        code: 'WELCOME',
        discountPercentage: 10,
        discountAmount: 0,
        isActive: true,
        validUntil: DateTime(2026, 6, 1),
      ),
    ],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
