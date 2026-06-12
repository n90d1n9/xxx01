import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';

/// Edits product grid attributes such as columns, limits, and price visibility.
class ComponentProductGridConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentProductGridConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final columns = componentIntConfig(
      attributes['columns'],
      fallback: 4,
      min: 2,
      max: 6,
    );
    final maxProducts = componentIntConfig(
      attributes['maxProducts'],
      fallback: 0,
      min: 0,
      max: 48,
    );
    final showPrice = componentBoolConfig(
      attributes['showPrice'],
      fallback: true,
    );

    return ComponentConfigSection(
      title: 'Product grid',
      children: [
        DropdownButtonFormField<int>(
          initialValue: columns,
          decoration: const InputDecoration(
            labelText: 'Columns',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: [
            for (var value = 2; value <= 6; value++)
              DropdownMenuItem(value: value, child: Text('$value columns')),
          ],
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'columns', value),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _maxProductsOption(maxProducts),
          decoration: const InputDecoration(
            labelText: 'Product limit',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 0, child: Text('All products')),
            DropdownMenuItem(value: 4, child: Text('4 products')),
            DropdownMenuItem(value: 8, child: Text('8 products')),
            DropdownMenuItem(value: 12, child: Text('12 products')),
            DropdownMenuItem(value: 16, child: Text('16 products')),
            DropdownMenuItem(value: 24, child: Text('24 products')),
          ],
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'maxProducts',
                value,
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show prices'),
          value: showPrice,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'showPrice', value),
        ),
      ],
    );
  }
}

/// Renders the product grid config editor with sample layout attributes.
@Preview(name: 'Component product grid config editor')
Widget componentProductGridConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-product-grid',
    type: ComponentType.buttonGrid,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {'columns': 4, 'maxProducts': 12, 'showPrice': true},
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
              child: ComponentProductGridConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

int _maxProductsOption(int value) {
  const allowed = {0, 4, 8, 12, 16, 24};
  return allowed.contains(value) ? value : 0;
}
