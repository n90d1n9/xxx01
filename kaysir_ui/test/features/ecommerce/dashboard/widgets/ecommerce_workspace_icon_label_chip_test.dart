import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/chip_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  testWidgets('IconLabelChip renders reusable icon chip', (tester) async {
    const foreground = Color(0xff14532d);
    const background = Color(0xffdcfce7);
    const border = Color(0xff86efac);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IconLabelChip(
            icon: Icons.hub_outlined,
            label: '6 channels',
            foregroundColor: foreground,
            backgroundColor: background,
            borderColor: border,
          ),
        ),
      ),
    );

    expect(find.byType(ChipSurface), findsOneWidget);
    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
    expect(find.text('6 channels'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.hub_outlined));
    final label = tester.widget<Text>(find.text('6 channels'));
    expect(icon.color, foreground);
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.color, foreground);
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(tester.takeException(), isNull);
  });

  testWidgets('IconLabelChip can derive tonal colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: IconLabelChip(
            icon: Icons.storefront_outlined,
            label: 'Marketplace',
            tone: VisualTone.secondary,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(ChipSurface),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.storefront_outlined));
    final label = tester.widget<Text>(find.text('Marketplace'));

    expect(decoration.color, scheme.secondaryContainer.withValues(alpha: 0.28));
    expect(
      decoration.border?.top.color,
      scheme.secondary.withValues(alpha: 0.16),
    );
    expect(icon.color, scheme.secondary);
    expect(label.style?.color, scheme.secondary);
  });
}
