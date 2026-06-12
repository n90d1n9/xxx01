import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/widgets/admin_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';

void main() {
  testWidgets('renders metric cards from reusable grid items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: AdminMetricGrid(
              metrics: [
                AdminMetricGridItem(
                  title: 'Transactions',
                  value: '127K',
                  change: '+ 2% than last week',
                  icon: Icons.receipt_long_outlined,
                  accentColor: Colors.blue,
                ),
                AdminMetricGridItem(
                  title: 'Growth',
                  value: '19.6%',
                  change: '- 4.9% than last week',
                  icon: Icons.show_chart,
                  accentColor: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricCard), findsNWidgets(2));
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
  });

  testWidgets('renders nothing when no metrics are supplied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminMetricGrid(metrics: []))),
    );

    expect(find.byType(AppMetricCard), findsNothing);
  });
}
