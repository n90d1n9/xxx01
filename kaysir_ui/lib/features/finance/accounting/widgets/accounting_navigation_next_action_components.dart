import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_workspace_next_action.dart';

class AccountingNavigationNextActions extends StatelessWidget {
  const AccountingNavigationNextActions({
    required this.actions,
    required this.onSelected,
    super.key,
  });

  final List<AccountingWorkspaceNextAction> actions;
  final ValueChanged<AccountingWorkspaceNextAction> onSelected;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 19),
                const SizedBox(width: 8),
                Text(
                  'Priority Actions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (actions.isEmpty)
              _NextActionsEmptyState()
            else
              Column(
                children: [
                  for (final action in actions) ...[
                    _NextActionRow(action: action, onSelected: onSelected),
                    if (action != actions.last)
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NextActionRow extends StatelessWidget {
  const _NextActionRow({required this.action, required this.onSelected});

  final AccountingWorkspaceNextAction action;
  final ValueChanged<AccountingWorkspaceNextAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      key: ValueKey('accounting-next-action-${action.id}'),
      onTap: () => onSelected(action),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  getIconData(action.icon),
                  color: colorScheme.onPrimaryContainer,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextActionsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.manage_search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No priority actions match this context.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
