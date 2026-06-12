import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';

class AccountingNavigationContextStrip extends StatelessWidget {
  const AccountingNavigationContextStrip({
    required this.rolePreset,
    required this.scope,
    required this.query,
    required this.resultCount,
    required this.onReset,
    super.key,
  });

  final AccountingWorkspaceRolePreset rolePreset;
  final AccountingMenuSearchScope scope;
  final String query;
  final int resultCount;
  final VoidCallback onReset;

  bool get _hasActiveContext {
    return query.trim().isNotEmpty ||
        scope != AccountingMenuSearchScope.all ||
        rolePreset != AccountingWorkspaceRolePreset.accountant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedQuery = query.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
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
                Icon(Icons.tune_rounded, color: colorScheme.primary, size: 19),
                const SizedBox(width: 8),
                Text(
                  'Active Context',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
            final resetButton = OutlinedButton.icon(
              key: const ValueKey('accounting-workspace-reset'),
              onPressed: _hasActiveContext ? onReset : null,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Reset'),
            );
            final pills = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextPill(
                  icon: getIconData(rolePreset.icon),
                  text: 'Role: ${rolePreset.label}',
                ),
                _ContextPill(
                  icon: _scopeIcon(scope),
                  text: 'Scope: ${scope.label}',
                ),
                _ContextPill(
                  icon: Icons.search_rounded,
                  text:
                      normalizedQuery.isEmpty
                          ? 'Search: None'
                          : 'Search: $normalizedQuery',
                ),
                _ContextPill(
                  icon: Icons.format_list_numbered_rounded,
                  text:
                      'Matches: $resultCount destination'
                      '${resultCount == 1 ? '' : 's'}',
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 8),
                      resetButton,
                    ],
                  ),
                  const SizedBox(height: 10),
                  pills,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(width: 16),
                Expanded(child: pills),
                const SizedBox(width: 12),
                resetButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

IconData _scopeIcon(AccountingMenuSearchScope scope) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return Icons.apps_rounded;
    case AccountingMenuSearchScope.screens:
      return Icons.web_asset_rounded;
    case AccountingMenuSearchScope.shortcuts:
      return Icons.shortcut_rounded;
  }
}

class _ContextPill extends StatelessWidget {
  const _ContextPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
