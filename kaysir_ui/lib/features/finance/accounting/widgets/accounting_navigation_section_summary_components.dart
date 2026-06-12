import 'package:flutter/material.dart';

import '../models/accounting_menu_catalog.dart';

class AccountingNavigationSectionSummaryPills extends StatelessWidget {
  const AccountingNavigationSectionSummaryPills({
    required this.section,
    super.key,
  });

  final AccountingMenuSection section;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SectionSummaryPill(
          key: ValueKey('accounting-section-summary-screens-${section.name}'),
          icon: Icons.web_asset_rounded,
          count: section.screenDestinations.length,
          label: 'Screen',
        ),
        _SectionSummaryPill(
          key: ValueKey('accounting-section-summary-shortcuts-${section.name}'),
          icon: Icons.shortcut_rounded,
          count: section.shortcutDestinations.length,
          label: 'Shortcut',
        ),
      ],
    );
  }
}

class _SectionSummaryPill extends StatelessWidget {
  const _SectionSummaryPill({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pluralized = '$label${count == 1 ? '' : 's'}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              '$count $pluralized',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
