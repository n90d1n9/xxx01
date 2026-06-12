import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_product_filter.dart';
import '../states/billing_product_catalog_provider.dart';

class BillingProductCatalogToolbar extends ConsumerStatefulWidget {
  final String tenantId;

  const BillingProductCatalogToolbar({super.key, required this.tenantId});

  @override
  ConsumerState<BillingProductCatalogToolbar> createState() =>
      _BillingProductCatalogToolbarState();
}

class _BillingProductCatalogToolbarState
    extends ConsumerState<BillingProductCatalogToolbar> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: ref.read(productCatalogFilterProvider(widget.tenantId)).query,
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BillingProductCatalogFilter>(
      productCatalogFilterProvider(widget.tenantId),
      (previous, next) {
        if (_queryController.text == next.query) return;
        _queryController.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      },
    );

    final filter = ref.watch(productCatalogFilterProvider(widget.tenantId));
    final productsAsync = ref.watch(productsProvider(widget.tenantId));
    final filteredAsync = ref.watch(filteredProductsProvider(widget.tenantId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;
            final countLabel = _countLabel(productsAsync, filteredAsync);

            final searchField = TextField(
              controller: _queryController,
              onChanged: (value) {
                _updateFilter(ref, (filter) => filter.withQuery(value));
              },
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    filter.query.trim().isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _updateFilter(
                              ref,
                              (filter) => filter.withQuery(''),
                            );
                          },
                        ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: _inputBorder(const Color(0xFFE2E8F0)),
                enabledBorder: _inputBorder(const Color(0xFFE2E8F0)),
                focusedBorder: _inputBorder(const Color(0xFF2563EB)),
              ),
            );

            final sortMenu = _SortMenu(
              tenantId: widget.tenantId,
              sort: filter.sort,
            );
            final footer = _CatalogToolbarFooter(
              tenantId: widget.tenantId,
              countLabel: countLabel,
              hasActiveControls: filter.hasActiveFilters,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  sortMenu,
                  const SizedBox(height: 8),
                  footer,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: sortMenu),
                const SizedBox(width: 10),
                footer,
              ],
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }

  String _countLabel<T, U>(
    AsyncValue<List<T>> totalAsync,
    AsyncValue<List<U>> filteredAsync,
  ) {
    return filteredAsync.maybeWhen(
      data:
          (filtered) => totalAsync.maybeWhen(
            data: (total) => '${filtered.length}/${total.length}',
            orElse: () => '${filtered.length}',
          ),
      orElse: () => '',
    );
  }

  void _updateFilter(
    WidgetRef ref,
    BillingProductCatalogFilter Function(BillingProductCatalogFilter filter)
    update,
  ) {
    final notifier = ref.read(
      productCatalogFilterProvider(widget.tenantId).notifier,
    );
    notifier.state = update(notifier.state);
  }
}

class _SortMenu extends ConsumerWidget {
  final String tenantId;
  final BillingProductSortOption sort;

  const _SortMenu({required this.tenantId, required this.sort});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BillingProductSortOption>(
          value: sort,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items:
              BillingProductSortOption.values
                  .map(
                    (option) => DropdownMenuItem<BillingProductSortOption>(
                      value: option,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value == null) return;
            final notifier = ref.read(
              productCatalogFilterProvider(tenantId).notifier,
            );
            notifier.state = notifier.state.withSort(value);
          },
        ),
      ),
    );
  }
}

class _CatalogToolbarFooter extends ConsumerWidget {
  final String tenantId;
  final String countLabel;
  final bool hasActiveControls;

  const _CatalogToolbarFooter({
    required this.tenantId,
    required this.countLabel,
    required this.hasActiveControls,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (countLabel.isNotEmpty)
          Text(
            '$countLabel items',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        if (hasActiveControls) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              final notifier = ref.read(
                productCatalogFilterProvider(tenantId).notifier,
              );
              notifier.state = notifier.state.reset();
            },
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: const Text('Reset'),
          ),
        ],
      ],
    );
  }
}
