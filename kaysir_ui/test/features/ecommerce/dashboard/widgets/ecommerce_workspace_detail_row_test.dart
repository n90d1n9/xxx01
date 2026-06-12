import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('DetailRow renders reusable media row chrome', (tester) async {
    const foreground = Color(0xff126a4a);
    const background = Color(0xffdff8ec);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailRow(
            icon: Icons.route_outlined,
            title: 'Web store',
            description: 'Online storefront with payment and fulfillment.',
            iconBackgroundColor: background,
            iconForegroundColor: foreground,
            footer: Text('Fulfillment: Pickup, Delivery'),
          ),
        ),
      ),
    );

    expect(find.text('Web store'), findsOneWidget);
    expect(
      find.text('Online storefront with payment and fulfillment.'),
      findsOneWidget,
    );
    expect(find.text('Fulfillment: Pickup, Delivery'), findsOneWidget);

    final badge = tester.widget<POSIconBadge>(find.byType(POSIconBadge));
    expect(badge.icon, Icons.route_outlined);
    expect(badge.backgroundColor, background);
    expect(badge.foregroundColor, foreground);

    final title = tester.widget<Text>(find.text('Web store'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(title.style?.fontWeight, FontWeight.w900);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DetailRow can render standard card titles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailRow(
            icon: Icons.storefront_outlined,
            title: ' POS',
            description: 'Checkout and cart operations.',
            titleScale: DetailRowTitleScale.standard,
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text(' POS'));
    final inheritedTheme = Theme.of(tester.element(find.text(' POS')));
    expect(
      title.style?.fontSize,
      inheritedTheme.textTheme.titleMedium?.fontSize,
    );
    expect(title.style?.fontWeight, FontWeight.w900);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DetailRow accepts precomputed icon colors', (tester) async {
    const colors = ToneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailRow(
            icon: Icons.check_circle_outline,
            title: 'Coverage healthy',
            description: 'All required channels are covered.',
            iconColors: colors,
            iconBadgeSize: 30,
            iconSize: 17,
          ),
        ),
      ),
    );

    final badge = tester.widget<POSIconBadge>(find.byType(POSIconBadge));
    expect(badge.backgroundColor, colors.foregroundTint());
    expect(badge.foregroundColor, colors.foreground);
    expect(badge.size, 30);
    expect(badge.iconSize, 17);
  });

  testWidgets('DetailRow can derive container icon colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: DetailRow(
            icon: Icons.route_outlined,
            title: 'Sales channel',
            description: 'Marketplace, web, and assisted commerce.',
            iconTone: VisualTone.success,
            iconBackgroundSource: ToneBackgroundSource.container,
            iconBackgroundAlpha: 0.32,
          ),
        ),
      ),
    );

    final badge = tester.widget<POSIconBadge>(find.byType(POSIconBadge));
    expect(
      badge.backgroundColor,
      scheme.tertiaryContainer.withValues(alpha: 0.32),
    );
    expect(badge.foregroundColor, scheme.tertiary);
  });
}
