import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/health_panel.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';

void main() {
  testWidgets('HealthPanel renders readiness summary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 900, child: HealthPanel(health: _health())),
        ),
      ),
    );

    expect(find.text('Operational review needed'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Priority actions'), findsOneWidget);
    expect(find.text('Channel coverage'), findsOneWidget);
    expect(find.text('Promise policy'), findsOneWidget);
    expect(find.text('Order attention'), findsOneWidget);
    expect(find.text('2 issues'), findsOneWidget);
    expect(find.text('3 reviews'), findsOneWidget);
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(find.byType(PanelHeader), findsOneWidget);
    expect(find.byType(PanelSurface), findsOneWidget);
    expect(find.byType(InsetSurface), findsNWidgets(6));
    expect(find.byType(MetricBlock), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });
}

HealthSummary _health() {
  return const HealthSummary(
    tone: HealthTone.warning,
    title: 'Operational review needed',
    message: '2 promise policy issues and 3 order reviews need attention.',
    moduleIssueCount: 0,
    actionRuleIssueCount: 0,
    promisePolicyIssueCount: 2,
    orderAttentionCount: 3,
    criticalOrderAttentionCount: 0,
    signals: [
      HealthSignal(
        id: 'profiles',
        label: 'Profiles',
        value: 'Ready',
        detail: 'Product profile registry healthy',
        tone: HealthTone.success,
      ),
      HealthSignal(
        id: 'modules',
        label: 'Modules',
        value: 'Ready',
        detail: 'Navigation registry healthy',
        tone: HealthTone.success,
      ),
      HealthSignal(
        id: 'actions',
        label: 'Priority actions',
        value: 'Ready',
        detail: 'Action registry healthy',
        tone: HealthTone.success,
      ),
      HealthSignal(
        id: 'channel_coverage',
        label: 'Channel coverage',
        value: 'Ready',
        detail: 'Channel playbook healthy',
        tone: HealthTone.success,
      ),
      HealthSignal(
        id: 'promise_policy',
        label: 'Promise policy',
        value: '2 issues',
        detail: 'Targets need configuration',
        tone: HealthTone.warning,
      ),
      HealthSignal(
        id: 'order_attention',
        label: 'Order attention',
        value: '3 reviews',
        detail: 'Fulfillment queue needs action',
        tone: HealthTone.warning,
      ),
    ],
  );
}
