import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_pill.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/registry_source_pill.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('RegistrySourcePill renders ready source', (tester) async {
    await tester.pumpWorkspaceWidget(
      const RegistrySourcePill(
        summary: RegistrySourceSummary(
          source: RegistryIssueSource.profile,
          count: 0,
        ),
      ),
    );

    expect(find.byType(MetricPill), findsOneWidget);
    expect(find.byType(POSMetricPill), findsOneWidget);
    expect(find.text('Profiles | Ready'), findsOneWidget);
    expect(find.byIcon(Icons.view_quilt_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegistrySourcePill renders issue count', (tester) async {
    await tester.pumpWorkspaceWidget(
      const RegistrySourcePill(
        summary: RegistrySourceSummary(
          source: RegistryIssueSource.module,
          count: 2,
        ),
      ),
    );

    expect(find.text('Modules | 2'), findsOneWidget);
    expect(find.byIcon(Icons.extension_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
