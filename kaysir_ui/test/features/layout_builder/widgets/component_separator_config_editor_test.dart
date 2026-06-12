import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_separator_config_editor.dart';

void main() {
  testWidgets('updates separator label through layout state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'separator-config',
      type: ComponentType.separator,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'label': 'Section',
                'orientation': 'horizontal',
                'thickness': 2,
                'inset': 0,
                'dashed': false,
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

                return ComponentSeparatorConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Separator'), findsOneWidget);
    expect(find.text('Line color'), findsOneWidget);
    expect(find.text('Dashed line'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('separator-label-separator-config')),
      'Totals',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['label'],
      'Totals',
    );
  });
}
