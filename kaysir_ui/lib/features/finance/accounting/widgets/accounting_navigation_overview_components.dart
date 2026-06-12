import 'package:flutter/material.dart';

import '../models/accounting_workspace_overview.dart';

class AccountingNavigationOverviewStrip extends StatelessWidget {
  const AccountingNavigationOverviewStrip({required this.overview, super.key});

  final AccountingWorkspaceOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Workspace Overview',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
            final metrics = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OverviewMetric(
                  key: const ValueKey('accounting-overview-saved-views'),
                  icon: Icons.bookmarks_rounded,
                  value: overview.savedViewCount,
                  label: 'Saved views',
                ),
                _OverviewMetric(
                  key: const ValueKey('accounting-overview-priority-actions'),
                  icon: Icons.bolt_rounded,
                  value: overview.priorityActionCount,
                  label: 'Priority actions',
                ),
                _OverviewMetric(
                  key: const ValueKey('accounting-overview-screens'),
                  icon: Icons.web_asset_rounded,
                  value: overview.screenCount,
                  label: 'Screens',
                ),
                _OverviewMetric(
                  key: const ValueKey('accounting-overview-shortcuts'),
                  icon: Icons.shortcut_rounded,
                  value: overview.shortcutCount,
                  label: 'Shortcuts',
                ),
                _OverviewMetric(
                  key: const ValueKey('accounting-overview-sections'),
                  icon: Icons.account_tree_rounded,
                  value: overview.sectionCount,
                  label: 'Sections',
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), metrics],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(width: 16),
                Expanded(child: metrics),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
