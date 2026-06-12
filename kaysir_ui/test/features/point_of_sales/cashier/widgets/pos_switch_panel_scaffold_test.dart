import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_panel_scaffold.dart';

void main() {
  testWidgets('switch panel scaffold renders shared chrome and slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: POSSwitchPanelScaffold(
              title: 'POS modes',
              currentLabel: 'Kaysir Core',
              contextBanner: const Text('Current order'),
              filters: const Text('Mode filters'),
              body: ListView(children: const [Text('Quick Checkout')]),
            ),
          ),
        ),
      ),
    );

    expect(find.text('POS modes'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsOneWidget);
    expect(find.text('Current order'), findsOneWidget);
    expect(find.text('Mode filters'), findsOneWidget);
    expect(find.text('Quick Checkout'), findsOneWidget);
  });

  testWidgets('switch panel scaffold supports shrink wrapped bodies', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: POSSwitchPanelScaffold(
              title: 'Runtime packs',
              currentLabel: 'Core pack',
              shrinkWrap: true,
              body: Column(children: const [Text('Pack row')]),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Core pack'), findsOneWidget);
    expect(find.text('Pack row'), findsOneWidget);
  });
}
