import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  testWidgets('card metric row renders children with operational spacing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RestaurantCardMetricRow(
            children: [
              RestaurantMiniStat(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                value: '18',
              ),
              RestaurantMiniStat(
                icon: Icons.timer_outlined,
                label: 'Prep',
                value: '7m',
              ),
            ],
          ),
        ),
      ),
    );

    final row = tester.widget<RestaurantCardMetricRow>(
      find.byType(RestaurantCardMetricRow),
    );

    expect(row.spacing, 18);
    expect(row.runSpacing, 12);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Prep'), findsOneWidget);
    expect(find.text('7m'), findsOneWidget);
  });

  testWidgets('card header renders title copy and trailing controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCardHeader(
            icon: Icons.table_restaurant_outlined,
            foregroundColor: Colors.teal.shade700,
            backgroundColor: Colors.teal.shade50,
            title: 'Main Floor',
            subtitle: 'North dining room',
            trailing: const Text('Busy'),
          ),
        ),
      ),
    );

    expect(find.byType(RestaurantCardHeader), findsOneWidget);
    expect(find.byIcon(Icons.table_restaurant_outlined), findsOneWidget);
    expect(find.text('Main Floor'), findsOneWidget);
    expect(find.text('North dining room'), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
  });

  testWidgets('card controls render compact chips and actions', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCardChipRow(
            children: [
              const RestaurantCardChip(
                icon: Icons.label_outline_rounded,
                label: 'Floor',
              ),
              RestaurantCardActionButton(
                icon: Icons.check_rounded,
                label: 'Send floor lead',
                foregroundColor: Colors.red.shade700,
                backgroundColor: Colors.red.shade50,
                onPressed: () => tapped = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(RestaurantCardChipRow), findsOneWidget);
    final row = tester.widget<RestaurantCardChipRow>(
      find.byType(RestaurantCardChipRow),
    );

    expect(row.spacing, 8);
    expect(row.runSpacing, 8);
    expect(find.byType(RestaurantCardChip), findsOneWidget);
    expect(find.byIcon(Icons.label_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Floor'), findsOneWidget);
    expect(find.text('Send floor lead'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Send floor lead'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
