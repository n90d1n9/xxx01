import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/invoice_table.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('renders payable bills with shared status and action widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 560, width: 1200, child: InvoicesTable()),
          ),
        ),
      ),
    );

    expect(find.text('Vendor'), findsOneWidget);
    expect(find.text('ABC Supplies'), findsOneWidget);
    expect(find.text('INV-2025-001'), findsOneWidget);
    expect(find.text(r'$2,500.00'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsWidgets);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.byType(AppIconActionButton), findsWidgets);
    expect(find.byTooltip('Edit bill'), findsWidgets);
    expect(find.byTooltip('Post bill payment'), findsWidgets);
    expect(find.byTooltip('Delete bill'), findsWidgets);
  });

  testWidgets('uses shared empty state when no payable bills match', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [invoicesProvider.overrideWith((ref) => _EmptyInvoices())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 420, width: 900, child: InvoicesTable()),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No bills found'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsNothing);
  });
}

class _EmptyInvoices extends InvoicesNotifier {
  _EmptyInvoices() {
    state = InvoiceState(invoices: const <Invoice>[]);
  }
}
