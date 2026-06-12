import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_column_contribution.dart';

class InventoryProductCatalogTableExtensionColumnButton
    extends StatelessWidget {
  const InventoryProductCatalogTableExtensionColumnButton({
    super.key,
    required this.preferences,
    required this.contributions,
    required this.onChanged,
  });

  final InventoryProductCatalogTablePreferences preferences;
  final List<InventoryProductCatalogTableColumnContribution> contributions;
  final ValueChanged<InventoryProductCatalogTablePreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Choose extension columns',
      icon: const Icon(Icons.extension_rounded),
      itemBuilder: (context) => _extensionColumnMenuItems(),
      onSelected: _toggleContributionColumn,
    );
  }

  List<PopupMenuEntry<String>> _extensionColumnMenuItems() {
    final entries = <PopupMenuEntry<String>>[];
    var activeSection = '';

    for (final contribution in contributions) {
      final section = contribution.resolvedSectionLabel;
      if (section != activeSection) {
        if (entries.isNotEmpty) {
          entries.add(const PopupMenuDivider(height: 4));
        }
        entries.add(
          PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: _ContributionColumnSectionHeader(label: section),
          ),
        );
        activeSection = section;
      }

      entries.add(
        CheckedPopupMenuItem<String>(
          key: ValueKey(
            'inventory-product-table-contribution-column-'
            '${contribution.normalizedId}',
          ),
          value: contribution.normalizedId,
          checked: preferences.isContributionVisible(
            contribution.normalizedId,
            defaultVisible: contribution.defaultVisible,
          ),
          child: _ContributionColumnMenuItem(contribution: contribution),
        ),
      );
    }

    return entries;
  }

  void _toggleContributionColumn(String contributionId) {
    InventoryProductCatalogTableColumnContribution? matchingContribution;
    for (final contribution in contributions) {
      if (contribution.normalizedId == contributionId) {
        matchingContribution = contribution;
        break;
      }
    }
    if (matchingContribution == null) return;

    onChanged(
      preferences.toggleContributionColumn(
        contributionId,
        defaultVisible: matchingContribution.defaultVisible,
      ),
    );
  }
}

class _ContributionColumnSectionHeader extends StatelessWidget {
  const _ContributionColumnSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ContributionColumnMenuItem extends StatelessWidget {
  const _ContributionColumnMenuItem({required this.contribution});

  final InventoryProductCatalogTableColumnContribution contribution;

  @override
  Widget build(BuildContext context) {
    final tooltip = contribution.tooltip;
    if (tooltip == null) return Text(contribution.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(contribution.label),
        const SizedBox(height: 2),
        Text(
          tooltip,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
