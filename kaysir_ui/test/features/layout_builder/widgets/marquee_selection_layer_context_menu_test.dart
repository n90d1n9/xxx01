import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/marquee_selection_layer.dart';

void main() {
  testWidgets(
    'MarqueeSelectionLayer canvas menu moves selection to clear spot',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(layoutStateProvider.notifier);
      notifier.updateLayoutConfig(
        const LayoutConfig(
          canvasWidth: 240,
          canvasHeight: 240,
          minComponentWidth: 20,
          minComponentHeight: 20,
          layoutMechanism: LayoutMechanism.grid,
        ),
      );
      notifier.updateGridSettings(const GridSettings(gridSize: 20));
      notifier.addComponents([
        _component('blocker', position: const Offset(20, 20)),
        _component('dragged', position: const Offset(20, 20)),
      ]);
      notifier.selectComponent('dragged');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  children: [
                    MarqueeSelectionLayer(
                      components: notifier.state.components,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(140, 40), buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Move selection to clear spot (Grid c4 r2)'),
        findsOneWidget,
      );

      await tester.tap(find.text('Move selection to clear spot (Grid c4 r2)'));
      await tester.pumpAndSettle();

      expect(
        container.read(layoutStateProvider).componentsById['dragged']?.position,
        const Offset(60, 20),
      );
      expect(
        find.text('Moved selection to clear spot at Grid c4 r2'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

ComponentData _component(String id, {required Offset position}) {
  return ComponentData.create(
    id: id,
    type: ComponentType.customButton,
    position: position,
    size: const Size(40, 40),
  );
}
