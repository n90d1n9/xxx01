import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('renders title, subtitle, icon, trailing, and child', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppContentPanel(
            title: 'Panel title',
            subtitle: 'Panel subtitle',
            leadingIcon: Icons.receipt_long_rounded,
            trailing: Text('12 shown'),
            child: Text('Panel child'),
          ),
        ),
      ),
    );

    expect(find.byType(AppSurface), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    expect(find.text('Panel title'), findsOneWidget);
    expect(find.text('Panel subtitle'), findsOneWidget);
    expect(find.text('12 shown'), findsOneWidget);
    expect(find.text('Panel child'), findsOneWidget);
  });

  testWidgets('stacks trailing content on compact widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 340,
            child: AppContentPanel(
              title: 'Compact panel',
              trailing: Text('Compact trailing'),
              child: Text('Compact child'),
            ),
          ),
        ),
      ),
    );

    final titleTop = tester.getTopLeft(find.text('Compact panel'));
    final trailingTop = tester.getTopLeft(find.text('Compact trailing'));

    expect(trailingTop.dy, greaterThan(titleTop.dy));
  });

  testWidgets('constrains wide trailing content on desktop widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: AppContentPanel(
              title: 'Wide panel',
              subtitle: 'Panel with dense controls',
              leadingIcon: Icons.inventory_2_rounded,
              trailing: SizedBox(width: 860, child: Text('Dense controls')),
              child: Text('Wide child'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Wide panel'), findsOneWidget);
    expect(find.text('Dense controls'), findsOneWidget);
    expect(find.text('Wide child'), findsOneWidget);
  });
}
