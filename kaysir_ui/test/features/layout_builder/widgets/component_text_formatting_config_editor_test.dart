import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_text_formatting_config_editor.dart';

void main() {
  testWidgets('updates button text attributes through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'text-format-button',
      type: ComponentType.customButton,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'label': 'Checkout',
                'fontSize': 14,
                'fontWeight': 600,
                'textAlign': 'center',
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

                return ComponentTextFormattingConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Text appearance'), findsOneWidget);
    expect(find.text('Button label'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('text-format-value-text-format-button-label')),
      'Pay now',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['label'],
      'Pay now',
    );
  });
}
