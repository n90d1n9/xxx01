import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_data_binding_editor.dart';

void main() {
  testWidgets('inserts a demo data binding token into the component label', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          ComponentData.create(
            id: 'binding-button',
            type: ComponentType.customButton,
            position: Offset.zero,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(layoutStateProvider);

                  return ComponentDataBindingEditor(
                    component: state.selectedComponent!,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Data bindings'), findsOneWidget);
    expect(find.text('Search demo JSON fields'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'full');
    await tester.pump();

    await tester.tap(find.text('{{user.fullName}}'));
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['label'],
      '{{user.fullName}}',
    );
    expect(find.text('Aisyah Rahman'), findsWidgets);
  });
}
