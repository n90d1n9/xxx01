import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_grid_selection_editor.dart';

void main() {
  testWidgets(
    'moves grid selection start column and row through layout state',
    (tester) async {
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
      notifier.addComponents([
        ComponentData.create(
          id: 'grid-first',
          type: ComponentType.customButton,
          position: const Offset(20, 20),
          size: const Size(40, 40),
        ),
        ComponentData.create(
          id: 'grid-second',
          type: ComponentType.customButton,
          position: const Offset(60, 20),
          size: const Size(40, 40),
        ),
      ]);

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
                      child: ComponentGridSelectionEditor(
                        components: state.selectedComponents,
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

      expect(find.text('Grid selection'), findsOneWidget);
      expect(find.text('C2-5 R2-3'), findsOneWidget);
      expect(find.text('4 x 2 cells'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.pump();

      expect(
        container
            .read(layoutStateProvider)
            .componentsById['grid-first']
            ?.position,
        Offset.zero,
      );
      expect(
        container
            .read(layoutStateProvider)
            .componentsById['grid-second']
            ?.position,
        const Offset(40, 0),
      );
    },
  );
}
