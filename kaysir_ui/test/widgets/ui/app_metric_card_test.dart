import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('renders metric content and positive trend affordance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMetricCard(
            title: 'Transactions',
            value: '127K',
            change: '+ 2% than last week',
            icon: Icons.receipt_long_outlined,
            accentColor: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.byType(AppSurface), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('127K'), findsOneWidget);
    expect(find.text('+ 2%'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('renders negative trend affordance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMetricCard(
            title: 'Growth',
            value: '19.6%',
            change: '- 4.9% than last week',
            icon: Icons.show_chart,
            accentColor: Colors.purple,
          ),
        ),
      ),
    );

    expect(find.text('- 4.9%'), findsOneWidget);
    expect(find.byIcon(Icons.trending_down), findsOneWidget);
  });

  testWidgets('renders metric helper without trend affordance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppMetricCard(
            title: 'Overdue',
            value: r'$8,240.00',
            helper: '3 customers',
            icon: Icons.warning_rounded,
            accentColor: Colors.red,
          ),
        ),
      ),
    );

    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text(r'$8,240.00'), findsOneWidget);
    expect(find.text('3 customers'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsNothing);
    expect(find.byIcon(Icons.trending_down), findsNothing);
  });
}
