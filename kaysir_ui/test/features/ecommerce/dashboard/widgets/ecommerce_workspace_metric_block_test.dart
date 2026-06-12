import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('MetricBlock renders reusable metric copy', (tester) async {
    await tester.pumpWorkspaceWidget(
      const MetricBlock(
        label: 'Net revenue',
        value: 'Rp0',
        detail: 'Rp0 avg',
        scale: MetricBlockScale.prominent,
      ),
    );

    expect(find.text('Net revenue'), findsOneWidget);
    expect(find.text('Rp0'), findsOneWidget);
    expect(find.text('Rp0 avg'), findsOneWidget);

    final label = tester.widget<Text>(find.text('Net revenue'));
    final value = tester.widget<Text>(find.text('Rp0'));
    final detail = tester.widget<Text>(find.text('Rp0 avg'));

    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(value.style?.fontWeight, FontWeight.w900);
    expect(detail.style?.fontWeight, FontWeight.w700);
    expect(tester.takeException(), isNull);
  });
}
