import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/vendor.dart';
import 'package:kaysir/features/finance/accounting/states/vendor_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_bill_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_bill_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('payable bill dialog composes reusable modern form widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(980, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_billDialog(vendors: [_vendor()]));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Post Vendor Bill'), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsNWidgets(2));
    expect(find.byType(PayableBillDateField), findsNWidgets(2));
    expect(find.byType(PayableBillJournalPreview), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('Acme Supplies'), findsOneWidget);
    expect(find.text('5000 - Rent Expense'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '225');
    await tester.pump();

    expect(find.text(r'$225.00'), findsNWidgets(3));
  });

  testWidgets('payable bill dialog shows setup state without vendors', (
    tester,
  ) async {
    await tester.pumpWidget(_billDialog(vendors: const []));

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Bill setup incomplete'), findsOneWidget);
    expect(
      find.text('Configure vendor records before posting vendor bills.'),
      findsOneWidget,
    );
    expect(find.byType(AppSelectField<String>), findsNothing);
    expect(find.byType(PayableBillJournalPreview), findsNothing);
  });
}

Widget _billDialog({required List<Vendor> vendors}) {
  return ProviderScope(
    overrides: [vendorsProvider.overrideWith((ref) => _SeededVendors(vendors))],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: PayableBillDialog())),
    ),
  );
}

Vendor _vendor() {
  return Vendor(id: 'vendor-1', name: 'Acme Supplies', email: 'ap@acme.test');
}

class _SeededVendors extends VendorsNotifier {
  _SeededVendors(List<Vendor> vendors) {
    state = vendors;
  }
}
