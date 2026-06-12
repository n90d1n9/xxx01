import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/customer.dart';
import 'package:kaysir/features/finance/accounting/screens/customer_list_screen.dart';
import 'package:kaysir/features/finance/accounting/states/customer_account_provider.dart';
import 'package:kaysir/features/finance/accounting/states/customer_provider.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('customer list controls use shared search, chips, and select', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [customersProvider3.overrideWith(_ImmediateCustomers.new)],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CustomerListScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(AppFilterBar), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(AppMetricCard), findsNWidgets(3));
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(AppFilterChipGroup<CustomerRiskFilter>), findsOneWidget);
    expect(find.byType(AppSelectField<CustomerSort>), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'acme');
    await tester.pump();

    expect(container.read(customerSearchProvider), 'acme');
    expect(find.byTooltip('Clear customer search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear customer search'));
    await tester.pump();

    expect(container.read(customerSearchProvider), isEmpty);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
    await tester.pump();

    expect(
      container.read(customerRiskFilterProvider),
      CustomerRiskFilter.overdue,
    );

    await tester.ensureVisible(find.byType(AppSelectField<CustomerSort>));
    await tester.tap(find.text('Open balance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Customer name').last);
    await tester.pumpAndSettle();

    expect(container.read(customerSortProvider), CustomerSort.nameAsc);
  });
}

class _ImmediateCustomers extends CustomersNotifier2 {
  @override
  Future<List<Customer>> build() async {
    return <Customer>[];
  }
}
