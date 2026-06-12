import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_manager_badge.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('manager badge renders shared saved-workspace styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: OrderSavedWorkspaceManagerBadge(label: 'Pinned')),
        ),
      ),
    );

    final badgeContainer = find.descendant(
      of: find.byType(OrderSavedWorkspaceManagerBadge),
      matching: find.byType(Container),
    );
    final badge = tester.widget<Container>(badgeContainer);
    final decoration = badge.decoration! as BoxDecoration;
    final label = tester.widget<Text>(find.text('Pinned'));

    expect(find.text('Pinned'), findsOneWidget);
    expect(
      badge.padding,
      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
    expect(decoration.borderRadius, BorderRadius.circular(POSUiTokens.radius));
    expect(decoration.border, isA<Border>());
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manager badge can render a leading status icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSavedWorkspaceManagerBadge(
              icon: Icons.push_pin_rounded,
              label: 'Pinned',
            ),
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.push_pin_rounded));

    expect(find.text('Pinned'), findsOneWidget);
    expect(icon.size, 13);
    expect(tester.takeException(), isNull);
  });
}
