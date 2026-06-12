import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_auto_grid_selection_editor.dart';

void main() {
  testWidgets(
    'moves auto-grid selection start column and row through layout state',
    (tester) async {
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
      notifier.addComponents([
        ComponentData.create(
          id: 'auto-grid-first',
          type: ComponentType.customButton,
          position: const Offset(110, 110),
          size: const Size(100, 100),
        ),
        ComponentData.create(
          id: 'auto-grid-second',
          type: ComponentType.customButton,
          position: const Offset(220, 110),
          size: const Size(100, 100),
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
                      child: ComponentAutoGridSelectionEditor(
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

      expect(find.text('Auto Grid selection'), findsOneWidget);
      expect(find.text('C2-3 R2'), findsOneWidget);
      expect(find.text('2 x 1 cells'), findsOneWidget);
      expect(find.text('Arrange'), findsOneWidget);
      expect(find.text('Free cells'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.pump();

      expect(
        container
            .read(layoutStateProvider)
            .componentsById['auto-grid-first']
            ?.position,
        Offset.zero,
      );
      expect(
        container
            .read(layoutStateProvider)
            .componentsById['auto-grid-second']
            ?.position,
        const Offset(110, 0),
      );
    },
  );
}
