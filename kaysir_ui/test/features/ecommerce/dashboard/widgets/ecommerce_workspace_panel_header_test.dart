import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_header.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('PanelHeader renders copy and trailing action', (tester) async {
    const iconBackgroundColor = Color(0xFFE0F2FE);
    const iconForegroundColor = Color(0xFF0369A1);
    const subtitleColor = Color(0xFFB45309);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PanelHeader(
            icon: Icons.route_outlined,
            title: 'Channel strategy',
            subtitle: '2 coverage gaps',
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            subtitleColor: subtitleColor,
            trailing: Text('Inspect'),
          ),
        ),
      ),
    );

    expect(find.text('Channel strategy'), findsOneWidget);
    expect(find.text('2 coverage gaps'), findsOneWidget);
    expect(find.text('Inspect'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.route_outlined));
    final subtitle = tester.widget<Text>(find.text('2 coverage gaps'));

    expect(icon.color, iconForegroundColor);
    expect(subtitle.style?.color, subtitleColor);
  });

  testWidgets('PanelHeader can derive tonal icon colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: PanelHeader(
            icon: Icons.bolt_outlined,
            title: 'Priority actions',
            subtitle: 'Continue the active basket.',
            tone: VisualTone.primary,
            iconBackgroundAlpha: 0.18,
          ),
        ),
      ),
    );

    final badge = tester.widget<POSIconBadge>(find.byType(POSIconBadge));

    expect(find.text('Priority actions'), findsOneWidget);
    expect(
      badge.backgroundColor,
      scheme.primaryContainer.withValues(alpha: 0.18),
    );
    expect(badge.foregroundColor, scheme.primary);
  });
}
