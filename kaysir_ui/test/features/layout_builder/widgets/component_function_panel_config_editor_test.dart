import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_function_panel_config_editor.dart';

void main() {
  testWidgets('normalizes function actions through layout state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'function-panel-config',
      type: ComponentType.functionPanel,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'actions': ['Pay', 'Void'],
                'columns': 1,
                'buttonStyle': 'outlined',
                'compact': false,
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

                return ComponentFunctionPanelConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Function panel'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Compact spacing'), findsOneWidget);

    await tester.enterText(
      find.byKey(
        const ValueKey('function-panel-actions-function-panel-config'),
      ),
      'Pay, Discount\nPrint',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['actions'],
      'Pay\nDiscount\nPrint',
    );
  });
}
