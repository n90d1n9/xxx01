import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Describes one sort option shown in [KyBuilderLibraryToolbar].
class KyBuilderSortOption<T extends Object> {
  final T value;
  final String label;
  final String keySuffix;

  const KyBuilderSortOption({
    required this.value,
    required this.label,
    required this.keySuffix,
  });
}

/// Combines library search, result counts, and sort controls.
class KyBuilderLibraryToolbar<T extends Object> extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String searchHint;
  final TextInputAction? searchInputAction;
  final Key? searchClearKey;
  final bool showSearchClearButton;
  final int visibleCount;
  final int totalCount;
  final String itemLabel;
  final String itemPluralLabel;
  final T selectedSortValue;
  final List<KyBuilderSortOption<T>> sortOptions;
  final ValueChanged<T> onSortChanged;
  final Key? searchFieldKey;
  final Key? countKey;
  final Key? sortMenuKey;
  final String sortOptionKeyPrefix;
  final String sortTooltip;

  const KyBuilderLibraryToolbar({
    super.key,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.visibleCount,
    required this.totalCount,
    required this.selectedSortValue,
    required this.sortOptions,
    required this.onSortChanged,
    this.searchHint = 'Search',
    this.searchInputAction,
    this.onSearchSubmitted,
    this.searchClearKey,
    this.showSearchClearButton = true,
    this.itemLabel = 'item',
    this.itemPluralLabel = 'items',
    this.searchFieldKey,
    this.countKey,
    this.sortMenuKey,
    this.sortOptionKeyPrefix = 'ky-builder-library-sort',
    this.sortTooltip = 'Sort',
  }) : assert(sortOptions.length > 0);

  @override
  State<KyBuilderLibraryToolbar<T>> createState() =>
      _KyBuilderLibraryToolbarState<T>();
}

@Preview(name: 'Builder library toolbar')
Widget kyBuilderLibraryToolbarPreview() {
  return KyBuilderLibraryToolbar<String>(
    searchQuery: '',
    searchHint: 'Search components',
    visibleCount: 4,
    totalCount: 12,
    itemLabel: 'component',
    itemPluralLabel: 'components',
    selectedSortValue: 'catalog',
    sortOptions: const [
      KyBuilderSortOption(
        value: 'catalog',
        label: 'Catalog order',
        keySuffix: 'catalog',
      ),
      KyBuilderSortOption(value: 'name', label: 'Name A-Z', keySuffix: 'name'),
    ],
    onSearchQueryChanged: (_) {},
    onSortChanged: (_) {},
  );
}

/// Maintains the toolbar search field controller.
class _KyBuilderLibraryToolbarState<T extends Object>
    extends State<KyBuilderLibraryToolbar<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(KyBuilderLibraryToolbar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery == _searchController.text) {
      return;
    }
    _searchController.text = widget.searchQuery;
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: widget.searchFieldKey,
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                widget.showSearchClearButton &&
                        _searchController.text.isNotEmpty
                    ? IconButton(
                      key: widget.searchClearKey,
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close),
                    )
                    : null,
            hintText: widget.searchHint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          textInputAction: widget.searchInputAction,
          onChanged: _handleSearchChanged,
          onFieldSubmitted: widget.onSearchSubmitted,
        ),
        const SizedBox(height: 12),
        _KyBuilderLibrarySortRow<T>(
          countKey: widget.countKey,
          sortMenuKey: widget.sortMenuKey,
          visibleCount: widget.visibleCount,
          totalCount: widget.totalCount,
          itemLabel: widget.itemLabel,
          itemPluralLabel: widget.itemPluralLabel,
          selectedSortValue: widget.selectedSortValue,
          sortOptions: widget.sortOptions,
          onSortChanged: widget.onSortChanged,
          sortOptionKeyPrefix: widget.sortOptionKeyPrefix,
          sortTooltip: widget.sortTooltip,
        ),
      ],
    );
  }

  void _handleSearchChanged(String value) {
    setState(() {});
    widget.onSearchQueryChanged(value);
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty) {
      return;
    }
    _searchController.clear();
    setState(() {});
    widget.onSearchQueryChanged('');
  }
}

/// Shows the current result count and sort menu.
class _KyBuilderLibrarySortRow<T extends Object> extends StatelessWidget {
  final Key? countKey;
  final Key? sortMenuKey;
  final int visibleCount;
  final int totalCount;
  final String itemLabel;
  final String itemPluralLabel;
  final T selectedSortValue;
  final List<KyBuilderSortOption<T>> sortOptions;
  final ValueChanged<T> onSortChanged;
  final String sortOptionKeyPrefix;
  final String sortTooltip;

  const _KyBuilderLibrarySortRow({
    required this.countKey,
    required this.sortMenuKey,
    required this.visibleCount,
    required this.totalCount,
    required this.itemLabel,
    required this.itemPluralLabel,
    required this.selectedSortValue,
    required this.sortOptions,
    required this.onSortChanged,
    required this.sortOptionKeyPrefix,
    required this.sortTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedOption = _selectedSortOption;

    return Row(
      children: [
        Expanded(
          child: Text(
            _countLabel,
            key: countKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        PopupMenuButton<T>(
          key: sortMenuKey,
          tooltip: sortTooltip,
          initialValue: selectedSortValue,
          onSelected: onSortChanged,
          itemBuilder:
              (context) => [
                for (final option in sortOptions)
                  PopupMenuItem<T>(
                    key: ValueKey('$sortOptionKeyPrefix-${option.keySuffix}'),
                    value: option.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option.value == selectedSortValue
                              ? Icons.check_outlined
                              : Icons.sort_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(option.label),
                      ],
                    ),
                  ),
              ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    selectedOption.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  KyBuilderSortOption<T> get _selectedSortOption {
    return sortOptions.firstWhere(
      (option) => option.value == selectedSortValue,
      orElse: () => sortOptions.first,
    );
  }

  String get _countLabel {
    final label = totalCount == 1 ? itemLabel : itemPluralLabel;
    return '$visibleCount of $totalCount $label';
  }
}
