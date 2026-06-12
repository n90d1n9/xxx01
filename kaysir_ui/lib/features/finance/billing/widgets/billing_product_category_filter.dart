import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/billing_product_catalog_provider.dart';

class BillingProductCategoryFilter extends ConsumerWidget {
  final String tenantId;

  const BillingProductCategoryFilter({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory =
        ref.watch(productCatalogFilterProvider(tenantId)).category;
    final categoriesAsync = ref.watch(productCategoriesProvider(tenantId));

    return categoriesAsync.when(
      data: (categories) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _CategoryChip(
                label: 'All',
                selected: selectedCategory == null,
                onSelected: () {
                  _setCategory(ref, null);
                },
              ),
              const SizedBox(width: 8),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: category,
                    selected: selectedCategory == category,
                    onSelected: () {
                      _setCategory(
                        ref,
                        selectedCategory == category ? null : category,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, _) => const SizedBox(
            height: 56,
            child: Center(child: Text('Failed to load categories')),
          ),
    );
  }

  void _setCategory(WidgetRef ref, String? category) {
    final notifier = ref.read(productCatalogFilterProvider(tenantId).notifier);
    notifier.state = notifier.state.withCategory(category);
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFFDBEAFE),
      checkmarkColor: const Color(0xFF2563EB),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
