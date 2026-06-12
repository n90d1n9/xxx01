import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_sort.dart';

class AccountingNavigationWorkQueueSortSelector extends StatelessWidget {
  const AccountingNavigationWorkQueueSortSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AccountingWorkspaceWorkQueueSort value;
  final ValueChanged<AccountingWorkspaceWorkQueueSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.sort_rounded, color: colorScheme.primary, size: 17),
            const SizedBox(width: 7),
            Text(
              'Sort queues',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<AccountingWorkspaceWorkQueueSort>(
            key: const ValueKey('accounting-work-queue-sort-selector'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: AccountingWorkspaceWorkQueueSort.workflow,
                icon: Icon(Icons.account_tree_rounded),
                label: Text('Workflow'),
              ),
              ButtonSegment(
                value: AccountingWorkspaceWorkQueueSort.urgent,
                icon: Icon(Icons.priority_high_rounded),
                label: Text('Urgent'),
              ),
              ButtonSegment(
                value: AccountingWorkspaceWorkQueueSort.largest,
                icon: Icon(Icons.format_list_numbered_rounded),
                label: Text('Largest'),
              ),
              ButtonSegment(
                value: AccountingWorkspaceWorkQueueSort.owner,
                icon: Icon(Icons.person_search_rounded),
                label: Text('Owner'),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selection) => onChanged(selection.single),
          ),
        ),
      ],
    );
  }
}
