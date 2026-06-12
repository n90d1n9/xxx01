import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/layout_data_binding_provider.dart';
import '../provider/layout_state_provider.dart';
import 'active_filter_bar.dart';
import 'filtered_empty_state.dart';
import 'layout_binding_component_factory.dart';

class LayoutDataPanel extends ConsumerStatefulWidget {
  const LayoutDataPanel({super.key});

  @override
  ConsumerState<LayoutDataPanel> createState() => _LayoutDataPanelState();
}

class _LayoutDataPanelState extends ConsumerState<LayoutDataPanel> {
  late final TextEditingController _searchController;
  var _query = '';
  var _category = _DataFieldCategory.all;
  var _usageFilter = _DataUsageFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(
          data: (values) => values,
          orElse: LayoutDataBindingValues.fallback,
        );
    final layoutState = ref.watch(layoutStateProvider);
    final usageComponentIds = _bindingUsageComponentIds(layoutState.components);
    final usageCounts = {
      for (final entry in usageComponentIds.entries)
        entry.key: entry.value.length,
    };
    final selectedComponents = layoutState.selectedComponents;
    final selectedComponentIds =
        selectedComponents.map((component) => component.id).toSet();
    final selectedUsageCounts = _selectedUsageCounts(
      usageComponentIds,
      selectedComponentIds,
    );
    final selectedComponent =
        selectedComponents.length == 1 ? selectedComponents.single : null;
    final attributeKey =
        selectedComponent == null
            ? null
            : _bindingAttributeKey(selectedComponent.type);
    final previews = _filteredPreviews(
      bindings,
      usageCounts,
      selectedUsageCounts,
    );
    final visibleUnusedPreviews = previews
        .where((binding) => (usageCounts[binding.key] ?? 0) == 0)
        .toList(growable: false);
    final theme = Theme.of(context);
    final hasQuery = _query.isNotEmpty;
    final hasCategoryFilter = _category != _DataFieldCategory.all;
    final hasUsageFilter = _usageFilter != _DataUsageFilter.all;
    final hasActiveFilter = hasQuery || hasCategoryFilter || hasUsageFilter;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Data', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _DataTargetSummary(
          component: selectedComponent,
          attributeKey: attributeKey,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search data fields',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                hasQuery
                    ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear search',
                      onPressed: _clearDataSearch,
                    )
                    : null,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 8),
        _DataCategoryFilters(
          selected: _category,
          counts: _categoryCounts(bindings.bindingPreviews),
          onSelected: (category) => setState(() => _category = category),
        ),
        const SizedBox(height: 6),
        _DataUsageFilters(
          selected: _usageFilter,
          counts: _usageFilterCounts(
            bindings.bindingPreviews,
            usageCounts,
            selectedUsageCounts,
          ),
          onSelected: (filter) => setState(() => _usageFilter = filter),
        ),
        if (hasActiveFilter) ...[
          const SizedBox(height: 10),
          ActiveFilterBar(
            tokens: [
              if (hasQuery)
                ActiveFilterToken(
                  icon: Icons.search,
                  label: 'Search "$_query"',
                  clearTooltip: 'Clear search filter',
                  onClear: _clearDataSearch,
                ),
              if (hasCategoryFilter)
                ActiveFilterToken(
                  icon: _categoryIcon(_category),
                  label: 'Category ${_category.label}',
                  clearTooltip: 'Clear category filter',
                  onClear:
                      () => setState(() => _category = _DataFieldCategory.all),
                ),
              if (hasUsageFilter)
                ActiveFilterToken(
                  icon: _usageFilterIcon(_usageFilter),
                  label: 'Usage ${_usageFilter.label}',
                  clearTooltip: 'Clear usage filter',
                  onClear:
                      () => setState(() => _usageFilter = _DataUsageFilter.all),
                ),
            ],
            onClearAll: _clearDataFilters,
          ),
        ],
        if (visibleUnusedPreviews.isNotEmpty) ...[
          const SizedBox(height: 10),
          _CreateVisibleLabelsButton(
            count: visibleUnusedPreviews.length,
            onPressed:
                () => _createBoundLabels(
                  visibleUnusedPreviews,
                  selectedComponent: selectedComponent,
                  componentCount: layoutState.components.length,
                ),
          ),
        ],
        const SizedBox(height: 12),
        if (previews.isEmpty)
          FilteredEmptyState(
            title: 'No data fields found',
            onAction: hasActiveFilter ? _clearDataFilters : null,
          )
        else
          for (final binding in previews)
            _DataBindingTile(
              binding: binding,
              usageCount: usageCounts[binding.key] ?? 0,
              selectedUsageCount: selectedUsageCounts[binding.key] ?? 0,
              canInsert: selectedComponent != null && attributeKey != null,
              onSelectUsages:
                  usageComponentIds[binding.key] == null
                      ? null
                      : () =>
                          _selectBindingUsages(usageComponentIds[binding.key]!),
              onCopy: () => _copyToken(context, binding.token),
              onCreate:
                  () => _createBoundLabel(
                    binding,
                    selectedComponent: selectedComponent,
                    componentCount: layoutState.components.length,
                  ),
              onInsert:
                  selectedComponent == null || attributeKey == null
                      ? null
                      : () => _insertBinding(
                        selectedComponent,
                        attributeKey,
                        binding.token,
                      ),
            ),
      ],
    );
  }

  List<LayoutBindingPreview> _filteredPreviews(
    LayoutDataBindingValues values,
    Map<String, int> usageCounts,
    Map<String, int> selectedUsageCounts,
  ) {
    final query = _query.toLowerCase();

    return [
      for (final binding in values.bindingPreviews)
        if (_matchesCategory(binding) &&
            _matchesUsage(binding, usageCounts, selectedUsageCounts) &&
            (query.isEmpty ||
                binding.key.toLowerCase().contains(query) ||
                binding.value.toLowerCase().contains(query) ||
                binding.token.toLowerCase().contains(query)))
          binding,
    ];
  }

  Map<_DataFieldCategory, int> _categoryCounts(
    List<LayoutBindingPreview> bindings,
  ) {
    return {
      for (final category in _DataFieldCategory.values)
        category:
            category == _DataFieldCategory.all
                ? bindings.length
                : bindings
                    .where(
                      (binding) => _categoryForKey(binding.key) == category,
                    )
                    .length,
    };
  }

  bool _matchesCategory(LayoutBindingPreview binding) {
    return _category == _DataFieldCategory.all ||
        _categoryForKey(binding.key) == _category;
  }

  Map<_DataUsageFilter, int> _usageFilterCounts(
    List<LayoutBindingPreview> bindings,
    Map<String, int> usageCounts,
    Map<String, int> selectedUsageCounts,
  ) {
    final categorizedBindings = bindings
        .where(_matchesCategory)
        .toList(growable: false);

    return {
      _DataUsageFilter.all: categorizedBindings.length,
      _DataUsageFilter.used:
          categorizedBindings
              .where((binding) => (usageCounts[binding.key] ?? 0) > 0)
              .length,
      _DataUsageFilter.unused:
          categorizedBindings
              .where((binding) => (usageCounts[binding.key] ?? 0) == 0)
              .length,
      _DataUsageFilter.selected:
          categorizedBindings
              .where((binding) => (selectedUsageCounts[binding.key] ?? 0) > 0)
              .length,
    };
  }

  bool _matchesUsage(
    LayoutBindingPreview binding,
    Map<String, int> usageCounts,
    Map<String, int> selectedUsageCounts,
  ) {
    final usageCount = usageCounts[binding.key] ?? 0;
    final selectedUsageCount = selectedUsageCounts[binding.key] ?? 0;

    switch (_usageFilter) {
      case _DataUsageFilter.all:
        return true;
      case _DataUsageFilter.used:
        return usageCount > 0;
      case _DataUsageFilter.unused:
        return usageCount == 0;
      case _DataUsageFilter.selected:
        return selectedUsageCount > 0;
    }
  }

  Map<String, int> _selectedUsageCounts(
    Map<String, Set<String>> usageComponentIds,
    Set<String> selectedComponentIds,
  ) {
    if (selectedComponentIds.isEmpty) return const {};

    return {
      for (final entry in usageComponentIds.entries)
        if (entry.value.any(selectedComponentIds.contains))
          entry.key: entry.value.where(selectedComponentIds.contains).length,
    };
  }

  Map<String, Set<String>> _bindingUsageComponentIds(
    List<ComponentData> components,
  ) {
    final usageComponentIds = <String, Set<String>>{};

    for (final component in components) {
      final componentBindingKeys = <String>{};

      for (final value in component.properties.attributes.values) {
        if (value is! String || !value.contains('{{')) continue;

        for (final match in _bindingTokenRegex.allMatches(value)) {
          final key = match.group(1);
          if (key == null) continue;
          componentBindingKeys.add(key);
        }
      }

      for (final key in componentBindingKeys) {
        usageComponentIds.putIfAbsent(key, () => <String>{}).add(component.id);
      }
    }

    return usageComponentIds;
  }

  Future<void> _copyToken(BuildContext context, String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $token'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _insertBinding(
    ComponentData component,
    String attributeKey,
    String token,
  ) {
    final attributes = Map<String, dynamic>.from(
      component.properties.attributes,
    )..[attributeKey] = token;

    ref
        .read(layoutStateProvider.notifier)
        .updateComponentProperties(
          component.id,
          component.properties.copyWith(attributes: attributes),
        );
  }

  void _selectBindingUsages(Set<String> componentIds) {
    if (componentIds.isEmpty) return;
    ref.read(layoutStateProvider.notifier).selectComponents(componentIds);
  }

  void _clearDataSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearDataFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = _DataFieldCategory.all;
      _usageFilter = _DataUsageFilter.all;
    });
  }

  void _createBoundLabel(
    LayoutBindingPreview binding, {
    required ComponentData? selectedComponent,
    required int componentCount,
  }) {
    ref
        .read(layoutStateProvider.notifier)
        .addComponent(
          createBoundTextLabelFromBinding(
            binding,
            _newLabelPosition(
              selectedComponent: selectedComponent,
              componentCount: componentCount,
            ),
          ),
        );
  }

  void _createBoundLabels(
    List<LayoutBindingPreview> bindings, {
    required ComponentData? selectedComponent,
    required int componentCount,
  }) {
    if (bindings.isEmpty) return;

    final origin = _newLabelPosition(
      selectedComponent: selectedComponent,
      componentCount: componentCount,
    );
    final components = [
      for (var index = 0; index < bindings.length; index++)
        createBoundTextLabelFromBinding(
          bindings[index],
          origin + Offset((index % 2) * 280, (index ~/ 2) * 76),
        ),
    ];

    ref.read(layoutStateProvider.notifier).addComponents(components);
  }

  Offset _newLabelPosition({
    required ComponentData? selectedComponent,
    required int componentCount,
  }) {
    if (selectedComponent != null) {
      return selectedComponent.position +
          Offset(0, selectedComponent.size.height + 12);
    }

    final lane = componentCount % 5;
    final yOffset = (componentCount * 14).clamp(0, 420).toDouble();
    return Offset(72 + (lane * 24), 72 + yOffset);
  }
}

