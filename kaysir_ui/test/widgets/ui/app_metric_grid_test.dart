import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('renders metric items with shared cards', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMetricGrid(
            maxColumns: 3,
            metrics: [
              AppMetricGridItem(
                title: 'Customers',
                value: '42',
                icon: Icons.people_alt_rounded,
                accentColor: Colors.indigo,
              ),
              AppMetricGridItem(
                title: 'Open Balance',
                value: r'$12,400',
                icon: Icons.account_balance_wallet_rounded,
                accentColor: Colors.blue,
              ),
              AppMetricGridItem(
                title: 'Overdue',
                value: r'$980',
                helper: '2 customers',
                icon: Icons.warning_rounded,
                accentColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricCard), findsNWidgets(3));
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text(r'$12,400'), findsOneWidget);
    expect(find.text('2 customers'), findsOneWidget);
  });

  testWidgets('renders nothing for empty metric lists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppMetricGrid(metrics: []))),
    );

    expect(find.byType(AppMetricCard), findsNothing);
  });
}
