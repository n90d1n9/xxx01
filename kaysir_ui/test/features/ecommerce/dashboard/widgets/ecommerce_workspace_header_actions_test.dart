import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/header_actions.dart';

void main() {
  testWidgets('HeaderActions renders workspace commands', (tester) async {
    final tapped = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeaderActions(
            onOpenCheckout: () => tapped.add('checkout'),
            onOpenOrders: () => tapped.add('orders'),
          ),
        ),
      ),
    );

    expect(find.byType(ActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.point_of_sale_outlined), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.text('Open checkout'), findsOneWidget);
    expect(find.text('Review orders'), findsOneWidget);
    expect(find.byType(FilledButton), findsNWidgets(2));

    await tester.tap(find.text('Open checkout'));
    await tester.tap(find.text('Review orders'));
    await tester.pump();

    expect(tapped, ['checkout', 'orders']);
  });

  testWidgets('HeaderActions accepts custom alignment', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeaderActions(
            onOpenCheckout: _noop,
            onOpenOrders: _noop,
            alignment: WrapAlignment.start,
          ),
        ),
      ),
    );

    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.alignment, WrapAlignment.start);
  });
}

void _noop() {}
