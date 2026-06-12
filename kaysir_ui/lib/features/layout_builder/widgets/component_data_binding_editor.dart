import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_data_binding_provider.dart';
import '../provider/layout_state_provider.dart';

/// Offers quick insertion of demo JSON data-binding tokens for text-like fields.
class ComponentDataBindingEditor extends ConsumerStatefulWidget {
  final ComponentData component;

  const ComponentDataBindingEditor({super.key, required this.component});

  @override
  ConsumerState<ComponentDataBindingEditor> createState() =>
      _ComponentDataBindingEditorState();
}

class _ComponentDataBindingEditorState
    extends ConsumerState<ComponentDataBindingEditor> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    final attributeKey = _bindingAttributeKey(component.type);
    if (attributeKey == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final currentValue = component.properties.attributes[attributeKey];
    final currentTemplate = currentValue is String ? currentValue : '';
    final currentPreview =
        currentTemplate.isEmpty ? null : bindings.resolve(currentTemplate);
    final bindingPreviews = _filteredBindingPreviews(bindings);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
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
                'Data bindings',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (currentPreview != null) ...[
                _BindingCurrentValue(
                  template: currentTemplate,
                  preview: currentPreview,
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search demo JSON fields',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              for (final binding in bindingPreviews.take(8))
                _BindingOptionTile(
                  binding: binding,
                  icon: _bindingIcon(binding.key),
                  onTap: () => _applyBinding(ref, attributeKey, binding.token),
                ),
              if (bindingPreviews.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${bindingPreviews.length - 8} more fields match',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<LayoutBindingPreview> _filteredBindingPreviews(
    LayoutDataBindingValues bindings,
  ) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return bindings.bindingPreviews;

    return [
      for (final binding in bindings.bindingPreviews)
        if (binding.key.toLowerCase().contains(query) ||
            binding.value.toLowerCase().contains(query))
          binding,
    ];
  }

  void _applyBinding(WidgetRef ref, String attributeKey, String token) {
    final attributes = Map<String, dynamic>.from(
      widget.component.properties.attributes,
    );
    attributes[attributeKey] = token;

    ref
        .read(layoutStateProvider.notifier)
        .updateComponentProperties(
          widget.component.id,
          widget.component.properties.copyWith(attributes: attributes),
        );
  }
}

/// Renders the data-binding editor with fallback demo bindings.
@Preview(name: 'Component data binding editor')
Widget componentDataBindingEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-binding-button',
    type: ComponentType.customButton,
    position: Offset.zero,
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentDataBindingEditor(component: component),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Displays the currently selected binding token and resolved preview value.
class _BindingCurrentValue extends StatelessWidget {
  final String template;
  final String preview;

  const _BindingCurrentValue({required this.template, required this.preview});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays one insertable binding token with a resolved sample value.
class _BindingOptionTile extends StatelessWidget {
  final LayoutBindingPreview binding;
  final IconData icon;
  final VoidCallback onTap;

  const _BindingOptionTile({
    required this.binding,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      binding.token,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      binding.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.add_circle_outline, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

String? _bindingAttributeKey(ComponentType type) {
  switch (type) {
    case ComponentType.customButton:
      return 'label';
    case ComponentType.textLabel:
      return 'text';
    case ComponentType.imageHolder:
      return 'source';
    case ComponentType.separator:
      return 'label';
    case ComponentType.buttonGrid:
    case ComponentType.cartPanel:
    case ComponentType.numpad:
    case ComponentType.functionPanel:
      return null;
  }
}

IconData _bindingIcon(String key) {
  if (key.startsWith('store.')) return Icons.storefront_outlined;
  if (key.startsWith('user.')) return Icons.person_outline;
  if (key.startsWith('shift.')) return Icons.badge_outlined;
  if (key.startsWith('cart.')) return Icons.receipt_long_outlined;
  if (key.startsWith('products.')) return Icons.inventory_2_outlined;
  return Icons.data_object_outlined;
}
