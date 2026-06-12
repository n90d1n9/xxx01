import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/customer.dart';
import 'package:kaysir/features/finance/accounting/screens/acc_receivable/acc_receivable.dart';
import 'package:kaysir/features/finance/accounting/states/customer_provider.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_filter_provider.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('receivable controls use shared search, chips, and select', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [customersProvider3.overrideWith(_ImmediateCustomers.new)],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AccountsReceivableScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(3));
    expect(find.byType(AppContentPanel), findsNWidgets(2));
    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(AppFilterBar), findsOneWidget);
    expect(find.byType(AppFilterChipGroup<String>), findsOneWidget);
    expect(find.byType(AppSelectField<ReceivableSort>), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'acme');
    await tester.pump();

    expect(container.read(receivableSearchProvider), 'acme');
    expect(find.byTooltip('Clear receivable search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear receivable search'));
    await tester.pump();

    expect(container.read(receivableSearchProvider), isEmpty);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
    await tester.pump();

    expect(container.read(receivableStatusFilterProvider), 'overdue');

    await tester.ensureVisible(find.byType(AppSelectField<ReceivableSort>));
    await tester.tap(find.text('Due date: oldest first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balance: high to low').last);
    await tester.pumpAndSettle();

    expect(container.read(receivableSortProvider), ReceivableSort.amountDesc);
  });
}

class _ImmediateCustomers extends CustomersNotifier2 {
  @override
  Future<List<Customer>> build() async {
    return <Customer>[];
  }
}
