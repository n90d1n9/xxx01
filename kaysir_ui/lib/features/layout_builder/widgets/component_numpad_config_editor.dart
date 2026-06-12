import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';

/// Edits numpad component controls such as display text, clear key, and decimal visibility.
class ComponentNumpadConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentNumpadConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final showDisplay = componentBoolConfig(
      attributes['showDisplay'],
      fallback: true,
    );
    final displayValue = componentStringConfig(
      attributes['displayValue'],
      fallback: '0',
    );
    final showDecimal = componentBoolConfig(
      attributes['showDecimal'],
      fallback: true,
    );
    final clearLabel = componentStringConfig(
      attributes['clearLabel'],
      fallback: 'C',
    );
    final buttonStyle = componentButtonStyleConfig(attributes['buttonStyle']);

    return ComponentConfigSection(
      title: 'Numpad controls',
      children: [
        TextFormField(
          key: ValueKey('numpad-display-value-${component.id}'),
          initialValue: displayValue,
          decoration: const InputDecoration(
            labelText: 'Display value',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'displayValue',
                value.trim().isEmpty ? '0' : value.trim(),
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('numpad-clear-key-${component.id}'),
          initialValue: clearLabel,
          decoration: const InputDecoration(
            labelText: 'Clear key',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'clearLabel',
                value.trim().isEmpty ? 'C' : value.trim(),
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: buttonStyle,
          decoration: const InputDecoration(
            labelText: 'Button style',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'outlined', child: Text('Outlined')),
            DropdownMenuItem(value: 'tonal', child: Text('Tonal')),
            DropdownMenuItem(value: 'filled', child: Text('Filled')),
          ],
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'buttonStyle',
                value,
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show display'),
          value: showDisplay,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'showDisplay',
                value,
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Decimal key'),
          value: showDecimal,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'showDecimal',
                value,
              ),
        ),
      ],
    );
  }
}

/// Renders the numpad config editor with common point-of-sale defaults.
@Preview(name: 'Component numpad config editor')
Widget componentNumpadConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-numpad',
    type: ComponentType.numpad,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'showDisplay': true,
        'displayValue': '0',
        'showDecimal': true,
        'clearLabel': 'C',
        'buttonStyle': 'outlined',
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
              child: ComponentNumpadConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}
