import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/provider/review_state.dart';
import 'package:kaysir/features/layout_builder/widgets/component_single_property_editor.dart';

void main() {
  testWidgets('updates component style through the single property editor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          ComponentData.create(
            id: 'single-property-button',
            type: ComponentType.customButton,
            position: const Offset(20, 20),
            size: const Size(160, 56),
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
                return SizedBox(
                  width: 320,
                  height: 1200,
                  child: ComponentSinglePropertyEditor(
                    component: state.selectedComponent!,
                    previewState: ResponsivePreviewState.mobile,
                    config: const LayoutConfig(
                      canvasWidth: 430,
                      canvasHeight: 320,
                      minComponentWidth: 40,
                      minComponentHeight: 40,
                    ),
                    gridSize: state.gridSettings.gridSize,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Action Button'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Style'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Style'), findsOneWidget);

    final draggableSwitch = find.widgetWithText(SwitchListTile, 'Draggable');
    await tester.scrollUntilVisible(
      draggableSwitch,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    tester.widget<SwitchListTile>(draggableSwitch).onChanged?.call(false);
    await tester.pump();

    final component =
        container
            .read(layoutStateProvider)
            .componentsById['single-property-button'];
    expect(component?.style.isDraggable, isFalse);
    expect(component?.properties.style['isDraggable'], isFalse);
  });
}
