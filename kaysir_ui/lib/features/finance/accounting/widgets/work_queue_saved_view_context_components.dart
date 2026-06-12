import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/work_queue_resolution_filter.dart';

/// Compact breadcrumb row for the active accounting work queue view context.
class WorkQueueSavedViewContext extends StatelessWidget {
  const WorkQueueSavedViewContext({
    required this.query,
    required this.scope,
    required this.focus,
    required this.sort,
    required this.ownerFilter,
    required this.resolutionFilter,
    required this.selectedQueueId,
    required this.detailSection,
    this.selectedQueueLabel,
    this.onFocusCleared,
    this.onSortCleared,
    this.onOwnerFilterCleared,
    this.onResolutionFilterCleared,
    this.onQueueSelectionCleared,
    this.onDetailSectionCleared,
    super.key,
  });

  final String query;
  final AccountingMenuSearchScope scope;
  final AccountingWorkspaceWorkQueueFocus focus;
  final AccountingWorkspaceWorkQueueSort sort;
  final String? ownerFilter;
  final AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter;
  final String? selectedQueueId;
  final String? selectedQueueLabel;
  final AccountingWorkspaceWorkQueueDetailSection detailSection;
  final VoidCallback? onFocusCleared;
  final VoidCallback? onSortCleared;
  final VoidCallback? onOwnerFilterCleared;
  final VoidCallback? onResolutionFilterCleared;
  final VoidCallback? onQueueSelectionCleared;
  final VoidCallback? onDetailSectionCleared;

  @override
  Widget build(BuildContext context) {
    final chips = _currentViewContextChips(
      query: query,
      scope: scope,
      focus: focus,
      sort: sort,
      ownerFilter: ownerFilter,
      resolutionFilter: resolutionFilter,
      selectedQueueId: selectedQueueId,
      selectedQueueLabel: selectedQueueLabel,
      detailSection: detailSection,
      onFocusCleared: onFocusCleared,
      onSortCleared: onSortCleared,
      onOwnerFilterCleared: onOwnerFilterCleared,
      onResolutionFilterCleared: onResolutionFilterCleared,
      onQueueSelectionCleared: onQueueSelectionCleared,
      onDetailSectionCleared: onDetailSectionCleared,
    );
    if (chips.isEmpty) return const SizedBox.shrink();

    final visibleChips = chips.take(4).toList(growable: false);
    final hiddenChips = chips.skip(4).toList(growable: false);

    return Wrap(
      key: const ValueKey('accounting-work-queue-current-view-context'),
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final chip in visibleChips) _CurrentQueueViewChip(data: chip),
        if (hiddenChips.isNotEmpty)
          _CurrentQueueViewOverflowChip(chips: hiddenChips),
      ],
    );
  }
}

@Preview(name: 'Work queue saved view context')
Widget workQueueSavedViewContextPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: WorkQueueSavedViewContext(
          query: '',
          scope: AccountingMenuSearchScope.all,
          focus: AccountingWorkspaceWorkQueueFocus.blocked,
          sort: AccountingWorkspaceWorkQueueSort.urgent,
          ownerFilter: 'Report approver',
          resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
          selectedQueueId: 'controller-release-approvals',
          selectedQueueLabel: 'Release approvals',
          detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
        ),
      ),
    ),
  );
}

List<_CurrentQueueViewChipData> _currentViewContextChips({
  required String query,
  required AccountingMenuSearchScope scope,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  required String? selectedQueueId,
  required String? selectedQueueLabel,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
  required VoidCallback? onFocusCleared,
  required VoidCallback? onSortCleared,
  required VoidCallback? onOwnerFilterCleared,
  required VoidCallback? onResolutionFilterCleared,
  required VoidCallback? onQueueSelectionCleared,
  required VoidCallback? onDetailSectionCleared,
}) {
  final trimmedQuery = query.trim();
  final trimmedOwner = ownerFilter?.trim();
  final trimmedQueueId = selectedQueueId?.trim();
  final trimmedQueueLabel = selectedQueueLabel?.trim();

  return [
    if (trimmedQuery.isNotEmpty)
      _CurrentQueueViewChipData(
        id: 'query',
        icon: Icons.search_rounded,
        label: '${scope.label}: $trimmedQuery',
      ),
    if (focus != AccountingWorkspaceWorkQueueFocus.all)
      _CurrentQueueViewChipData(
        id: 'focus',
        icon: Icons.filter_alt_rounded,
        label: _focusLabel(focus),
        clearTooltip: 'Clear focus filter',
        onClear: onFocusCleared,
      ),
    if (sort != AccountingWorkspaceWorkQueueSort.workflow)
      _CurrentQueueViewChipData(
        id: 'sort',
        icon: Icons.sort_rounded,
        label: 'Sort: ${sort.label}',
        clearTooltip: 'Reset sort',
        onClear: onSortCleared,
      ),
    if (trimmedOwner != null && trimmedOwner.isNotEmpty)
      _CurrentQueueViewChipData(
        id: 'owner',
        icon: Icons.person_search_rounded,
        label: 'Owner: $trimmedOwner',
        clearTooltip: 'Clear owner filter',
        onClear: onOwnerFilterCleared,
      ),
    if (!resolutionFilter.isDefault)
      _CurrentQueueViewChipData(
        id: 'resolution',
        icon: Icons.task_alt_rounded,
        label: 'Resolution: ${resolutionFilter.label}',
        clearTooltip: 'Clear resolution filter',
        onClear: onResolutionFilterCleared,
      ),
    if (trimmedQueueId != null && trimmedQueueId.isNotEmpty)
      _CurrentQueueViewChipData(
        id: 'queue',
        icon: Icons.push_pin_rounded,
        label:
            trimmedQueueLabel != null && trimmedQueueLabel.isNotEmpty
                ? 'Queue: $trimmedQueueLabel'
                : 'Queue pinned',
        clearTooltip: 'Clear pinned queue',
        onClear: onQueueSelectionCleared,
      ),
    if (detailSection != AccountingWorkspaceWorkQueueDetailSection.overview)
      _CurrentQueueViewChipData(
        id: 'detail',
        icon: Icons.tab_rounded,
        label: 'Tab: ${_detailSectionLabel(detailSection)}',
        clearTooltip: 'Return to overview tab',
        onClear: onDetailSectionCleared,
      ),
  ];
}

