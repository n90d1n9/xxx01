import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import 'component_config_helpers.dart';
import 'component_config_section.dart';

/// Edits image holder attributes such as source, fit, alignment, and placeholder visibility.
class ComponentImageHolderConfigEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentImageHolderConfigEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributes = component.properties.attributes;
    final source = componentStringConfig(attributes['source'], fallback: '');
    final fit = _imageFitConfig(attributes['fit']);
    final alignment = _imageAlignmentConfig(attributes['alignment']);
    final showPlaceholder = componentBoolConfig(
      attributes['showPlaceholder'],
      fallback: true,
    );

    return ComponentConfigSection(
      title: 'Image source',
      children: [
        TextFormField(
          key: ValueKey('image-source-${component.id}-$source'),
          initialValue: source,
          decoration: const InputDecoration(
            labelText: 'Asset, URL, or binding',
            hintText: 'assets/icons/logo-golok.png',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'source',
                value.trim().isEmpty ? null : value.trim(),
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Logo asset'),
              onPressed:
                  () => updateComponentAttribute(
                    ref,
                    component,
                    'source',
                    'assets/icons/logo-golok.png',
                  ),
            ),
            ActionChip(
              avatar: const Icon(Icons.person_outline, size: 18),
              label: const Text('User image'),
              onPressed:
                  () => updateComponentAttribute(
                    ref,
                    component,
                    'source',
                    '{{user.imageUrl}}',
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: fit,
          decoration: const InputDecoration(
            labelText: 'Fit',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'cover', child: Text('Cover')),
            DropdownMenuItem(value: 'contain', child: Text('Contain')),
            DropdownMenuItem(value: 'fill', child: Text('Fill')),
            DropdownMenuItem(value: 'fit_width', child: Text('Fit width')),
            DropdownMenuItem(value: 'fit_height', child: Text('Fit height')),
            DropdownMenuItem(value: 'none', child: Text('None')),
          ],
          onChanged:
              (value) => updateComponentAttribute(ref, component, 'fit', value),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: alignment,
          decoration: const InputDecoration(
            labelText: 'Alignment',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'center', child: Text('Center')),
            DropdownMenuItem(value: 'top', child: Text('Top')),
            DropdownMenuItem(value: 'bottom', child: Text('Bottom')),
            DropdownMenuItem(value: 'left', child: Text('Left')),
            DropdownMenuItem(value: 'right', child: Text('Right')),
          ],
          onChanged:
              (value) =>
                  updateComponentAttribute(ref, component, 'alignment', value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show placeholder'),
          value: showPlaceholder,
          onChanged:
              (value) => updateComponentAttribute(
                ref,
                component,
                'showPlaceholder',
                value,
              ),
        ),
      ],
    );
  }
}

/// Renders the image holder config editor with a sample asset source.
@Preview(name: 'Component image holder config editor')
Widget componentImageHolderConfigEditorPreview() {
  final baseComponent = ComponentData.create(
    id: 'preview-image-holder',
    type: ComponentType.imageHolder,
    position: Offset.zero,
  );
  final component = baseComponent.copyWith(
    properties: baseComponent.properties.copyWith(
      attributes: const {
        'source': 'assets/icons/logo-golok.png',
        'fit': 'contain',
        'alignment': 'center',
        'showPlaceholder': true,
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
              child: ComponentImageHolderConfigEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

String _imageFitConfig(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  const allowedFits = {
    'cover',
    'contain',
    'fill',
    'fit_width',
    'fit_height',
    'none',
  };
  return allowedFits.contains(normalized) ? normalized! : 'cover';
}

String _imageAlignmentConfig(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  const allowedAlignments = {'center', 'top', 'bottom', 'left', 'right'};
  return allowedAlignments.contains(normalized) ? normalized! : 'center';
}
