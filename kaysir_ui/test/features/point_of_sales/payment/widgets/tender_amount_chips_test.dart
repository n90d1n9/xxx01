import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/payment/utils/payment_tendering.dart';
import 'package:kaysir/features/point_of_sales/payment/widgets/tender_amount_chips.dart';

void main() {
  testWidgets('TenderAmountChips reports the selected amount', (tester) async {
    double? selectedAmount;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TenderAmountChips(
            suggestions: const [
              TenderSuggestion(label: 'Exact', amount: 27500, isExact: true),
              TenderSuggestion(label: '50k', amount: 50000),
            ],
            selectedAmount: 27500,
            onSelected: (amount) => selectedAmount = amount,
          ),
        ),
      ),
    );

    await tester.tap(find.text('50k'));
    await tester.pumpAndSettle();

    expect(selectedAmount, 50000);
  });
}
