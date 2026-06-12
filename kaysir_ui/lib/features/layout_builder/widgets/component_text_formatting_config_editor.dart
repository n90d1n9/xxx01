import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'color_picker.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';
import 'number_field.dart';

/// Edits text-specific attributes for button and label components.
class ComponentTextFormattingConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentTextFormattingConfigEditor({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final textKey =
        component.type == ComponentType.customButton ? 'label' : 'text';
    final textFallback =
        component.type == ComponentType.customButton ? 'Action' : 'Label';
    final textLabel =
        component.type == ComponentType.customButton ? 'Button label' : 'Text';
    final fontSize = componentDoubleConfig(
      attributes['fontSize'],
      fallback: component.type == ComponentType.customButton ? 14 : 16,
      min: 8,
      max: 48,
    );
    final fontWeight = _fontWeightConfig(
      attributes['fontWeight'],
      fallback: component.type == ComponentType.customButton ? 600 : 500,
    );
    final textAlign = _textAlignConfig(
      attributes['textAlign'],
      fallback:
          component.type == ComponentType.customButton ? 'center' : 'left',
    );
    final textColor = componentColorConfig(
      attributes['textColor'],
      fallback: Colors.black87,
    );
    final maxLines = componentIntConfig(
      attributes['maxLines'],
      fallback: 1,
      min: 1,
      max: 6,
    );

    return ComponentConfigSection(
      title: 'Text appearance',
      children: [
        TextFormField(
          key: ValueKey('text-format-value-${component.id}-$textKey'),
          initialValue: componentStringConfig(
            attributes[textKey],
            fallback: textFallback,
          ),
          decoration: InputDecoration(
            labelText: textLabel,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                textKey,
                value.trim().isEmpty ? textFallback : value,
              ),
        ),
        const SizedBox(height: 8),
        NumberField(
          label: 'Font size',
          value: fontSize,
          min: 8,
          max: 48,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'fontSize',
                value.clamp(8, 48).toDouble(),
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: fontWeight,
          decoration: const InputDecoration(
            labelText: 'Weight',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 400, child: Text('Regular')),
            DropdownMenuItem(value: 500, child: Text('Medium')),
            DropdownMenuItem(value: 600, child: Text('Semibold')),
            DropdownMenuItem(value: 700, child: Text('Bold')),
          ],
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'fontWeight', value),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: textAlign,
          decoration: const InputDecoration(
            labelText: 'Alignment',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'left', child: Text('Left')),
            DropdownMenuItem(value: 'center', child: Text('Center')),
            DropdownMenuItem(value: 'right', child: Text('Right')),
          ],
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'textAlign', value),
        ),
        const SizedBox(height: 10),
        ColorPicker(
          label: 'Text color',
          color: textColor,
          onColorChanged:
              (color) => updateComponentAttribute(
                ref,
                component,
                'textColor',
                color.toARGB32(),
              ),
        ),
        if (component.type == ComponentType.textLabel) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: maxLines,
            decoration: const InputDecoration(
              labelText: 'Lines',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 line')),
              DropdownMenuItem(value: 2, child: Text('2 lines')),
              DropdownMenuItem(value: 3, child: Text('3 lines')),
              DropdownMenuItem(value: 4, child: Text('4 lines')),
              DropdownMenuItem(value: 6, child: Text('6 lines')),
            ],
            onChanged:
                (value) =>
                    updateComponentAttribute(ref, component, 'maxLines', value),
          ),
        ],
      ],
    );
  }
}

/// Renders the text formatting inspector for a button component.
@Preview(name: 'Component text formatting config editor')
Widget componentTextFormattingConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-text-formatting-button',
    type: ComponentType.customButton,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'label': 'Checkout',
        'fontSize': 16,
        'fontWeight': 600,
        'textAlign': 'center',
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
              child: ComponentTextFormattingConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

int _fontWeightConfig(Object? value, {required int fallback}) {
  const allowedWeights = {400, 500, 600, 700};
  final parsed =
      value is num ? value.round() : int.tryParse(value?.toString() ?? '');
  final next = parsed ?? fallback;
  return allowedWeights.contains(next) ? next : fallback;
}

String _textAlignConfig(Object? value, {required String fallback}) {
  final normalized = value?.toString().trim().toLowerCase();
  const allowedAlignments = {'left', 'center', 'right'};
  return allowedAlignments.contains(normalized) ? normalized! : fallback;
}
