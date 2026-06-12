import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';
import 'dialog_utils.dart';

/// Edits the selected component's layer-facing identity and preset action.
class ComponentIdentityEditor extends ConsumerWidget {
  final ComponentData component;

  const ComponentIdentityEditor({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final layerName = _componentDisplayName(component);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layer identity',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('layer-name-${component.id}'),
              initialValue: layerName,
              decoration: const InputDecoration(
                labelText: 'Layer name',
                prefixIcon: Icon(Icons.label_outline),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged:
                  (value) => ref
                      .read(layoutStateProvider.notifier)
                      .renameComponent(component.id, value),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _IdentityChip(
                  icon: component.type.icon,
                  label: component.type.key,
                ),
                _IdentityChip(
                  icon: Icons.tag,
                  label: _shortComponentId(component.id),
                ),
                if (component.properties.events.isNotEmpty)
                  _IdentityChip(
                    icon: Icons.bolt_outlined,
                    label:
                        component.properties.events.length == 1
                            ? '1 event'
                            : '${component.properties.events.length} events',
                  ),
                if (component.isLocked)
                  const _IdentityChip(icon: Icons.lock, label: 'locked'),
                if (!component.isVisible)
                  const _IdentityChip(
                    icon: Icons.visibility_off_outlined,
                    label: 'hidden',
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('Save preset'),
                onPressed:
                    () =>
                        showSaveComponentPresetDialog(context, ref, component),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the component identity editor with sample layer metadata.
@Preview(name: 'Component identity editor')
Widget componentIdentityEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-identity-button',
    type: ComponentType.customButton,
    position: Offset.zero,
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentIdentityEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Displays compact identity metadata for the selected component.
class _IdentityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IdentityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

String _componentDisplayName(ComponentData component) {
  final attributes = component.properties.attributes;
  final customName =
      attributes['name'] ?? attributes['label'] ?? attributes['text'];

  if (customName is String && customName.trim().isNotEmpty) {
    return customName.trim();
  }

  return component.type.label;
}

String _shortComponentId(String id) {
  if (id.length <= 8) return id;
  return id.substring(0, 8);
}
