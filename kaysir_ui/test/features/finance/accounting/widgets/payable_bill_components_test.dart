import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_bill_components.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

void main() {
  testWidgets('payable bill date field renders date and reports taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: PayableBillDateField(
                label: 'Bill Date',
                date: DateTime(2026, 5, 31),
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bill Date'), findsOneWidget);
    expect(find.text('05/31/2026'), findsOneWidget);
    expect(find.byType(AppIconBadge), findsOneWidget);

    await tester.tap(find.text('05/31/2026'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('payable bill journal preview uses reusable info rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: PayableBillJournalPreview(
              debitAccountName: 'Rent Expense',
              creditAccountName: 'Accounts Payable',
              amount: 450,
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Journal Preview'), findsOneWidget);
    expect(find.byType(AppInfoRow), findsNWidgets(2));
    expect(find.text('Debit'), findsOneWidget);
    expect(find.text('Credit'), findsOneWidget);
    expect(find.text('Rent Expense'), findsOneWidget);
    expect(find.text('Accounts Payable'), findsOneWidget);
    expect(find.text(r'$450.00'), findsNWidgets(3));
  });
}
