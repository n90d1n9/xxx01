import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';

void main() {
  testWidgets('inventory separated list renders indexed items with gaps', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventorySeparatedList<String>(
            items: const ['Alpha', 'Beta', 'Gamma'],
            spacing: 12,
            itemBuilder: (context, item, index) {
              return Text('$index: $item');
            },
          ),
        ),
      ),
    );

    expect(find.text('0: Alpha'), findsOneWidget);
    expect(find.text('1: Beta'), findsOneWidget);
    expect(find.text('2: Gamma'), findsOneWidget);
    expect(_gapCount(tester, 12), 2);
  });

  testWidgets('inventory separated list handles empty items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventorySeparatedList<String>(
            items: const [],
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Text), findsNothing);
    expect(_gapCount(tester, 10), 0);
  });
}

int _gapCount(WidgetTester tester, double height) {
  return tester
      .widgetList<SizedBox>(find.byType(SizedBox))
      .where((box) => box.height == height)
      .length;
}
