import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_segmented_filter_bar.dart';

void main() {
  test('option factory preserves filter values, labels, counts, and icons', () {
    final options = POSSegmentedFilterOption.fromValues<_FilterValue>(
      _FilterValue.values,
      labelBuilder: _filterLabel,
      countBuilder: _filterCount,
      iconBuilder: _filterIcon,
    );

    expect(options.map((option) => option.value), _FilterValue.values);
    expect(options.map((option) => option.label), ['All', 'Ready']);
    expect(options.map((option) => option.count), [4, 2]);
    expect(options.map((option) => option.icon), [
      Icons.list_alt_outlined,
      Icons.check_circle_outline,
    ]);
  });

  testWidgets('segmented filter bar renders labels, counts, and icons', (
    tester,
  ) async {
    final selectedValues = <_FilterValue>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSegmentedFilterBar<_FilterValue>(
            selectedValue: _FilterValue.all,
            options: const [
              POSSegmentedFilterOption(
                value: _FilterValue.all,
                label: 'All',
                count: 4,
                icon: Icons.list_alt_outlined,
              ),
              POSSegmentedFilterOption(
                value: _FilterValue.ready,
                label: 'Ready',
                count: 2,
                icon: Icons.check_circle_outline,
              ),
            ],
            onSelected: selectedValues.add,
          ),
        ),
      ),
    );

    expect(find.text('All (4)'), findsOneWidget);
    expect(find.text('Ready (2)'), findsOneWidget);
    expect(find.byIcon(Icons.list_alt_outlined), findsOneWidget);

    await tester.tap(find.text('Ready (2)'));
    await tester.pump();

    expect(selectedValues, [_FilterValue.ready]);
  });

  testWidgets('segmented filter bar hides when options are empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSegmentedFilterBar<_FilterValue>(
            selectedValue: _FilterValue.all,
            options: const [],
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(SegmentedButton<_FilterValue>), findsNothing);
  });
}

enum _FilterValue { all, ready }

String _filterLabel(_FilterValue value) {
  switch (value) {
    case _FilterValue.all:
      return 'All';
    case _FilterValue.ready:
      return 'Ready';
  }
}

int _filterCount(_FilterValue value) {
  switch (value) {
    case _FilterValue.all:
      return 4;
    case _FilterValue.ready:
      return 2;
  }
}

IconData _filterIcon(_FilterValue value) {
  switch (value) {
    case _FilterValue.all:
      return Icons.list_alt_outlined;
    case _FilterValue.ready:
      return Icons.check_circle_outline;
  }
}
