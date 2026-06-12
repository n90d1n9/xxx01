import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tonal_icon_badge.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/tone.dart';

void main() {
  testWidgets('TonalIconBadge can derive tonal colors', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: TonalIconBadge(
            icon: Icons.receipt_long_outlined,
            tone: VisualTone.primary,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TonalIconBadge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.receipt_long_outlined));

    expect(container.constraints?.maxWidth, 34);
    expect(container.constraints?.maxHeight, 34);
    expect(decoration.color, scheme.primary.withValues(alpha: 0.12));
    expect(icon.color, scheme.primary);
    expect(icon.size, 19);
  });

  testWidgets('TonalIconBadge accepts precomputed colors', (tester) async {
    const colors = ToneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TonalIconBadge(
            icon: Icons.check_circle_outline,
            colors: colors,
            backgroundAlpha: 0.1,
            size: 30,
            iconSize: 17,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TonalIconBadge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));

    expect(container.constraints?.maxWidth, 30);
    expect(container.constraints?.maxHeight, 30);
    expect(decoration.color, colors.foregroundTint(alpha: 0.1));
    expect(icon.color, colors.foreground);
    expect(icon.size, 17);
  });

  testWidgets('TonalIconBadge can use container backgrounds', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: TonalIconBadge(
            icon: Icons.view_quilt_outlined,
            tone: VisualTone.secondary,
            backgroundSource: ToneBackgroundSource.container,
            backgroundAlpha: 0.36,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(TonalIconBadge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    final icon = tester.widget<Icon>(find.byIcon(Icons.view_quilt_outlined));

    expect(decoration.color, scheme.secondaryContainer.withValues(alpha: 0.36));
    expect(icon.color, scheme.secondary);
  });
}
