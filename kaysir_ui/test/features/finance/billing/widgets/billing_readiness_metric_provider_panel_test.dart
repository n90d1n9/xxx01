import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_metric_strip.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_collection.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_provider_panel.dart';

void main() {
  testWidgets('BillingReadinessMetricProviderPanel resolves metrics and body', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 780,
            child: BillingReadinessMetricProviderPanel<_DemoSource>(
              source: const _DemoSource(readyCount: 7),
              metricProvider: _demoProvider,
              title: 'Demo readiness',
              summary: 'Provider backed metrics',
              icon: Icons.insights_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBackgroundColor: const Color(0xFFEFF6FF),
              trailing: const Text('Tail'),
              child: const Text('Panel body'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Demo readiness'), findsOneWidget);
    expect(find.text('Provider backed metrics'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Tail'), findsOneWidget);
    expect(find.text('Panel body'), findsOneWidget);
  });
}

final _demoProvider = BillingReadinessMetricProvider<_DemoSource>(
  id: 'demo.readiness',
  resolver: (source) {
    return BillingReadinessMetricCollection(
      items: [
        BillingReadinessMetric(
          label: 'Ready',
          value: '${source.readyCount}',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF059669),
        ),
      ],
    );
  },
);

class _DemoSource {
  final int readyCount;

  const _DemoSource({required this.readyCount});
}
