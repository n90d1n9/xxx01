import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/pattern_library_provider.dart';
import 'pattern_card.dart';

class PatternLibraryPanel extends ConsumerStatefulWidget {
  const PatternLibraryPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<PatternLibraryPanel> createState() =>
      _PatternLibraryPanelState();
}

class _PatternLibraryPanelState extends ConsumerState<PatternLibraryPanel> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patternState = ref.watch(patternLibraryProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Library',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag patterns onto canvas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patterns...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(patternLibraryProvider.notifier).search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                ref.read(patternLibraryProvider.notifier).search(value);
              },
            ),
          ),

          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('All', null, patternState.selectedCategory),
                _buildCategoryChip(
                  'Messaging',
                  'messaging',
                  patternState.selectedCategory,
                ),
                _buildCategoryChip(
                  'Routing',
                  'routing',
                  patternState.selectedCategory,
                ),
                _buildCategoryChip(
                  'Transform',
                  'transformation',
                  patternState.selectedCategory,
                ),
                _buildCategoryChip(
                  'Endpoint',
                  'endpoint',
                  patternState.selectedCategory,
                ),
                _buildCategoryChip('AI', 'ai', patternState.selectedCategory),
              ],
            ),
          ),

          const Divider(),

          // Pattern list
          Expanded(
            child: patternState.filteredPatterns.isEmpty
                ? Center(
                    child: Text(
                      'No patterns found',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: patternState.filteredPatterns.length,
                    itemBuilder: (context, index) {
                      final pattern = patternState.filteredPatterns[index];
                      return PatternCard(pattern: pattern);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value, String? selected) {
    final isSelected = (value == null && selected == null) || value == selected;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref
              .read(patternLibraryProvider.notifier)
              .filterByCategory(selected ? value : null);
        },
      ),
    );
  }
}
