import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_filtered_panel.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_filter_state.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('switch filtered panel wires chrome, filters, and sections', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    expect(find.text('Switch modes'), findsOneWidget);
    expect(find.text('Core mode'), findsOneWidget);
    expect(find.text('Search options'), findsOneWidget);
    expect(find.text('Kaysir Core (2)'), findsOneWidget);
    expect(find.text('Coffee bar'), findsOneWidget);
    expect(find.text('Retail counter'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'All'),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pumpAndSettle();

    expect(find.text('Coffee bar'), findsOneWidget);
    expect(find.text('Retail counter'), findsNothing);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Blocked'),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pumpAndSettle();

    expect(find.text('No matching options'), findsOneWidget);
  });

  testWidgets('switch filtered panel can hide filters and show order context', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        enableSearch: false,
        shrinkWrap: true,
        currentOrder: _activeOrder(),
      ),
    );

    expect(find.text('Active order'), findsOneWidget);
    expect(find.text('Search options'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Coffee bar'), findsOneWidget);
  });
}

Widget _host({
  bool enableSearch = true,
  bool shrinkWrap = false,
  Order? currentOrder,
}) {
  final panel = POSSwitchFilteredPanel<_FilterStatus, _SwitchSection>(
    title: 'Switch modes',
    currentLabel: 'Core mode',
    initialStatus: _FilterStatus.all,
    statusValues: _FilterStatus.values,
    statusLabelBuilder: _statusLabel,
    searchHintText: 'Search options',
    filteredTitle: 'No matching options',
    emptyTitle: 'No options available',
    enableSearch: enableSearch,
    shrinkWrap: shrinkWrap,
    currentOrder: currentOrder,
    dataBuilder:
        (context, filterState) => _buildPanelData(filterState, _sampleEntries),
    headerBuilder:
        (context, section) =>
            Text('${section.title} (${section.entries.length})'),
    childrenBuilder:
        (context, section) => section.entries.map((entry) => Text(entry.label)),
  );

  return MaterialApp(
    home: Scaffold(
      body:
          shrinkWrap
              ? SingleChildScrollView(child: panel)
              : SizedBox(height: 360, child: panel),
    ),
  );
}

POSSwitchFilteredPanelData<_FilterStatus, _SwitchSection> _buildPanelData(
  POSSwitchFilterState<_FilterStatus> filterState,
  List<_SwitchEntry> entries,
) {
  final normalizedQuery = filterState.query.trim().toLowerCase();
  final queryMatches = entries
      .where((entry) {
        if (normalizedQuery.isEmpty) return true;
        return entry.label.toLowerCase().contains(normalizedQuery);
      })
      .toList(growable: false);
  final visible = queryMatches
      .where((entry) {
        if (filterState.status == _FilterStatus.all) return true;
        return entry.status == filterState.status;
      })
      .toList(growable: false);

  return POSSwitchFilteredPanelData(
    sections:
        visible.isEmpty
            ? const []
            : [_SwitchSection(title: 'Kaysir Core', entries: visible)],
    filterActive: !filterState.isAtDefault,
    countForStatus: (status) {
      if (status == _FilterStatus.all) return queryMatches.length;
      return queryMatches.where((entry) => entry.status == status).length;
    },
  );
}

String _statusLabel(_FilterStatus status) {
  switch (status) {
    case _FilterStatus.all:
      return 'All';
    case _FilterStatus.open:
      return 'Open';
    case _FilterStatus.blocked:
      return 'Blocked';
  }
}

Order _activeOrder() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}

const _sampleEntries = [
  _SwitchEntry(label: 'Coffee bar', status: _FilterStatus.open),
  _SwitchEntry(label: 'Retail counter', status: _FilterStatus.blocked),
];

enum _FilterStatus { all, open, blocked }

class _SwitchSection {
  final String title;
  final List<_SwitchEntry> entries;

  const _SwitchSection({required this.title, required this.entries});
}

class _SwitchEntry {
  final String label;
  final _FilterStatus status;

  const _SwitchEntry({required this.label, required this.status});
}
