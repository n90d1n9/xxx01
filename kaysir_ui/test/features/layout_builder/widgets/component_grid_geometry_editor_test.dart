import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_grid_geometry_editor.dart';

void main() {
  testWidgets('updates grid column and span through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        layoutMechanism: LayoutMechanism.grid,
        canvasWidth: 200,
        canvasHeight: 160,
        minComponentWidth: 20,
        minComponentHeight: 20,
      ),
    );
    notifier.addComponent(
      ComponentData.create(
        id: 'grid-button',
        type: ComponentType.customButton,
        position: const Offset(20, 20),
        size: const Size(40, 40),
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(layoutStateProvider);
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 320,
                    child: ComponentGridGeometryEditor(
                      component: state.selectedComponent!,
                      config: state.config,
                      gridSize: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid position'), findsOneWidget);
    expect(find.text('C2 R2'), findsOneWidget);
    expect(find.text('2 x 2 cells'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '4');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.position.dx,
      60,
    );

    await tester.enterText(find.byType(TextFormField).at(2), '5');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.size.width,
      100,
    );
  });
}
