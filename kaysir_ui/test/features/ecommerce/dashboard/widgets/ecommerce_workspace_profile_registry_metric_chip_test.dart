import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_metric_chip.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ProfileRegistryMetricChip renders metric chip', (tester) async {
    await tester.pumpWorkspaceWidget(
      const ProfileRegistryMetricChip(
        icon: Icons.extension_outlined,
        label: '6 modules',
      ),
    );

    expect(find.byType(IconLabelChip), findsOneWidget);
    expect(find.text('6 modules'), findsOneWidget);
    expect(find.byIcon(Icons.extension_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
