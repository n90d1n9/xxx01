import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/component_properties.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_identity_editor.dart';

void main() {
  testWidgets('renames the selected component layer', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final component = ComponentData.create(
      id: 'button-identity-123456',
      type: ComponentType.customButton,
      position: Offset.zero,
    ).copyWith(
      properties: const ComponentProperties(
        attributes: {'name': 'Checkout CTA'},
        events: {'tap': 'submit_order'},
      ),
    );
    container.read(layoutStateProvider.notifier).addComponent(component);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(layoutStateProvider);
                return ComponentIdentityEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Layer identity'), findsOneWidget);
    expect(find.text('Checkout CTA'), findsOneWidget);
    expect(find.text('custom_button'), findsOneWidget);
    expect(find.text('button-i'), findsOneWidget);
    expect(find.text('1 event'), findsOneWidget);
    expect(find.text('Save preset'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('layer-name-button-identity-123456')),
      'Primary checkout',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['name'],
      'Primary checkout',
    );
  });
}
