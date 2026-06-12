import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/pos_catalog_filter_provider.dart';
import '../utils/pos_error_copy.dart';
import 'pos_ui.dart';

class CategoryFilter extends ConsumerWidget {
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(posCatalogCategoriesProvider);
    final selectedCategory =
        ref.watch(posCatalogFilterProvider).category ?? 'All';
    final theme = Theme.of(context);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: POSUiTokens.gap),
              child: POSChoicePill(
                label: category,
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category);
                  }
                },
              ),
            );
          },
        );
      },
      loading:
          () => Center(
            child: SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
      error:
          (error, stackTrace) => Center(
            child: Text(
              friendlyPOSErrorMessage(
                error,
                fallbackMessage: 'Categories unavailable.',
              ),
            ),
          ),
    );
  }
}
