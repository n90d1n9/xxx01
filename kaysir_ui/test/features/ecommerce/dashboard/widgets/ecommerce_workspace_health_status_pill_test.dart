import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/health_status_pill.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/health_visuals.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_pill.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('HealthStatusPill renders review state', (tester) async {
    await tester.pumpWorkspaceWidget(
      const HealthStatusPill(tone: HealthTone.warning),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.byIcon(Icons.manage_search_outlined), findsOneWidget);
    expect(find.byType(MetricPill), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('healthStatusLabel maps danger state', () {
    expect(healthStatusLabel(HealthTone.danger), 'Critical');
    expect(healthStatusIcon(HealthTone.danger), Icons.priority_high_outlined);
  });
}
