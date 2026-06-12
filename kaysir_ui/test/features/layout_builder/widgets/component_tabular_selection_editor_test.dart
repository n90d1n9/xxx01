import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_tabular_selection_editor.dart';

void main() {
  testWidgets(
    'moves tabular selection start column and row through layout state',
    (tester) async {
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
      notifier.addComponents([
        ComponentData.create(
          id: 'tabular-first',
          type: ComponentType.customButton,
          position: const Offset(110, 40),
          size: const Size(100, 40),
        ),
        ComponentData.create(
          id: 'tabular-second',
          type: ComponentType.customButton,
          position: const Offset(220, 40),
          size: const Size(100, 40),
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
                      child: ComponentTabularSelectionEditor(
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

      expect(find.text('Tabular selection'), findsOneWidget);
      expect(find.text('C2-3 R2'), findsOneWidget);
      expect(find.text('2 x 1 cells'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), '1');
      await tester.pump();

      expect(
        container
            .read(layoutStateProvider)
            .componentsById['tabular-first']
            ?.position,
        Offset.zero,
      );
      expect(
        container
            .read(layoutStateProvider)
            .componentsById['tabular-second']
            ?.position,
        const Offset(110, 0),
      );
    },
  );
}
