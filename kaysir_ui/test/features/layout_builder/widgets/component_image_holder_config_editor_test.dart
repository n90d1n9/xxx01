import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_image_holder_config_editor.dart';

void main() {
  testWidgets('applies the logo asset preset through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'image-holder-config',
      type: ComponentType.imageHolder,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'fit': 'cover',
                'alignment': 'center',
                'showPlaceholder': true,
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

                return ComponentImageHolderConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Image source'), findsOneWidget);
    expect(find.text('Logo asset'), findsOneWidget);
    expect(find.text('User image'), findsOneWidget);

    await tester.tap(find.text('Logo asset'));
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['source'],
      'assets/icons/logo-golok.png',
    );
  });
}
