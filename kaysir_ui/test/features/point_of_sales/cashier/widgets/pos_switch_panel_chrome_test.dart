import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_panel_chrome.dart';

void main() {
  testWidgets('switch panel header renders title and current selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ChromeHost(
        child: POSSwitchPanelHeader(
          title: 'Runtime packs',
          currentLabel: 'Kaysir Core',
        ),
      ),
    );

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsOneWidget);
  });

  testWidgets('switch panel empty state switches copy for active filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _ChromeHost(
        child: POSSwitchPanelEmptyState(
          filterActive: false,
          filteredTitle: 'No matching modes',
          emptyTitle: 'No modes available',
        ),
      ),
    );

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('No modes available'), findsOneWidget);
    expect(find.text('No matching modes'), findsNothing);

    await tester.pumpWidget(
      const _ChromeHost(
        child: POSSwitchPanelEmptyState(
          filterActive: true,
          filteredTitle: 'No matching modes',
          emptyTitle: 'No modes available',
        ),
      ),
    );

    expect(find.text('No matching modes'), findsOneWidget);
    expect(find.text('No modes available'), findsNothing);
  });
}

class _ChromeHost extends StatelessWidget {
  final Widget child;

  const _ChromeHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
