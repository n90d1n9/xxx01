import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_option_surface.dart';

void main() {
  testWidgets('switch option surface renders content and handles taps', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _SurfaceHost(
        child: POSSwitchOptionSurface(
          selected: false,
          onTap: () => taps++,
          child: const Text('Quick Checkout'),
        ),
      ),
    );

    expect(find.text('Quick Checkout'), findsOneWidget);

    await tester.tap(find.text('Quick Checkout'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('switch option surface uses selected treatment', (tester) async {
    await tester.pumpWidget(
      const _SurfaceHost(
        child: POSSwitchOptionSurface(
          selected: true,
          onTap: null,
          child: Text('Kaysir Core'),
        ),
      ),
    );

    final surface = find.byType(POSSwitchOptionSurface);
    final context = tester.element(surface);
    final material = tester.widget<Material>(
      find.descendant(of: surface, matching: find.byType(Material)),
    );

    expect(
      material.color,
      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.34),
    );
  });
}

class _SurfaceHost extends StatelessWidget {
  final Widget child;

  const _SurfaceHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
