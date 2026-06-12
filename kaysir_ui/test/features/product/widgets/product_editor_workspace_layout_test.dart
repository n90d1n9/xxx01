import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_editor_form_layout.dart';
import 'package:kaysir/features/product/widgets/product_editor_workspace_layout.dart';

void main() {
  testWidgets('product editor workspace layout stacks compact slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductEditorWorkspaceLayout(
            layout: ProductEditorFormLayout.forWidth(800),
            header: const _TestSlot('Header'),
            primaryContent: const _TestSlot('Primary content'),
            sideRail: const _TestSlot('Side rail'),
            compactGuidance: const _TestSlot('Compact guidance'),
            compactSaveAction: const _TestSlot('Compact save action'),
          ),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Compact guidance'), findsOneWidget);
    expect(find.text('Primary content'), findsOneWidget);
    expect(find.text('Compact save action'), findsOneWidget);
    expect(find.text('Side rail'), findsNothing);

    expect(
      tester.getTopLeft(find.text('Compact guidance')).dy,
      greaterThan(tester.getTopLeft(find.text('Header')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Compact save action')).dy,
      greaterThan(tester.getTopLeft(find.text('Primary content')).dy),
    );
  });

  testWidgets('product editor workspace layout splits wide slots', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductEditorWorkspaceLayout(
            layout: ProductEditorFormLayout.forWidth(1280),
            header: const _TestSlot('Header'),
            primaryContent: const _TestSlot('Primary content'),
            sideRail: const _TestSlot('Side rail'),
            compactGuidance: const _TestSlot('Compact guidance'),
            compactSaveAction: const _TestSlot('Compact save action'),
          ),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Primary content'), findsOneWidget);
    expect(find.text('Side rail'), findsOneWidget);
    expect(find.text('Compact guidance'), findsNothing);
    expect(find.text('Compact save action'), findsNothing);

    final primaryTopLeft = tester.getTopLeft(find.text('Primary content'));
    final railTopLeft = tester.getTopLeft(find.text('Side rail'));

    expect(railTopLeft.dx, greaterThan(primaryTopLeft.dx));
    expect((railTopLeft.dy - primaryTopLeft.dy).abs(), lessThan(4));
  });
}

/// Fixed-size test slot for product editor workspace layout assertions.
class _TestSlot extends StatelessWidget {
  const _TestSlot(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(child: Text(label)),
      ),
    );
  }
}
