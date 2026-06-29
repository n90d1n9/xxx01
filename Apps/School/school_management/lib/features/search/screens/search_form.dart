import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_result.dart';
import '../states/search_provider.dart';

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

    return Column(
      children: [
        /*  IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            _showSettingsBottomSheet(context);
          },
        ), */
        // Search Input
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search...',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      ref.read(searchProvider.notifier).toggleAdvancedSearch();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      ref.read(searchProvider.notifier).performSearch();
                    },
                  ),
                ],
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(searchProvider.notifier).updateQuery(value);
            },
          ),
        )),

        // Suggestions
        if (searchState.suggestions.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: searchState.suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    label: Text(searchState.suggestions[index]),
                    onDeleted: () {},
                  ),
                );
              },
            ),
          ),

        // Advanced Search Options
        if (searchState.isAdvancedSearch)
          _buildAdvancedSearchOptions(context, ref),

        // Search Results
        Expanded(
          child: _buildSearchResults(searchState.results),
        ),
      ],
    );
  }

  Widget _buildAdvancedSearchOptions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Example advanced filter options
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Filter 1'),
                  value: ref.watch(searchProvider).advancedFilters['filter1'] ??
                      false,
                  onChanged: (bool? value) {
                    ref.read(searchProvider.notifier).updateAdvancedFilters({
                      ...ref.read(searchProvider).advancedFilters,
                      'filter1': value ?? false,
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Filter 2'),
                  value: ref.watch(searchProvider).advancedFilters['filter2'] ??
                      false,
                  onChanged: (bool? value) {
                    ref.read(searchProvider.notifier).updateAdvancedFilters({
                      ...ref.read(searchProvider).advancedFilters,
                      'filter2': value ?? false,
                    });
                  },
                ),
              ),
            ],
          ),
        ],
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
                    results.where((r) => r.category == 'Category A').toList()),
                _buildCategoryResultList(
                    results.where((r) => r.category == 'Category B').toList()),
                _buildCategoryResultList(
                    results.where((r) => r.category == 'Category C').toList()),
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
          ),
          title: Text(result.title),
          subtitle: Text(result.description),
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Search Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: false, // Replace with actual theme state management
                onChanged: (bool value) {
                  // Implement theme switching logic
                },
              ),
              // Add more settings as needed
            ],
          ),
        );
      },
    );
  }
}
