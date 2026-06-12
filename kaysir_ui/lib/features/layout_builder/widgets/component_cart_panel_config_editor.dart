import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';

/// Edits cart panel title, totals visibility, tax visibility, and compact rows.
class ComponentCartPanelConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentCartPanelConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final title = componentStringConfig(attributes['title'], fallback: 'Cart');
    final showTitle = componentBoolConfig(
      attributes['showTitle'],
      fallback: true,
    );
    final showSubtotal = componentBoolConfig(
      attributes['showSubtotal'],
      fallback: true,
    );
    final showTax = componentBoolConfig(attributes['showTax'], fallback: true);
    final compact = componentBoolConfig(attributes['compact'], fallback: false);

    return ComponentConfigSection(
      title: 'Cart panel',
      children: [
        TextFormField(
          key: ValueKey('cart-panel-title-${component.id}'),
          initialValue: title,
          decoration: const InputDecoration(
            labelText: 'Title',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'title',
                value.trim().isEmpty ? 'Cart' : value,
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show title'),
          value: showTitle,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'showTitle', value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show subtotal'),
          value: showSubtotal,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'showSubtotal',
                value,
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show tax'),
          value: showTax,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'showTax', value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Compact rows'),
          value: compact,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'compact', value),
        ),
      ],
    );
  }
}

/// Renders the cart panel config editor with common totals enabled.
@Preview(name: 'Component cart panel config editor')
Widget componentCartPanelConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-cart-panel',
    type: ComponentType.cartPanel,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'title': 'Cart',
        'showTitle': true,
        'showSubtotal': true,
        'showTax': true,
        'compact': false,
      },
    ),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentCartPanelConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}
