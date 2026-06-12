import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/provider/layout_state_provider.dart';
import 'package:kaysir/features/layout_builder/widgets/component_cart_panel_config_editor.dart';

void main() {
  testWidgets('updates cart panel title through layout state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final baseComponent = ComponentData.create(
      id: 'cart-panel-config',
      type: ComponentType.cartPanel,
      position: Offset.zero,
    );
    container
        .read(layoutStateProvider.notifier)
        .addComponent(
          baseComponent.copyWith(
            properties: baseComponent.properties.copyWith(
              attributes: const {
                'title': 'Cart',
                'showTitle': true,
                'showSubtotal': true,
                'showTax': true,
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

                return ComponentCartPanelConfigEditor(
                  component: state.selectedComponent!,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cart panel'), findsOneWidget);
    expect(find.text('Show subtotal'), findsOneWidget);
    expect(find.text('Compact rows'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('cart-panel-title-cart-panel-config')),
      'Basket',
    );
    await tester.pump();

    expect(
      container
          .read(layoutStateProvider)
          .components
          .single
          .properties
          .attributes['title'],
      'Basket',
    );
  });
}
