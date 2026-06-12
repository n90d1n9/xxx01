import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_numpad_config_editor.dart';

void main() {
  testWidgets('updates the numpad clear key through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'numpad-config',
      type: ComponentType.numpad,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'showDisplay': true,
                'displayValue': '0',
                'showDecimal': true,
                'clearLabel': 'C',
                'buttonStyle': 'outlined',
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

                return ComponentNumpadConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Numpad controls'), findsOneWidget);
    expect(find.text('Display value'), findsOneWidget);
    expect(find.text('Clear key'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('numpad-clear-key-numpad-config')),
      'CLR',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['clearLabel'],
      'CLR',
    );
  });
}
