import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_product_grid_config_editor.dart';

void main() {
  testWidgets('updates product grid price visibility through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'product-grid-config',
      type: ComponentType.buttonGrid,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'columns': 4,
                'maxProducts': 8,
                'showPrice': true,
              },
            ),
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

                return ComponentProductGridConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product grid'), findsOneWidget);
    expect(find.text('Product limit'), findsOneWidget);
    expect(find.text('Show prices'), findsOneWidget);

    await tester.tap(find.text('Show prices'));
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['showPrice'],
      isFalse,
    );
  });
}
