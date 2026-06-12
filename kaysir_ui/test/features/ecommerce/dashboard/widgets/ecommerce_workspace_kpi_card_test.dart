import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/kpi_card.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tonal_icon_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('KpiCard renders prominent metric chrome', (tester) async {
    await tester.pumpWorkspaceWidget(
      const KpiCard(
        width: 280,
        label: 'Ops alerts',
        value: '3',
        detail: '2 policy review',
        icon: Icons.crisis_alert_outlined,
        tone: KpiTone.danger,
      ),
    );

    expect(find.text('Ops alerts'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2 policy review'), findsOneWidget);
    expect(find.byType(TonalIconBadge), findsOneWidget);
    expect(find.byType(MetricBlock), findsOneWidget);
    expect(find.byType(PanelSurface), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
