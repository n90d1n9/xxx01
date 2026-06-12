import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/dialog_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('DialogHeader renders reusable dialog chrome', (tester) async {
    const backgroundColor = Color(0xFFE0F2FE);
    const foregroundColor = Color(0xFF0369A1);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DialogHeader(
            icon: Icons.route_outlined,
            title: 'Channel strategy details',
            iconBackgroundColor: backgroundColor,
            iconForegroundColor: foregroundColor,
            trailing: Text('Beta'),
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.route_outlined));

    expect(find.text('Channel strategy details'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(icon.color, foregroundColor);
  });

  testWidgets('DialogHeader can derive tonal icon colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: DialogHeader(
            icon: Icons.view_quilt_outlined,
            title: 'Commerce profile',
            tone: VisualTone.primary,
            iconBackgroundAlpha: 0.42,
          ),
        ),
      ),
    );

    final badge = tester.widget<POSIconBadge>(find.byType(POSIconBadge));

    expect(find.text('Commerce profile'), findsOneWidget);
    expect(
      badge.backgroundColor,
      scheme.primaryContainer.withValues(alpha: 0.42),
    );
    expect(badge.foregroundColor, scheme.primary);
  });
}