String _focusLabel(AccountingWorkspaceWorkQueueFocus focus) {
  switch (focus) {
    case AccountingWorkspaceWorkQueueFocus.all:
      return 'All queues';
    case AccountingWorkspaceWorkQueueFocus.blocked:
      return 'Blocked queues';
    case AccountingWorkspaceWorkQueueFocus.review:
      return 'Review queues';
    case AccountingWorkspaceWorkQueueFocus.monitor:
      return 'Monitor queues';
  }
}

String _detailSectionLabel(AccountingWorkspaceWorkQueueDetailSection section) {
  switch (section) {
    case AccountingWorkspaceWorkQueueDetailSection.overview:
      return 'Overview';
    case AccountingWorkspaceWorkQueueDetailSection.controls:
      return 'Controls';
    case AccountingWorkspaceWorkQueueDetailSection.request:
      return 'Evidence';
    case AccountingWorkspaceWorkQueueDetailSection.activity:
      return 'Activity';
  }
}

/// Presentation data for one active work queue context chip.
class _CurrentQueueViewChipData {
  const _CurrentQueueViewChipData({
    required this.id,
    required this.icon,
    required this.label,
    this.clearTooltip,
    this.onClear,
  });

  final String id;
  final IconData icon;
  final String label;
  final String? clearTooltip;
  final VoidCallback? onClear;
}

/// Small chip for one active queue filter or pinned detail.
class _CurrentQueueViewChip extends StatelessWidget {
  const _CurrentQueueViewChip({required this.data});

  final _CurrentQueueViewChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: data.label,
      button: data.onClear != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 13, color: colorScheme.secondary),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 164),
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (data.onClear != null) ...[
                const SizedBox(width: 2),
                Tooltip(
                  message: data.clearTooltip ?? 'Clear filter',
                  child: InkWell(
                    key: ValueKey(
                      'accounting-work-queue-current-view-clear-${data.id}',
                    ),
                    borderRadius: BorderRadius.circular(999),
                    onTap: data.onClear,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: colorScheme.onSecondaryContainer.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Overflow chip for additional active context that should stay visually quiet.
class _CurrentQueueViewOverflowChip extends StatelessWidget {
  const _CurrentQueueViewOverflowChip({required this.chips});

  final List<_CurrentQueueViewChipData> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hiddenCount = chips.length;

    return PopupMenuButton<_CurrentQueueViewChipData>(
      key: const ValueKey('accounting-work-queue-current-view-overflow'),
      tooltip: 'Show hidden queue context',
      position: PopupMenuPosition.under,
      onSelected: (chip) => chip.onClear?.call(),
      itemBuilder:
          (context) => [
            for (final chip in chips)
              PopupMenuItem<_CurrentQueueViewChipData>(
                value: chip,
                enabled: chip.onClear != null,
                child: _CurrentQueueViewOverflowMenuItem(data: chip),
              ),
          ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '+$hiddenCount more',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu row for a hidden work queue context chip.
class _CurrentQueueViewOverflowMenuItem extends StatelessWidget {
  const _CurrentQueueViewOverflowMenuItem({required this.data});

  final _CurrentQueueViewChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = data.onClear != null;
    final contentColor =
        enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(data.icon, color: contentColor, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (enabled) ...[
          const SizedBox(width: 12),
          Icon(Icons.close_rounded, color: colorScheme.primary, size: 15),
        ],
      ],
    );
  }
}
