import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';

typedef InventoryProductCatalogTableColumnCellBuilder =
    Widget Function(BuildContext context, InventoryProductCatalogRecord record);

class InventoryProductCatalogTableColumnContribution {
  const InventoryProductCatalogTableColumnContribution({
    required this.id,
    required this.label,
    required this.cellBuilder,
    this.tooltip,
    this.sectionLabel = 'Extensions',
    this.priority = 0,
    this.defaultVisible = true,
    this.numeric = false,
  });

  final String id;
  final String label;
  final String? tooltip;
  final String sectionLabel;
  final int priority;
  final bool defaultVisible;
  final bool numeric;
  final InventoryProductCatalogTableColumnCellBuilder cellBuilder;

  String get normalizedId => id.trim();

  String get resolvedSectionLabel {
    final normalizedLabel = sectionLabel.trim();
    if (normalizedLabel.isEmpty) return 'Extensions';

    return normalizedLabel;
  }
}

List<InventoryProductCatalogTableColumnContribution>
normalizeInventoryProductCatalogTableColumnContributions(
  Iterable<InventoryProductCatalogTableColumnContribution> contributions,
) {
  final contributionById =
      <String, InventoryProductCatalogTableColumnContribution>{};
  final firstOrderById = <String, int>{};
  var index = 0;

  for (final contribution in contributions) {
    final id = contribution.normalizedId;
    if (id.isEmpty) continue;
    firstOrderById.putIfAbsent(id, () => index);

    contributionById[id] = contribution;
    index += 1;
  }

  final normalized = contributionById.entries.toList(growable: false)
    ..sort((left, right) {
      final priorityComparison = left.value.priority.compareTo(
        right.value.priority,
      );
      if (priorityComparison != 0) return priorityComparison;

      return firstOrderById[left.key]!.compareTo(firstOrderById[right.key]!);
    });

  return List.unmodifiable([for (final entry in normalized) entry.value]);
}
