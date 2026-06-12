import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_owner_summary.dart';

class AccountingNavigationWorkQueueOwnerStrip extends StatelessWidget {
  const AccountingNavigationWorkQueueOwnerStrip({
    required this.summary,
    required this.selectedOwnerLabel,
    required this.onOwnerSelected,
    this.maxOwners = 3,
    super.key,
  });

  final AccountingWorkspaceWorkQueueOwnerSummary summary;
  final String? selectedOwnerLabel;
  final ValueChanged<String?> onOwnerSelected;
  final int maxOwners;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasOwners) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleOwners = summary.owners.take(maxOwners).toList();
    final hiddenOwnerCount = summary.ownerCount - visibleOwners.length;
    final selectedOwner = selectedOwnerLabel?.trim();
    final hasSelectedOwner = selectedOwner != null && selectedOwner.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.groups_rounded, color: colorScheme.primary, size: 17),
            const SizedBox(width: 7),
            Text(
              'Owner load',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              hasSelectedOwner
                  ? '$selectedOwner selected'
                  : _ownerCountLabel(summary.ownerCount),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (hasSelectedOwner) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('accounting-work-queue-owner-clear'),
                tooltip: 'Clear owner filter',
                visualDensity: VisualDensity.compact,
                iconSize: 17,
                onPressed: () => onOwnerSelected(null),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final owner in visibleOwners)
              _OwnerLoadCard(
                key: ValueKey(
                  'accounting-work-queue-owner-${owner.ownerLabel}',
                ),
                owner: owner,
                isSelected:
                    owner.ownerLabel.trim().toLowerCase() ==
                    selectedOwner?.toLowerCase(),
                onSelected: () {
                  final isSelected =
                      owner.ownerLabel.trim().toLowerCase() ==
                      selectedOwner?.toLowerCase();
                  onOwnerSelected(isSelected ? null : owner.ownerLabel);
                },
              ),
            if (hiddenOwnerCount > 0)
              _RemainingOwnersCard(hiddenOwnerCount: hiddenOwnerCount),
          ],
        ),
      ],
    );
  }
}

class _OwnerLoadCard extends StatelessWidget {
  const _OwnerLoadCard({
    super.key,
    required this.owner,
    required this.isSelected,
    required this.onSelected,
  });

  final AccountingWorkspaceWorkQueueOwnerLoad owner;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final contentColor = _ownerAccentColor(colorScheme, owner);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? contentColor.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? contentColor : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: contentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.person_rounded,
                      color: contentColor,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.ownerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _ownerPressureLabel(owner),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: contentColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _itemCountLabel(owner.totalItems),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemainingOwnersCard extends StatelessWidget {
  const _RemainingOwnersCard({required this.hiddenOwnerCount});

  final int hiddenOwnerCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Text(
          '+$hiddenOwnerCount more',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _ownerPressureLabel(AccountingWorkspaceWorkQueueOwnerLoad owner) {
  if (owner.hasOverdueItems) return '${owner.overdueItems} overdue';
  if (owner.hasDueTodayItems) return '${owner.dueTodayItems} due today';
  if (owner.hasCriticalItems) return '${owner.criticalItems} blocked';

  return '${owner.onTrackItems} on track';
}

String _itemCountLabel(int count) {
  return count == 1 ? '1 item' : '$count items';
}

String _ownerCountLabel(int count) {
  return count == 1 ? '1 owner' : '$count owners';
}

Color _ownerAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueOwnerLoad owner,
) {
  if (owner.hasOverdueItems) return colorScheme.error;
  if (owner.hasDueTodayItems) return colorScheme.secondary;
  if (owner.hasCriticalItems) return colorScheme.error;

  return colorScheme.tertiary;
}
