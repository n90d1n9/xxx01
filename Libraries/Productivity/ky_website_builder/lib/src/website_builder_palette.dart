import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_presets.dart';
import 'website_builder_preset_source_badge.dart';

typedef WebsiteBuilderPalettePresetAdder =
    void Function(
      BuilderComponentKind kind,
      WebsiteBuilderComponentPreset preset,
    );
typedef WebsiteBuilderPalettePresetProvider =
    List<WebsiteBuilderComponentPreset> Function(String kindKey);
typedef WebsiteBuilderPalettePresetMatcher =
    List<WebsiteBuilderComponentPreset> Function(String kindKey, String query);
typedef WebsiteBuilderPalettePresetMatchChecker =
    bool Function(String kindKey, String query);

enum _PaletteSortMode { catalog, name, category }

extension _PaletteSortModeLabel on _PaletteSortMode {
  String get label {
    return switch (this) {
      _PaletteSortMode.catalog => 'Catalog order',
      _PaletteSortMode.name => 'Name A-Z',
      _PaletteSortMode.category => 'Category',
    };
  }

  String get keySuffix {
    return switch (this) {
      _PaletteSortMode.catalog => 'catalog',
      _PaletteSortMode.name => 'name',
      _PaletteSortMode.category => 'category',
    };
  }
}

class WebsiteBuilderPalette extends StatefulWidget {
  final BuilderComponentCatalog catalog;
  final String query;
  final String selectedCategory;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<BuilderComponentKind> onAddComponent;
  final WebsiteBuilderPalettePresetAdder onAddComponentPreset;
  final WebsiteBuilderPalettePresetProvider? presetProvider;
  final WebsiteBuilderPalettePresetMatcher? presetMatcher;
  final WebsiteBuilderPalettePresetMatchChecker? presetMatchChecker;

  const WebsiteBuilderPalette({
    super.key,
    required this.catalog,
    required this.query,
    required this.selectedCategory,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onAddComponent,
    required this.onAddComponentPreset,
    this.presetProvider,
    this.presetMatcher,
    this.presetMatchChecker,
  });

  @override
  State<WebsiteBuilderPalette> createState() => _WebsiteBuilderPaletteState();
}

