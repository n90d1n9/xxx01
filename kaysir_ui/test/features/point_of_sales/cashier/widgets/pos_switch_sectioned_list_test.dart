import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_sectioned_list.dart';

void main() {
  testWidgets('switch sectioned list renders headers and children', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: POSSwitchSectionedList<_SwitchSection>(
              sections: const [
                _SwitchSection('Kaysir Core', ['Quick Checkout']),
                _SwitchSection('Online', ['Online Pack']),
              ],
              filterActive: false,
              filteredTitle: 'No matching options',
              emptyTitle: 'No options available',
              headerBuilder:
                  (context, section) =>
                      Text('${section.title} (${section.children.length})'),
              childrenBuilder:
                  (context, section) =>
                      section.children.map((label) => Text(label)),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kaysir Core (1)'), findsOneWidget);
    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Online (1)'), findsOneWidget);
    expect(find.text('Online Pack'), findsOneWidget);
  });

  testWidgets('switch sectioned list renders unfiltered empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 180,
            child: POSSwitchSectionedList<_SwitchSection>(
              sections: const [],
              filterActive: false,
              filteredTitle: 'No matching options',
              emptyTitle: 'No options available',
              headerBuilder: (context, section) => Text(section.title),
              childrenBuilder: (context, section) => const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('No options available'), findsOneWidget);
    expect(find.text('No matching options'), findsNothing);
  });

  testWidgets('switch sectioned list renders filtered empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 180,
            child: POSSwitchSectionedList<_SwitchSection>(
              sections: const [],
              filterActive: true,
              filteredTitle: 'No matching options',
              emptyTitle: 'No options available',
              headerBuilder: (context, section) => Text(section.title),
              childrenBuilder: (context, section) => const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('No matching options'), findsOneWidget);
    expect(find.text('No options available'), findsNothing);
  });
}

class _SwitchSection {
  final String title;
  final List<String> children;

  const _SwitchSection(this.title, this.children);
}
