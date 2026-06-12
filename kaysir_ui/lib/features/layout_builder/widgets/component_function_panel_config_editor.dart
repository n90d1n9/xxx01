import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';

/// Edits function panel actions, columns, button style, and compact spacing.
class ComponentFunctionPanelConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentFunctionPanelConfigEditor({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final actions = _actionsConfig(attributes['actions']);
    final columns = componentIntConfig(
      attributes['columns'],
      fallback: 1,
      min: 1,
      max: 2,
    );
    final buttonStyle = componentButtonStyleConfig(attributes['buttonStyle']);
    final compact = componentBoolConfig(attributes['compact'], fallback: false);

    return ComponentConfigSection(
      title: 'Function panel',
      children: [
        TextFormField(
          key: ValueKey('function-panel-actions-${component.id}'),
          initialValue: actions,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Actions',
            helperText: 'One action per line or comma-separated',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'actions',
                _normalizeActions(value),
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: columns,
          decoration: const InputDecoration(
            labelText: 'Columns',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 column')),
            DropdownMenuItem(value: 2, child: Text('2 columns')),
          ],
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'columns', value),
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
          title: const Text('Compact spacing'),
          value: compact,
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'compact', value),
        ),
      ],
    );
  }
}

/// Renders the function panel config editor with common point-of-sale actions.
@Preview(name: 'Component function panel config editor')
Widget componentFunctionPanelConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-function-panel',
    type: ComponentType.functionPanel,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'actions': ['Pay', 'Void', 'Discount', 'Print'],
        'columns': 1,
        'buttonStyle': 'outlined',
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
              child: ComponentFunctionPanelConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

String _actionsConfig(Object? value) {
  final actions = _actionItems(value);
  return actions.isEmpty ? 'Pay\nVoid\nDiscount\nPrint' : actions.join('\n');
}

String _normalizeActions(String value) {
  final actions = _actionItems(value);
  return actions.isEmpty ? 'Pay\nVoid\nDiscount\nPrint' : actions.join('\n');
}

List<String> _actionItems(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  return const <String>[];
}
