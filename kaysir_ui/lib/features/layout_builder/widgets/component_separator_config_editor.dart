import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'color_picker.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';
import 'number_field.dart';

/// Edits separator label, orientation, spacing, color, and dash styling.
class ComponentSeparatorConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentSeparatorConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final orientation = _separatorOrientationConfig(attributes['orientation']);
    final label = componentStringConfig(attributes['label'], fallback: '');
    final thickness = componentDoubleConfig(
      attributes['thickness'],
      fallback: 2,
      min: 1,
      max: 16,
    );
    final inset = componentDoubleConfig(
      attributes['inset'],
      fallback: 0,
      min: 0,
      max: 64,
    );
    final color = componentColorConfig(
      attributes['color'],
      fallback: Colors.black26,
    );
    final dashed = componentBoolConfig(attributes['dashed'], fallback: false);

    return ComponentConfigSection(
      title: 'Separator',
      children: [
        TextFormField(
          key: ValueKey('separator-label-${component.id}'),
          initialValue: label,
          decoration: const InputDecoration(
            labelText: 'Label',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'label',
                value.trim().isEmpty ? null : value.trim(),
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: orientation,
          decoration: const InputDecoration(
            labelText: 'Orientation',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'horizontal', child: Text('Horizontal')),
            DropdownMenuItem(value: 'vertical', child: Text('Vertical')),
          ],
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'orientation',
                value,
              ),
        ),
        const SizedBox(height: 8),
        NumberField(
          label: 'Thickness',
          value: thickness,
          min: 1,
          max: 16,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'thickness',
                value.clamp(1, 16).toDouble(),
              ),
        ),
        const SizedBox(height: 8),
        NumberField(
          label: 'Inset',
          value: inset,
          min: 0,
          max: 64,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'inset',
                value.clamp(0, 64).toDouble(),
              ),
        ),
        const SizedBox(height: 10),
        ColorPicker(
          label: 'Line color',
          color: color,
          onColorChanged:
              (color) => updateComponentAttribute(
                ref,
                component,
                'color',
                color.toARGB32(),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dashed line'),
          value: dashed,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'dashed', value),
        ),
      ],
    );
  }
}

/// Renders the separator config editor with sample divider attributes.
@Preview(name: 'Component separator config editor')
Widget componentSeparatorConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-separator',
    type: ComponentType.separator,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'label': 'Section',
        'orientation': 'horizontal',
        'thickness': 2,
        'inset': 12,
        'dashed': false,
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
              child: ComponentSeparatorConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

String _separatorOrientationConfig(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'vertical' ? 'vertical' : 'horizontal';
}