class _WebsiteBuilderPaletteState extends State<WebsiteBuilderPalette> {
  _PaletteSortMode _sortMode = _PaletteSortMode.catalog;

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...widget.catalog.categories];
    final effectivePresetProvider =
        widget.presetProvider ?? websiteBuilderPresetsFor;
    final effectivePresetMatcher =
        widget.presetMatcher ?? websiteBuilderPresetsMatching;
    final effectivePresetMatchChecker =
        widget.presetMatchChecker ?? websiteBuilderKindHasPresetMatch;
    final filteredItems = _paletteItemsFor(
      catalog: widget.catalog,
      query: widget.query,
      category:
          widget.selectedCategory == 'All' ? null : widget.selectedCategory,
      presetMatchChecker: effectivePresetMatchChecker,
    );
    final items = _sortedPaletteItems(filteredItems, _sortMode);

    return KyBuilderSurface(
      title: 'Components',
      subtitle: '${items.length} available',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KyBuilderLibraryToolbar<_PaletteSortMode>(
            searchFieldKey: const ValueKey('website-builder-palette-search'),
            searchClearKey: const ValueKey(
              'website-builder-palette-search-clear',
            ),
            countKey: const ValueKey('website-builder-palette-count'),
            sortMenuKey: const ValueKey('website-builder-palette-sort'),
            sortOptionKeyPrefix: 'website-builder-palette-sort',
            searchQuery: widget.query,
            searchHint: 'Search components',
            searchInputAction: TextInputAction.done,
            visibleCount: items.length,
            totalCount: widget.catalog.kinds.length,
            itemLabel: 'component',
            itemPluralLabel: 'components',
            selectedSortValue: _sortMode,
            sortOptions: [
              for (final mode in _PaletteSortMode.values)
                KyBuilderSortOption<_PaletteSortMode>(
                  value: mode,
                  label: mode.label,
                  keySuffix: mode.keySuffix,
                ),
            ],
            onSearchQueryChanged: widget.onQueryChanged,
            onSearchSubmitted: (submittedQuery) {
              _quickAddFromSearch(
                items: items,
                query: submittedQuery,
                onAddComponent: widget.onAddComponent,
                onAddComponentPreset: widget.onAddComponentPreset,
                presetMatcher: effectivePresetMatcher,
              );
            },
            onSortChanged: (sortMode) => setState(() => _sortMode = sortMode),
          ),
          const SizedBox(height: 12),
          KyBuilderFilterChipBar<String>(
            optionKeyPrefix: 'website-builder-palette-category',
            options: categories,
            selectedValue: widget.selectedCategory,
            labelBuilder: (category) => category,
            onChanged: widget.onCategoryChanged,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final itemMatchesQuery = item.matches(widget.query);
                final matchedPresets =
                    itemMatchesQuery
                        ? const <WebsiteBuilderComponentPreset>[]
                        : effectivePresetMatcher(item.key, widget.query);
                final presets =
                    itemMatchesQuery
                        ? effectivePresetProvider(item.key)
                        : matchedPresets;
                final onPrimaryTap =
                    matchedPresets.length == 1
                        ? () => widget.onAddComponentPreset(
                          item,
                          matchedPresets.single,
                        )
                        : () => widget.onAddComponent(item);
                return Draggable<BuilderComponentKind>(
                  data: item,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 220,
                      child: _PaletteTile(
                        item: item,
                        presets: const [],
                        matchedPresets: const [],
                        onTap: () {},
                        onPresetTap: null,
                        dragging: true,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.42,
                    child: _PaletteTile(
                      item: item,
                      presets: presets,
                      matchedPresets: matchedPresets,
                      onTap: onPrimaryTap,
                      onPresetTap:
                          (preset) => widget.onAddComponentPreset(item, preset),
                    ),
                  ),
                  child: _PaletteTile(
                    item: item,
                    presets: presets,
                    matchedPresets: matchedPresets,
                    onTap: onPrimaryTap,
                    onPresetTap:
                        (preset) => widget.onAddComponentPreset(item, preset),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  final BuilderComponentKind item;
  final List<WebsiteBuilderComponentPreset> presets;
  final List<WebsiteBuilderComponentPreset> matchedPresets;
  final VoidCallback onTap;
  final ValueChanged<WebsiteBuilderComponentPreset>? onPresetTap;
  final bool dragging;

  const _PaletteTile({
    required this.item,
    required this.presets,
    required this.matchedPresets,
    required this.onTap,
    required this.onPresetTap,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final menuPresets =
        dragging || onPresetTap == null
            ? const <WebsiteBuilderComponentPreset>[]
            : presets;

    return KyBuilderLibraryTile(
      key: ValueKey('website-builder-palette-tile-${item.key}'),
      dragging: dragging,
      minLeadingWidth: 36,
      leading: Icon(_iconForComponent(item), color: colorScheme.primary),
      title: Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: _PaletteTileSubtitle(
        description: item.description,
        matchedPresets: matchedPresets,
      ),
      trailing:
          menuPresets.isEmpty
              ? const Icon(Icons.add_circle_outline)
              : _PalettePresetMenu(
                item: item,
                presets: menuPresets,
                onPresetTap: onPresetTap!,
              ),
      onTap: onTap,
    );
  }
}

class _PaletteTileSubtitle extends StatelessWidget {
  final String description;
  final List<WebsiteBuilderComponentPreset> matchedPresets;

  const _PaletteTileSubtitle({
    required this.description,
    required this.matchedPresets,
  });

  @override
  Widget build(BuildContext context) {
    if (matchedPresets.isEmpty) {
      return Text(description, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final preset in matchedPresets.take(2))
              _MatchedPresetBadge(preset: preset),
            if (matchedPresets.length > 2)
              _MatchedPresetOverflowBadge(
                hiddenCount: matchedPresets.length - 2,
              ),
          ],
        ),
      ],
    );
  }
}

/// Shows the best matching saved or built-in preset inside search results.
class _MatchedPresetBadge extends StatelessWidget {
  final WebsiteBuilderComponentPreset preset;

  const _MatchedPresetBadge({required this.preset});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return KyBuilderBadge(
      key: ValueKey(
        'website-builder-palette-match-${preset.kindKey}-${preset.id}',
      ),
      label: preset.label,
      icon: Icons.auto_awesome_motion_outlined,
      trailing: WebsiteBuilderPresetSourceBadge(
        preset: preset,
        dense: true,
        shortLabel: true,
      ),
      maxWidth: 214,
      radius: 8,
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.72),
      borderColor: colorScheme.primary.withValues(alpha: 0.2),
      foregroundColor: colorScheme.onPrimaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
  }
}

