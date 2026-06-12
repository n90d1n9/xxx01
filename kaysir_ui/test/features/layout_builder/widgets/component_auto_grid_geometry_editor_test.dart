import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_auto_grid_geometry_editor.dart';

void main() {
  testWidgets('updates auto-grid column and span through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        layoutMechanism: LayoutMechanism.autoGrid,
        canvasWidth: 430,
        canvasHeight: 430,
        minComponentWidth: 40,
        minComponentHeight: 40,
        autoGridColumnCount: 4,
        autoGridGap: 10,
        autoGridRowHeight: 100,
      ),
    );
    notifier.addComponent(
      ComponentData.create(
        id: 'auto-grid-button',
        type: ComponentType.customButton,
        position: const Offset(110, 110),
        size: const Size(100, 100),
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
                    child: ComponentAutoGridGeometryEditor(
                      component: state.selectedComponent!,
                      config: state.config,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Auto Grid position'), findsOneWidget);
    expect(find.text('C2 R2'), findsOneWidget);
    expect(find.text('1 x 1 cells'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '3');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.position.dx,
      220,
    );

    await tester.enterText(find.byType(TextFormField).at(2), '2');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.size.width,
      210,
    );
  });
}
