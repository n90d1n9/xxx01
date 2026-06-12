import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_geometry_editor.dart';

void main() {
  testWidgets('updates component position and size through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(layoutStateProvider.notifier);
    notifier.updateLayoutConfig(
      const LayoutConfig(
        layoutMechanism: LayoutMechanism.freeform,
        snapToGrid: false,
        minComponentWidth: 20,
        minComponentHeight: 20,
      ),
    );
    notifier.addComponent(
      ComponentData.create(
        id: 'button-1',
        type: ComponentType.customButton,
        position: const Offset(20, 24),
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
                return ComponentGeometryEditor(
                  component: state.selectedComponent!,
                  config: state.config,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Position'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);
    expect(find.text('Width'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '46');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.position.dx,
      46,
    );

    await tester.enterText(find.byType(TextFormField).at(2), '220');
    await tester.pump();

    expect(
      container.read(layoutStateProvider).components.single.size.width,
      220,
    );
  });
}
