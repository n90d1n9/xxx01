import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/health_signal_tile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/health_visuals.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tonal_icon_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  const promiseSignal = HealthSignal(
    id: 'promise_policy',
    label: 'Promise policy',
    value: '2 issues',
    detail: 'Targets need configuration',
    tone: HealthTone.warning,
  );

  testWidgets('HealthSignalTile renders health signal', (tester) async {
    await tester.pumpWorkspaceWidget(
      const HealthSignalTile(width: 320, signal: promiseSignal),
    );

    expect(find.text('Promise policy'), findsOneWidget);
    expect(find.text('2 issues'), findsOneWidget);
    expect(find.text('Targets need configuration'), findsOneWidget);
    expect(find.byIcon(Icons.rule_folder_outlined), findsOneWidget);
    expect(find.byType(InsetSurface), findsOneWidget);
    expect(find.byType(MetricBlock), findsOneWidget);
    expect(find.byType(TonalIconBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('healthSignalIcon falls back for custom signal', () {
    expect(healthSignalIcon('custom_health_signal'), Icons.insights_outlined);
  });
}
