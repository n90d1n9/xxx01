import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_metric_strip.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_collection.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_panel_descriptor.dart';

void main() {
  testWidgets('readiness panel descriptor builds provider-backed panel', (
    tester,
  ) async {
    final registry = BillingReadinessPanelDescriptorRegistry(
      descriptors: [_earlyDescriptor],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: registry.build(
              'demo.early',
              const _DemoSource(readyCount: 4),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Early readiness'), findsOneWidget);
    expect(find.text('Ready count 4'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Early body'), findsOneWidget);
  });

  test('readiness panel registry filters and sorts descriptors', () {
    final registry = BillingReadinessPanelDescriptorRegistry(
      descriptors: [_lateDescriptor, _otherDescriptor, _earlyDescriptor],
    );

    expect(registry.descriptorIds, ['demo.other', 'demo.early', 'demo.late']);
    expect(
      registry
          .descriptorsForSource(const _DemoSource(readyCount: 1))
          .map((descriptor) => descriptor.id),
      ['demo.early', 'demo.late'],
    );
    expect(registry.buildForSource(const _OtherSource()), hasLength(1));
  });

  test(
    'readiness panel registry supports hidden descriptors and extensions',
    () {
      final registry = BillingReadinessPanelDescriptorRegistry(
        descriptors: [_earlyDescriptor, _lateDescriptor],
      ).extend(
        hiddenDescriptorIds: ['demo.early'],
        extensions: [_customDescriptor],
      );

      expect(registry.descriptorIds, ['demo.custom', 'demo.late']);
      expect(registry.contains('demo.early'), isFalse);
    },
  );

  test('readiness panel registry rejects invalid descriptors', () {
    expect(
      () => BillingReadinessPanelDescriptorRegistry(
        descriptors: [_earlyDescriptor, _earlyDescriptor],
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => BillingReadinessPanelDescriptorRegistry(
        descriptors: [
          BillingReadinessMetricProviderPanelDescriptor<_DemoSource>(
            id: ' ',
            metricProvider: _demoProvider,
            title: 'Blank',
            summaryResolver: (_) => 'Blank',
            icon: Icons.warning_outlined,
            iconColor: const Color(0xFFDC2626),
            iconBackgroundColor: const Color(0xFFFEE2E2),
            childBuilder: (_) => const Text('Blank body'),
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('readiness panel descriptor rejects unsupported source models', () {
    final registry = BillingReadinessPanelDescriptorRegistry(
      descriptors: [_earlyDescriptor],
    );

    expect(
      () => registry.build('demo.early', const _OtherSource()),
      throwsA(isA<ArgumentError>()),
    );
  });
}

final _demoProvider = BillingReadinessMetricProvider<_DemoSource>(
  id: 'demo.metric',
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

final _earlyDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_DemoSource>(
      id: 'demo.early',
      priority: 100,
      metricProvider: _demoProvider,
      title: 'Early readiness',
      summaryResolver: (source) => 'Ready count ${source.readyCount}',
      icon: Icons.insights_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: (_) => const Text('Early body'),
    );

final _lateDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_DemoSource>(
      id: 'demo.late',
      priority: 200,
      metricProvider: _demoProvider,
      title: 'Late readiness',
      summaryResolver: (source) => 'Ready count ${source.readyCount}',
      icon: Icons.pending_actions_outlined,
      iconColor: const Color(0xFFD97706),
      iconBackgroundColor: const Color(0xFFFFF7ED),
      childBuilder: (_) => const Text('Late body'),
    );

final _customDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_DemoSource>(
      id: 'demo.custom',
      priority: 50,
      metricProvider: _demoProvider,
      title: 'Custom readiness',
      summaryResolver: (source) => 'Ready count ${source.readyCount}',
      icon: Icons.auto_graph_outlined,
      iconColor: const Color(0xFF7C3AED),
      iconBackgroundColor: const Color(0xFFF5F3FF),
      childBuilder: (_) => const Text('Custom body'),
    );

final _otherProvider = BillingReadinessMetricProvider<_OtherSource>(
  id: 'demo.other.metric',
  resolver: (_) {
    return BillingReadinessMetricCollection(
      items: [
        BillingReadinessMetric(
          label: 'Other',
          value: '1',
          icon: Icons.category_outlined,
          color: const Color(0xFF475569),
        ),
      ],
    );
  },
);

final _otherDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<_OtherSource>(
      id: 'demo.other',
      priority: 50,
      metricProvider: _otherProvider,
      title: 'Other readiness',
      summaryResolver: (_) => 'Other source',
      icon: Icons.category_outlined,
      iconColor: const Color(0xFF475569),
      iconBackgroundColor: const Color(0xFFF8FAFC),
      childBuilder: (_) => const Text('Other body'),
    );

class _DemoSource {
  final int readyCount;

  const _DemoSource({required this.readyCount});
}

class _OtherSource {
  const _OtherSource();
}
