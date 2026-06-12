import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_popup_menu.dart';

void main() {
  testWidgets('switch popup menu builder creates grouped entries', (
    tester,
  ) async {
    final entries = buildPOSSwitchPopupMenuEntries<String, _SwitchSection>(
      title: const Text('Switches'),
      sections: const [
        _SwitchSection(title: 'Core', items: ['Counter', 'Compact']),
        _SwitchSection(title: 'Online', items: ['Web']),
      ],
      sectionHeaderBuilder: (section) => Text(section.title),
      itemEntriesBuilder:
          (section) => section.items.map((item) {
            return CheckedPopupMenuItem<String>(
              value: item,
              checked: item == 'Counter',
              child: Text(item),
            );
          }),
    );

    expect(entries, hasLength(8));
    expect(entries.whereType<PopupMenuDivider>(), hasLength(2));
    expect(entries.whereType<CheckedPopupMenuItem<String>>(), hasLength(3));
  });

  testWidgets('switch popup menu button supports labeled selection', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchPopupMenuButton<String>(
            tooltip: 'Switch mode',
            icon: const Icon(Icons.apps_outlined),
            label: const Text('Current mode'),
            initialValue: 'current',
            onSelected: (value) => selected = value,
            itemBuilder:
                (context) => const [
                  CheckedPopupMenuItem<String>(
                    value: 'current',
                    checked: true,
                    child: Text('Current mode'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'next',
                    checked: false,
                    child: Text('Next mode'),
                  ),
                ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Current mode').first);
    await tester.pumpAndSettle();

    expect(find.text('Next mode'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckedPopupMenuItem<String> && widget.value == 'next',
      ),
    );
    await tester.pumpAndSettle();

    expect(selected, 'next');
  });

  testWidgets('adaptive switch menu uses compact trigger below breakpoint', (
    tester,
  ) async {
    var compactPresses = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchAdaptiveMenuButton<String>(
            tooltip: 'Switch runtime',
            icon: const Icon(Icons.apps_outlined),
            label: const Text('Current pack'),
            viewportWidth: 600,
            onCompactPressed: () => compactPresses += 1,
            onSelected: (_) {},
            itemBuilder: (_) => const [],
          ),
        ),
      ),
    );

    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.text('Current pack'), findsOneWidget);

    await tester.tap(find.text('Current pack'));
    await tester.pump();

    expect(compactPresses, 1);
  });

  testWidgets('adaptive switch menu opens popup on expanded widths', (
    tester,
  ) async {
    var compactPresses = 0;
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSwitchAdaptiveMenuButton<String>(
            tooltip: 'Switch runtime',
            icon: const Icon(Icons.apps_outlined),
            viewportWidth: 900,
            onCompactPressed: () => compactPresses += 1,
            initialValue: 'current',
            onSelected: (value) => selected = value,
            itemBuilder:
                (_) => const [
                  CheckedPopupMenuItem<String>(
                    value: 'current',
                    checked: true,
                    child: Text('Current pack'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'next',
                    checked: false,
                    child: Text('Next pack'),
                  ),
                ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.apps_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Next pack'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckedPopupMenuItem<String> && widget.value == 'next',
      ),
    );
    await tester.pumpAndSettle();

    expect(compactPresses, 0);
    expect(selected, 'next');
  });
}

class _SwitchSection {
  final String title;
  final List<String> items;

  const _SwitchSection({required this.title, required this.items});
}
