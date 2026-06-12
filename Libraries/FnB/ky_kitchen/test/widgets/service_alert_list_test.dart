import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('service alert list orders critical guidance first', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: KitchenServiceAlertList(
              alerts: [
                FnbServiceAlert(
                  type: FnbServiceAlertType.dietary,
                  label: 'No shellfish',
                ),
                FnbServiceAlert(
                  type: FnbServiceAlertType.allergy,
                  label: 'Peanut allergy',
                  description: 'Use clean utensils.',
                  critical: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Allergy: Peanut allergy'), findsOneWidget);
    expect(find.text('Use clean utensils.'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Dietary: No shellfish'), findsOneWidget);

    final allergyTop = tester
        .getTopLeft(find.text('Allergy: Peanut allergy'))
        .dy;
    final dietaryTop = tester.getTopLeft(find.text('Dietary: No shellfish')).dy;

    expect(allergyTop, lessThan(dietaryTop));
  });

  testWidgets('service alert list renders empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: KitchenServiceAlertList(alerts: [])),
      ),
    );

    expect(find.text('No service alerts.'), findsOneWidget);
  });
}