/// Displays the number of hidden preset matches in a compact badge.
class _MatchedPresetOverflowBadge extends StatelessWidget {
  final int hiddenCount;

  const _MatchedPresetOverflowBadge({required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return KyBuilderBadge(
      label: '+$hiddenCount',
      radius: 8,
      backgroundColor: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.outlineVariant,
      foregroundColor: colorScheme.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
  }
}

List<BuilderComponentKind> _paletteItemsFor({
  required BuilderComponentCatalog catalog,
  required String query,
  required String? category,
  required WebsiteBuilderPalettePresetMatchChecker presetMatchChecker,
}) {
  final normalizedCategory = category == 'All' ? null : category;
  return [
    for (final item in catalog.search(query: '', category: normalizedCategory))
      if (item.matches(query) || presetMatchChecker(item.key, query)) item,
  ];
}

List<BuilderComponentKind> _sortedPaletteItems(
  List<BuilderComponentKind> items,
  _PaletteSortMode sortMode,
) {
  final sortedItems = [...items];

  switch (sortMode) {
    case _PaletteSortMode.catalog:
      return sortedItems;
    case _PaletteSortMode.name:
      sortedItems.sort(_comparePaletteItemLabels);
      return sortedItems;
    case _PaletteSortMode.category:
      sortedItems.sort((left, right) {
        final categoryComparison = left.category.toLowerCase().compareTo(
          right.category.toLowerCase(),
        );
        if (categoryComparison != 0) {
          return categoryComparison;
        }
        return _comparePaletteItemLabels(left, right);
      });
      return sortedItems;
  }
}

int _comparePaletteItemLabels(
  BuilderComponentKind left,
  BuilderComponentKind right,
) {
  final labelComparison = left.label.toLowerCase().compareTo(
    right.label.toLowerCase(),
  );
  if (labelComparison != 0) {
    return labelComparison;
  }
  return left.key.compareTo(right.key);
}

void _quickAddFromSearch({
  required List<BuilderComponentKind> items,
  required String query,
  required ValueChanged<BuilderComponentKind> onAddComponent,
  required WebsiteBuilderPalettePresetAdder onAddComponentPreset,
  required WebsiteBuilderPalettePresetMatcher presetMatcher,
}) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty || items.isEmpty) return;

  for (final item in items) {
    if (item.matches(normalizedQuery)) continue;
    final matchingPresets = presetMatcher(item.key, normalizedQuery);
    if (matchingPresets.isEmpty) continue;
    onAddComponentPreset(item, matchingPresets.first);
    return;
  }

  onAddComponent(items.first);
}

class _PalettePresetMenu extends StatelessWidget {
  final BuilderComponentKind item;
  final List<WebsiteBuilderComponentPreset> presets;
  final ValueChanged<WebsiteBuilderComponentPreset> onPresetTap;

  const _PalettePresetMenu({
    required this.item,
    required this.presets,
    required this.onPresetTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopupMenuButton<WebsiteBuilderComponentPreset>(
      key: ValueKey('website-builder-palette-presets-${item.key}'),
      tooltip: 'Add with content preset',
      icon: const Icon(Icons.library_add_outlined),
      onSelected: onPresetTap,
      itemBuilder:
          (context) => [
            for (final preset in presets)
              PopupMenuItem(
                key: ValueKey(
                  'website-builder-palette-preset-${item.key}-${preset.id}',
                ),
                value: preset,
                child: SizedBox(
                  width: 236,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              preset.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          WebsiteBuilderPresetSourceBadge(
                            preset: preset,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
    );
  }
}

IconData _iconForComponent(BuilderComponentKind item) {
  return switch (item.key) {
    'hero' => Icons.web_asset,
    'section' => Icons.view_agenda_outlined,
    'two_column' => Icons.view_column,
    'text_block' => Icons.notes,
    'image' => Icons.image_outlined,
    'gallery' => Icons.photo_library_outlined,
    'button' => Icons.smart_button_outlined,
    'form' => Icons.dynamic_form_outlined,
    'pricing' => Icons.sell_outlined,
    'product_card' => Icons.shopping_bag_outlined,
    _ => Icons.widgets_outlined,
  };
}