class _DataTargetSummary extends StatelessWidget {
  final ComponentData? component;
  final String? attributeKey;

  const _DataTargetSummary({
    required this.component,
    required this.attributeKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final component = this.component;
    final attributeKey = this.attributeKey;
    final isReady = component != null && attributeKey != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isReady
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              isReady ? Icons.link_outlined : Icons.link_off_outlined,
              size: 18,
              color:
                  isReady
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isReady
                    ? '${component.type.label} - ${_attributeLabel(attributeKey)}'
                    : 'No compatible selection',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isReady
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCategoryFilters extends StatelessWidget {
  final _DataFieldCategory selected;
  final Map<_DataFieldCategory, int> counts;
  final ValueChanged<_DataFieldCategory> onSelected;

  const _DataCategoryFilters({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final category in _DataFieldCategory.values)
          FilterChip(
            label: Text('${category.label} ${counts[category] ?? 0}'),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _DataUsageFilters extends StatelessWidget {
  final _DataUsageFilter selected;
  final Map<_DataUsageFilter, int> counts;
  final ValueChanged<_DataUsageFilter> onSelected;

  const _DataUsageFilters({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final filter in _DataUsageFilter.values)
          FilterChip(
            label: Text('${filter.label} ${counts[filter] ?? 0}'),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _CreateVisibleLabelsButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _CreateVisibleLabelsButton({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.playlist_add_outlined),
        label: Text('Create unused labels ($count)'),
        onPressed: onPressed,
      ),
    );
  }
}

class _DataBindingTile extends StatelessWidget {
  final LayoutBindingPreview binding;
  final int usageCount;
  final int selectedUsageCount;
  final bool canInsert;
  final VoidCallback? onSelectUsages;
  final VoidCallback onCopy;
  final VoidCallback onCreate;
  final VoidCallback? onInsert;

  const _DataBindingTile({
    required this.binding,
    required this.usageCount,
    required this.selectedUsageCount,
    required this.canInsert,
    required this.onSelectUsages,
    required this.onCopy,
    required this.onCreate,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Draggable<LayoutBindingPreview>(
        data: binding,
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: _DataBindingTileContent(
              binding: binding,
              usageCount: usageCount,
              selectedUsageCount: selectedUsageCount,
              canInsert: false,
              onSelectUsages: null,
              onCopy: null,
              onCreate: null,
              onInsert: null,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.45,
          child: _DataBindingTileContent(
            binding: binding,
            usageCount: usageCount,
            selectedUsageCount: selectedUsageCount,
            canInsert: canInsert,
            onSelectUsages: onSelectUsages,
            onCopy: onCopy,
            onCreate: onCreate,
            onInsert: onInsert,
          ),
        ),
        child: _DataBindingTileContent(
          binding: binding,
          usageCount: usageCount,
          selectedUsageCount: selectedUsageCount,
          canInsert: canInsert,
          onSelectUsages: onSelectUsages,
          onCopy: onCopy,
          onCreate: onCreate,
          onInsert: onInsert,
        ),
      ),
    );
  }
}

class _DataBindingTileContent extends StatelessWidget {
  final LayoutBindingPreview binding;
  final int usageCount;
  final int selectedUsageCount;
  final bool canInsert;
  final VoidCallback? onSelectUsages;
  final VoidCallback? onCopy;
  final VoidCallback? onCreate;
  final VoidCallback? onInsert;

  const _DataBindingTileContent({
    required this.binding,
    required this.usageCount,
    required this.selectedUsageCount,
    required this.canInsert,
    required this.onSelectUsages,
    required this.onCopy,
    required this.onCreate,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(_bindingIcon(binding.key), size: 18),
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
                  const SizedBox(height: 2),
                  Text(
                    binding.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (usageCount > 0) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _DataStatusBadge(
                          label: 'Used $usageCount',
                          onTap: onSelectUsages,
                        ),
                        if (selectedUsageCount > 0)
                          _DataStatusBadge(
                            label:
                                selectedUsageCount == 1
                                    ? 'Selected'
                                    : 'Selected $selectedUsageCount',
                            onTap: null,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onCopy != null)
              _CompactIconButton(
                tooltip: 'Copy token',
                icon: const Icon(Icons.copy_outlined),
                onPressed: onCopy,
              ),
            if (onCreate != null)
              _CompactIconButton(
                tooltip: 'Create label',
                icon: const Icon(Icons.note_add_outlined),
                onPressed: onCreate,
              ),
            if (onInsert != null)
              _CompactIconButton(
                tooltip: 'Insert token',
                icon: const Icon(Icons.input_outlined),
                onPressed: canInsert ? onInsert : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final VoidCallback? onPressed;

  const _CompactIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
    );
  }
}

class _DataStatusBadge extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DataStatusBadge({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final badge = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (onTap == null) return badge;

    return Tooltip(
      message: 'Select bound components',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: badge,
      ),
    );
  }
}

final _bindingTokenRegex = RegExp(r'\{\{\s*([\w\.\-]+)\s*\}\}');

enum _DataFieldCategory {
  all,
  store,
  shift,
  user,
  cart,
  products;

  String get label {
    switch (this) {
      case _DataFieldCategory.all:
        return 'All';
      case _DataFieldCategory.store:
        return 'Store';
      case _DataFieldCategory.shift:
        return 'Shift';
      case _DataFieldCategory.user:
        return 'User';
      case _DataFieldCategory.cart:
        return 'Cart';
      case _DataFieldCategory.products:
        return 'Products';
    }
  }
}

enum _DataUsageFilter {
  all,
  used,
  unused,
  selected;

  String get label {
    switch (this) {
      case _DataUsageFilter.all:
        return 'All';
      case _DataUsageFilter.used:
        return 'Used';
      case _DataUsageFilter.unused:
        return 'Unused';
      case _DataUsageFilter.selected:
        return 'Selected';
    }
  }
}

_DataFieldCategory _categoryForKey(String key) {
  if (key.startsWith('store.')) return _DataFieldCategory.store;
  if (key.startsWith('shift.')) return _DataFieldCategory.shift;
  if (key.startsWith('user.')) return _DataFieldCategory.user;
  if (key.startsWith('cart.')) return _DataFieldCategory.cart;
  if (key.startsWith('products.')) return _DataFieldCategory.products;
  return _DataFieldCategory.all;
}

IconData _categoryIcon(_DataFieldCategory category) {
  switch (category) {
    case _DataFieldCategory.all:
      return Icons.data_object_outlined;
    case _DataFieldCategory.store:
      return Icons.storefront_outlined;
    case _DataFieldCategory.shift:
      return Icons.schedule_outlined;
    case _DataFieldCategory.user:
      return Icons.person_outline;
    case _DataFieldCategory.cart:
      return Icons.receipt_long_outlined;
    case _DataFieldCategory.products:
      return Icons.inventory_2_outlined;
  }
}

IconData _usageFilterIcon(_DataUsageFilter filter) {
  switch (filter) {
    case _DataUsageFilter.all:
      return Icons.link_outlined;
    case _DataUsageFilter.used:
      return Icons.check_circle_outline;
    case _DataUsageFilter.unused:
      return Icons.radio_button_unchecked;
    case _DataUsageFilter.selected:
      return Icons.ads_click_outlined;
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

String _attributeLabel(String key) {
  switch (key) {
    case 'label':
      return 'Label';
    case 'text':
      return 'Text';
    default:
      return key;
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
