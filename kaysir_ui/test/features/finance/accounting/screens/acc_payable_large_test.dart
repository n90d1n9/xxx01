import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/screens/acc_payable/acc_payable_large.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_filter_provider.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('payable filters use shared select and checkbox controls', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AccountsPayableDashboard()),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(3));
    expect(find.byType(AppContentPanel), findsNWidgets(2));
    expect(find.byType(AppFilterBar), findsOneWidget);
    expect(find.byType(AppSelectField<InvoiceStatus?>), findsOneWidget);
    expect(find.byType(AppSelectField<String?>), findsOneWidget);
    expect(find.byType(AppCheckboxRow), findsOneWidget);
    expect(find.byType(AppActionButton), findsOneWidget);

    await tester.ensureVisible(find.text('All Statuses'));
    await tester.tap(find.text('All Statuses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paid').last);
    await tester.pumpAndSettle();

    expect(container.read(invoiceFilterProvider).status, InvoiceStatus.paid);

    await tester.ensureVisible(find.text('Show Overdue Only'));
    await tester.tap(find.text('Show Overdue Only'));
    await tester.pumpAndSettle();

    expect(container.read(invoiceFilterProvider).showOverdueOnly, isTrue);
  });
}
