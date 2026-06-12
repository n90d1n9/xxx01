import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_pill.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('MetricPill preserves default pill chrome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricPill(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
            value: '12',
          ),
        ),
      ),
    );

    final pill = tester.widget<POSMetricPill>(find.byType(POSMetricPill));
    expect(pill.icon, isA<Icon>());
    expect(pill.label, 'Orders');
    expect(pill.value, '12');
    expect(pill.backgroundColor, isNull);
    expect(pill.foregroundColor, isNull);
    expect(find.text('Orders | 12'), findsOneWidget);
  });

  testWidgets('MetricPill accepts precomputed colors', (tester) async {
    const colors = ToneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricPill(
            icon: Icon(Icons.check_circle_outline),
            label: 'Ready',
            colors: colors,
            backgroundAlpha: 0.1,
          ),
        ),
      ),
    );

    final pill = tester.widget<POSMetricPill>(find.byType(POSMetricPill));
    expect(pill.backgroundColor, colors.foregroundTint(alpha: 0.1));
    expect(pill.foregroundColor, colors.foreground);
  });

  testWidgets('MetricPill can use container backgrounds', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: MetricPill(
            icon: Icon(Icons.rule_folder_outlined),
            label: 'Policy',
            tone: VisualTone.primary,
            backgroundSource: ToneBackgroundSource.container,
            backgroundAlpha: 0.42,
          ),
        ),
      ),
    );

    final pill = tester.widget<POSMetricPill>(find.byType(POSMetricPill));
    expect(
      pill.backgroundColor,
      scheme.primaryContainer.withValues(alpha: 0.42),
    );
    expect(pill.foregroundColor, scheme.primary);
  });
}
