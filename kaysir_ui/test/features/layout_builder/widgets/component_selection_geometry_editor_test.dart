import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_selection_geometry_editor.dart';

void main() {
  testWidgets(
    'moves and resizes selection through extracted geometry controls',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(layoutStateProvider.notifier);
      notifier.updateLayoutConfig(
        const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          canvasWidth: 240,
          canvasHeight: 160,
          minComponentWidth: 20,
          minComponentHeight: 20,
          gridSize: 20,
        ),
      );
      notifier.addComponents([
        ComponentData.create(
          id: 'selection-first',
          type: ComponentType.customButton,
          position: const Offset(20, 20),
          size: const Size(40, 40),
        ),
        ComponentData.create(
          id: 'selection-second',
          type: ComponentType.customButton,
          position: const Offset(80, 20),
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
                      child: ComponentSelectionGeometryEditor(
                        components: state.selectedComponents,
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

      expect(find.text('Selection position'), findsOneWidget);
      expect(find.text('Selection size'), findsOneWidget);
      expect(find.text('Stack selection'), findsOneWidget);
      expect(find.text('Selection spacing'), findsOneWidget);
      expect(find.text('Align and distribute'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '0');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '0');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(2), '60');
      await tester.pump();

      final state = container.read(layoutStateProvider);
      expect(state.componentsById['selection-first']?.position, Offset.zero);
      expect(
        state.componentsById['selection-second']?.position,
        const Offset(60, 0),
      );
      expect(state.componentsById['selection-first']?.size, const Size(60, 40));
      expect(
        state.componentsById['selection-second']?.size,
        const Size(60, 40),
      );
    },
  );
}
