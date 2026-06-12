import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_tabular_geometry_editor.dart';

void main() {
  testWidgets('updates tabular column and span through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        layoutMechanism: LayoutMechanism.tabularColumns,
        canvasWidth: 430,
        canvasHeight: 430,
        minComponentWidth: 40,
        minComponentHeight: 40,
        tabularColumnCount: 4,
        tabularColumnGap: 10,
        tabularRowHeight: 40,
      ),
    );
    notifier.addComponent(
      ComponentData.create(
        id: 'tabular-button',
        type: ComponentType.customButton,
        position: const Offset(110, 40),
        size: const Size(100, 40),
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
                    child: ComponentTabularGeometryEditor(
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

    expect(find.text('Tabular position'), findsOneWidget);
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
