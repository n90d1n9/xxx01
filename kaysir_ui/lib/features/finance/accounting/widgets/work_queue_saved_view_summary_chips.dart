import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_saved_view.dart';

/// Compact context chips for the state restored by a custom queue view.
class WorkQueueSavedViewSummaryChips extends StatelessWidget {
  const WorkQueueSavedViewSummaryChips({
    required this.view,
    this.keyPrefix = 'accounting-work-queue-saved-view-manager-summary',
    super.key,
  });

  final AccountingWorkspaceWorkQueueSavedView view;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final chips = <_WorkQueueSavedViewSummaryChipData>[
      _WorkQueueSavedViewSummaryChipData(
        keySuffix: 'role',
        label: view.rolePreset.label,
        icon: getIconData(view.rolePreset.icon),
      ),
      if (view.query.trim().isNotEmpty)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'search',
          label: '${view.scope.label}: ${view.query.trim()}',
          icon: Icons.search_rounded,
        )
      else if (view.scope != AccountingMenuSearchScope.all)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'scope',
          label: view.scope.label,
          icon: Icons.filter_alt_rounded,
        ),
      _WorkQueueSavedViewSummaryChipData(
        keySuffix: 'focus',
        label: _focusLabel(view.focus),
        icon: Icons.center_focus_strong_rounded,
      ),
      _WorkQueueSavedViewSummaryChipData(
        keySuffix: 'sort',
        label: view.sort.label,
        icon: Icons.sort_rounded,
      ),
      if (view.ownerFilter?.trim() case final owner? when owner.isNotEmpty)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'owner',
          label: owner,
          icon: Icons.person_outline_rounded,
        ),
      if (!view.resolutionFilter.isDefault)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'resolution',
          label: view.resolutionFilter.label,
          icon: Icons.task_alt_rounded,
        ),
      if (view.selectedQueueId?.trim() case final queueId?
          when queueId.isNotEmpty)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'work',
          label: 'Work item',
          icon: Icons.assignment_late_rounded,
        ),
      if (view.detailSection !=
          AccountingWorkspaceWorkQueueDetailSection.overview)
        _WorkQueueSavedViewSummaryChipData(
          keySuffix: 'detail',
          label: _detailLabel(view.detailSection),
          icon: Icons.tab_rounded,
        ),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final chip in chips)
          _WorkQueueSavedViewSummaryChip(
            key: ValueKey('$keyPrefix-${view.id}-${chip.keySuffix}'),
            data: chip,
          ),
      ],
    );
  }
}

@Preview(name: 'Work queue saved view summary chips')
Widget workQueueSavedViewSummaryChipsPreview() {
  final view = AccountingWorkspaceWorkQueueSavedView.custom(
    query: 'approval',
    scope: AccountingMenuSearchScope.shortcuts,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.review,
    sort: AccountingWorkspaceWorkQueueSort.urgent,
    ownerFilter: 'Report approver',
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
    selectedQueueId: 'controller-release-approvals',
    selectedQueueTitle: 'Release approvals',
    detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: WorkQueueSavedViewSummaryChips(view: view),
      ),
    ),
  );
}

/// Data needed to render a saved-view summary chip.
class _WorkQueueSavedViewSummaryChipData {
  const _WorkQueueSavedViewSummaryChipData({
    required this.keySuffix,
    required this.label,
    required this.icon,
  });

  final String keySuffix;
  final String label;
  final IconData icon;
}

/// Small metadata chip for a custom saved queue view.
class _WorkQueueSavedViewSummaryChip extends StatelessWidget {
  const _WorkQueueSavedViewSummaryChip({required this.data, super.key});

  final _WorkQueueSavedViewSummaryChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              data.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _focusLabel(AccountingWorkspaceWorkQueueFocus focus) {
  switch (focus) {
    case AccountingWorkspaceWorkQueueFocus.all:
      return 'All queues';
    case AccountingWorkspaceWorkQueueFocus.blocked:
      return 'Blocked';
    case AccountingWorkspaceWorkQueueFocus.review:
      return 'Review';
    case AccountingWorkspaceWorkQueueFocus.monitor:
      return 'Monitor';
  }
}

String _detailLabel(AccountingWorkspaceWorkQueueDetailSection section) {
  switch (section) {
    case AccountingWorkspaceWorkQueueDetailSection.overview:
      return 'Overview';
    case AccountingWorkspaceWorkQueueDetailSection.controls:
      return 'Controls';
    case AccountingWorkspaceWorkQueueDetailSection.request:
      return 'Request';
    case AccountingWorkspaceWorkQueueDetailSection.activity:
      return 'Activity';
  }
}
