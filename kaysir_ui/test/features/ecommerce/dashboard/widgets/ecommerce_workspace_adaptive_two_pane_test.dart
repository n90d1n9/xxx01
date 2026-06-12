import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/adaptive_two_pane.dart';

void main() {
  testWidgets('AdaptiveTwoPane uses wide layout', (tester) async {
    _setViewport(tester, const Size(1180, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTwoPane(
            leadingPane: _Pane(
              key: ValueKey('leading_pane'),
              label: 'Controls',
            ),
            mainPane: _Pane(key: ValueKey('main_pane'), label: 'Results'),
          ),
        ),
      ),
    );

    final leadingTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('leading_pane')),
    );
    final mainTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('main_pane')),
    );
    final leadingSize = tester.getSize(
      find.byKey(const ValueKey('leading_pane')),
    );

    expect(leadingSize.width, 410);
    expect(mainTopLeft.dx, greaterThan(leadingTopLeft.dx));
    expect((mainTopLeft.dy - leadingTopLeft.dy).abs(), lessThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdaptiveTwoPane stacks compact layout', (tester) async {
    _setViewport(tester, const Size(620, 640));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveTwoPane(
            leadingPane: _Pane(
              key: ValueKey('leading_pane'),
              label: 'Controls',
            ),
            mainPane: _Pane(key: ValueKey('main_pane'), label: 'Results'),
          ),
        ),
      ),
    );

    final leadingTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('leading_pane')),
    );
    final mainTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('main_pane')),
    );

    expect(mainTopLeft.dy, greaterThan(leadingTopLeft.dy));
    expect(mainTopLeft.dx, leadingTopLeft.dx);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdaptiveTwoPane accepts custom pane width', (tester) async {
    _setViewport(tester, const Size(1000, 640));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptiveTwoPane(
            leadingPaneWidthBuilder: (_) => 280,
            leadingPane: const _Pane(
              key: ValueKey('leading_pane'),
              label: 'Controls',
            ),
            mainPane: const _Pane(key: ValueKey('main_pane'), label: 'Results'),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('leading_pane'))).width,
      280,
    );
    expect(tester.takeException(), isNull);
  });
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _Pane extends StatelessWidget {
  final String label;

  const _Pane({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(height: 120, child: Center(child: Text(label))),
    );
  }
}
