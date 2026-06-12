import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';

import '../models/search_result.dart';
import '../states/search_provider.dart';
import '../states/search_state.dart';

class SearchForm extends ConsumerStatefulWidget {
  const SearchForm({super.key});

  @override
  ConsumerState<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends ConsumerState<SearchForm> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            !constraints.hasBoundedHeight || constraints.maxHeight < 160;

        if (isCompact) {
          return _buildSearchField(dense: true);
        }

        return _buildExpandedSearch(searchState);
      },
    );
  }

  Widget _buildExpandedSearch(SearchState searchState) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: _buildSearchField()),

        if (searchState.suggestions.isNotEmpty) _buildSuggestions(searchState),

        if (searchState.isAdvancedSearch) _buildAdvancedSearchOptions(),

        Expanded(child: _buildSearchResults(searchState.results)),
      ],
    );
  }

  Widget _buildSearchField({bool dense = false}) {
    return AppSearchField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: 'Search...',
      height: dense ? 42 : 48,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconActionButton(
            icon: Icons.tune,
            tooltip: 'Advanced search',
            onPressed: () {
              ref.read(searchProvider.notifier).toggleAdvancedSearch();
            },
            size: dense ? 34 : 38,
            iconSize: dense ? 18 : 20,
          ),
          AppIconActionButton(
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: _performSearch,
            variant: AppIconActionButtonVariant.tonal,
            size: dense ? 34 : 38,
            iconSize: dense ? 18 : 20,
          ),
        ],
      ),
      onChanged: (value) {
        ref.read(searchProvider.notifier).updateQuery(value);
      },
      onSubmitted: (_) => _performSearch(),
    );
  }

  Widget _buildAdvancedSearchOptions() {
    final filters = ref.watch(searchProvider).advancedFilters;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final isNarrow = constraints.maxWidth < 520;
          final itemWidth =
              isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: itemWidth,
                child: _buildAdvancedFilter(
                  title: 'Filter 1',
                  icon: Icons.filter_alt_outlined,
                  value: filters['filter1'] ?? false,
                  onChanged:
                      (value) =>
                          _updateAdvancedFilter('filter1', value ?? false),
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _buildAdvancedFilter(
                  title: 'Filter 2',
                  icon: Icons.rule_outlined,
                  value: filters['filter2'] ?? false,
                  onChanged:
                      (value) =>
                          _updateAdvancedFilter('filter2', value ?? false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFilter({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return AppCheckboxRow(
      title: title,
      icon: icon,
      iconBadge: true,
      contained: true,
      value: value,
      onChanged: onChanged,
    );
  }

  void _updateAdvancedFilter(String key, bool value) {
    ref.read(searchProvider.notifier).updateAdvancedFilters({
      ...ref.read(searchProvider).advancedFilters,
      key: value,
    });
  }

  Widget _buildSuggestions(SearchState searchState) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: searchState.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = searchState.suggestions[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(suggestion),
              onPressed: () {
                _searchController.text = suggestion;
                ref.read(searchProvider.notifier).updateQuery(suggestion);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List<SearchResult> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return DefaultTabController(
      length: 3, // Number of categories
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Category A'),
              Tab(text: 'Category B'),
              Tab(text: 'Category C'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCategoryResultList(
                  results.where((r) => r.category == 'Category A').toList(),
                ),
                _buildCategoryResultList(
                  results.where((r) => r.category == 'Category B').toList(),
                ),
                _buildCategoryResultList(
                  results.where((r) => r.category == 'Category C').toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResultList(List<SearchResult> categoryResults) {
    return ListView.builder(
      itemCount: categoryResults.length,
      itemBuilder: (context, index) {
        final result = categoryResults[index];
        return ListTile(
          leading: Image.network(
            result.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (_, _, _) => const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.image_not_supported_outlined),
                ),
          ),
          title: Text(result.title),
          subtitle: Text(result.description),
        );
      },
    );
  }

  void _performSearch() {
    ref.read(searchProvider.notifier).performSearch();
  }
}
