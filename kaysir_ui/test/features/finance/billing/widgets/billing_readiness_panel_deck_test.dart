import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_metric_strip.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_collection.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_panel_deck.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_panel_descriptor.dart';

void main() {
  testWidgets('BillingReadinessPanelDeck renders registered sources in order', (
    tester,
  ) async {
    await _pumpDeck(
      tester,
      BillingReadinessPanelDeck(
        registry: _registry,
        sources: const [
          _DemoSource(label: 'First', count: 2),
          _OtherSource(label: 'Second'),
          _DemoSource(label: 'Third', count: 5),
        ],
      ),
    );

    expect(find.text('Demo First'), findsOneWidget);
    expect(find.text('Other Second'), findsOneWidget);
    expect(find.text('Demo Third'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Demo First')).dy,
      lessThan(tester.getTopLeft(find.text('Other Second')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Other Second')).dy,
      lessThan(tester.getTopLeft(find.text('Demo Third')).dy),
    );
  });

  testWidgets(
    'BillingReadinessPanelDeck renders empty state when no source matches',
    (tester) async {
      await _pumpDeck(
        tester,
        BillingReadinessPanelDeck(
          registry: _registry,
          sources: const [_UnknownSource()],
          emptyState: const Text('No registered panels'),
        ),
      );

      expect(find.text('No registered panels'), findsOneWidget);
      expect(find.text('Demo readiness'), findsNothing);
      expect(find.text('Other readiness'), findsNothing);
    },
  );
}

Future<void> _pumpDeck(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 900, child: child)),
      ),
    ),
  );
}

final _registry = BillingReadinessPanelDescriptorRegistry(
  descriptors: [_demoDescriptor, _otherDescriptor],
);

final _demoProvider = BillingReadinessMetricProvider<_DemoSource>(
  id: 'deck.demo.metric',
  resolver: (source) {
    return BillingReadinessMetricCollection(
      items: [
        BillingReadinessMetric(
          label: 'Count',
          value: '${source.count}',
          icon: Icons.insights_outlined,
          color: const Color(0xFF2563EB),
        ),
      ],
    );
  },
);

final _otherProvider = BillingReadinessMetricProvider<_OtherSource>(
  id: 'deck.other.metric',
  resolver: (_) {
    return BillingReadinessMetricCollection(
      items: [
        BillingReadinessMetric(
          label: 'Other',
          value: '1',
          icon: Icons.category_outlined,
          color: const Color(0xFF059669),
        ),
      ],
    );
  },
);

final _demoDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_DemoSource>(
      id: 'deck.demo',
      metricProvider: _demoProvider,
      title: 'Demo readiness',
      summaryResolver: (source) => 'Demo ${source.label}',
      icon: Icons.insights_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: (source) => Text('Demo ${source.label} body'),
    );

final _otherDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_OtherSource>(
      id: 'deck.other',
      metricProvider: _otherProvider,
      title: 'Other readiness',
      summaryResolver: (source) => 'Other ${source.label}',
      icon: Icons.category_outlined,
      iconColor: const Color(0xFF059669),
      iconBackgroundColor: const Color(0xFFECFDF5),
      childBuilder: (source) => Text('Other ${source.label} body'),
    );

class _DemoSource {
  final String label;
  final int count;

  const _DemoSource({required this.label, required this.count});
}

class _OtherSource {
  final String label;

  const _OtherSource({required this.label});
}

class _UnknownSource {
  const _UnknownSource();
}
