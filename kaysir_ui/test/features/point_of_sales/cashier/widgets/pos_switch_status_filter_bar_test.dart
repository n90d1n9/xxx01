import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_status_filter_bar.dart';

enum _FilterStatus { all, ready, blocked }

void main() {
  test('option factory preserves status values, labels, and counts', () {
    final options = POSSwitchStatusFilterOption.fromValues<_FilterStatus>(
      _FilterStatus.values,
      labelBuilder: _statusLabel,
      countBuilder: _statusCount,
    );

    expect(options.map((option) => option.value), _FilterStatus.values);
    expect(options.map((option) => option.label), ['All', 'Ready', 'Blocked']);
    expect(options.map((option) => option.count), [8, 5, 1]);
  });

  testWidgets('switch status filter bar renders labels and counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchStatusFilterBar<_FilterStatus>(
            selectedValue: _FilterStatus.ready,
            options: const [
              POSSwitchStatusFilterOption(
                value: _FilterStatus.all,
                label: 'All',
                count: 8,
              ),
              POSSwitchStatusFilterOption(
                value: _FilterStatus.ready,
                label: 'Ready',
                count: 5,
              ),
              POSSwitchStatusFilterOption(
                value: _FilterStatus.blocked,
                label: 'Blocked',
                count: 1,
              ),
            ],
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Ready'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Blocked'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Ready'),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('switch status filter bar reports selected values', (
    tester,
  ) async {
    _FilterStatus? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchStatusFilterBar<_FilterStatus>(
            selectedValue: _FilterStatus.all,
            options: const [
              POSSwitchStatusFilterOption(
                value: _FilterStatus.all,
                label: 'All',
                count: 8,
              ),
              POSSwitchStatusFilterOption(
                value: _FilterStatus.blocked,
                label: 'Blocked',
                count: 1,
              ),
            ],
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pump();

    expect(selected, _FilterStatus.blocked);
  });

  testWidgets('switch status filter bar stays quiet without options', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchStatusFilterBar<_FilterStatus>(
            selectedValue: _FilterStatus.all,
            options: const [],
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(ChoiceChip), findsNothing);
  });
}

String _statusLabel(_FilterStatus status) {
  switch (status) {
    case _FilterStatus.all:
      return 'All';
    case _FilterStatus.ready:
      return 'Ready';
    case _FilterStatus.blocked:
      return 'Blocked';
  }
}

int _statusCount(_FilterStatus status) {
  switch (status) {
    case _FilterStatus.all:
      return 8;
    case _FilterStatus.ready:
      return 5;
    case _FilterStatus.blocked:
      return 1;
  }
}
