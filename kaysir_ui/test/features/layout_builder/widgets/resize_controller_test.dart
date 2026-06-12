import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/widgets/resize_controller.dart';

void main() {
  testWidgets('ResizeController expands from the right handle', (tester) async {
    final sizes = <Size>[];

    await _pumpResizeController(tester, sizes);
    await tester.drag(_handle('right'), const Offset(30, 0));
    await tester.pump();

    expect(sizes.last, const Size(150, 80));
    expect(tester.getSize(find.byType(ResizeController)), const Size(150, 80));
  });

  testWidgets('ResizeController clamps from the left handle', (tester) async {
    final sizes = <Size>[];

    await _pumpResizeController(tester, sizes);
    await tester.drag(_handle('left'), const Offset(90, 0));
    await tester.pump();

    expect(sizes.last, const Size(60, 80));
    expect(tester.getSize(find.byType(ResizeController)), const Size(60, 80));
  });

  testWidgets('ResizeController grows from the top-left handle', (
    tester,
  ) async {
    final sizes = <Size>[];

    await _pumpResizeController(tester, sizes);
    await tester.drag(_handle('topLeft'), const Offset(-20, -10));
    await tester.pump();

    expect(sizes.last, const Size(140, 90));
    expect(tester.getSize(find.byType(ResizeController)), const Size(140, 90));
  });

  testWidgets('ResizeController renders only concrete handles', (tester) async {
    await _pumpResizeController(tester, <Size>[]);

    for (final handle in [
      'topLeft',
      'top',
      'topRight',
      'right',
      'bottomRight',
      'bottom',
      'bottomLeft',
      'left',
    ]) {
      expect(_handle(handle), findsOneWidget);
    }

    for (final hiddenHandle in ['none', 'horizontal', 'vertical', 'diagonal']) {
      expect(_handle(hiddenHandle), findsNothing);
    }
  });
}

Finder _handle(String name) {
  return find.byKey(ValueKey('resize-controller-handle-$name'));
}

Future<void> _pumpResizeController(
  WidgetTester tester,
  List<Size> sizes,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: ResizeController(
            initialSize: const Size(120, 80),
            minSize: const Size(60, 40),
            onResize: sizes.add,
          ),
        ),
      ),
    ),
  );
}
