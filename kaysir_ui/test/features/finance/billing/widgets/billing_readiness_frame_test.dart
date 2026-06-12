import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_frame.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_metric_strip.dart';

void main() {
  testWidgets('BillingReadinessPanelScaffold renders header metrics and body', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingReadinessPanelScaffold(
            title: 'Launch queue',
            summary: '2 tasks ready.',
            icon: Icons.queue_outlined,
            iconColor: Color(0xFF2563EB),
            iconBackgroundColor: Color(0xFFEFF6FF),
            metrics: [
              BillingReadinessMetric(
                label: 'Ready',
                value: '2',
                icon: Icons.play_circle_outline,
                color: Color(0xFF059669),
              ),
            ],
            child: Text('Queue body'),
          ),
        ),
      ),
    );

    expect(find.text('Launch queue'), findsOneWidget);
    expect(find.text('2 tasks ready.'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Queue body'), findsOneWidget);
    expect(find.byIcon(Icons.queue_outlined), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
  });

  testWidgets('BillingReadinessPanelHeader renders summary and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingReadinessPanelHeader(
            title: 'Launch readiness',
            summary: '3 actions ready.',
            icon: Icons.rocket_launch_outlined,
            iconColor: Color(0xFF059669),
            iconBackgroundColor: Color(0xFFECFDF5),
            trailing: Text('Ready'),
          ),
        ),
      ),
    );

    expect(find.text('Launch readiness'), findsOneWidget);
    expect(find.text('3 actions ready.'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
  });

  testWidgets('BillingReadinessStatusIcon supports custom sizing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingReadinessStatusIcon(
            icon: Icons.route_outlined,
            color: Color(0xFF2563EB),
            backgroundColor: Color(0xFFEFF6FF),
            size: 44,
            iconSize: 26,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(BillingReadinessStatusIcon)),
      const Size(44, 44),
    );
    expect(find.byIcon(Icons.route_outlined), findsOneWidget);
  });
}
