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
import 'work_queue_saved_view_context_components.dart';

/// Compact saved-view launcher for accounting work queue operating presets.
class AccountingNavigationWorkQueueSavedViews extends StatelessWidget {
  const AccountingNavigationWorkQueueSavedViews({
    required this.views,
    required this.query,
    required this.scope,
    required this.rolePreset,
    required this.focus,
    required this.sort,
    required this.ownerFilter,
    required this.resolutionFilter,
    required this.selectedQueueId,
    required this.detailSection,
    required this.onSelected,
    this.selectedQueueLabel,
    this.onFocusCleared,
    this.onSortCleared,
    this.onOwnerFilterCleared,
    this.onResolutionFilterCleared,
    this.onQueueSelectionCleared,
    this.onDetailSectionCleared,
    this.onContextReset,
    this.onSaveCurrent,
    this.onManageViews,
    this.hasManagedViewHistory = false,
    this.onDeleted,
    super.key,
  });

  final List<AccountingWorkspaceWorkQueueSavedView> views;
  final String query;
  final AccountingMenuSearchScope scope;
  final AccountingWorkspaceRolePreset rolePreset;
  final AccountingWorkspaceWorkQueueFocus focus;
  final AccountingWorkspaceWorkQueueSort sort;
  final String? ownerFilter;
  final AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter;
  final String? selectedQueueId;
  final String? selectedQueueLabel;
  final AccountingWorkspaceWorkQueueDetailSection detailSection;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onSelected;
  final VoidCallback? onFocusCleared;
  final VoidCallback? onSortCleared;
  final VoidCallback? onOwnerFilterCleared;
  final VoidCallback? onResolutionFilterCleared;
  final VoidCallback? onQueueSelectionCleared;
  final VoidCallback? onDetailSectionCleared;
  final VoidCallback? onContextReset;
  final VoidCallback? onSaveCurrent;
  final VoidCallback? onManageViews;
  final bool hasManagedViewHistory;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView>? onDeleted;

  @override
  Widget build(BuildContext context) {
    if (views.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCustomViews = views.any((view) => view.isCustom);
    final canManageViews =
        onManageViews != null && (hasCustomViews || hasManagedViewHistory);
    final savedCurrentView = _matchingCustomSavedView(
      views: views,
      query: query,
      scope: scope,
      rolePreset: rolePreset,
      focus: focus,
      sort: sort,
      ownerFilter: ownerFilter,
      resolutionFilter: resolutionFilter,
      selectedQueueId: selectedQueueId,
      detailSection: detailSection,
    );
    final hasSavedCurrentView = savedCurrentView != null;
    final hasActiveContext = _hasActiveContext(
      query: query,
      focus: focus,
      sort: sort,
      ownerFilter: ownerFilter,
      resolutionFilter: resolutionFilter,
      selectedQueueId: selectedQueueId,
      detailSection: detailSection,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_added_rounded,
              color: colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              'Queue Views',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (hasActiveContext && onContextReset != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('accounting-work-queue-reset-view'),
                tooltip: 'Reset queue view',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                onPressed: onContextReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
              ),
            ],
            if (onSaveCurrent != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('accounting-work-queue-save-current-view'),
                tooltip:
                    hasSavedCurrentView
                        ? 'Update saved queue view'
                        : 'Save current queue view',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                onPressed: onSaveCurrent,
                icon: Icon(
                  hasSavedCurrentView
                      ? Icons.bookmark_added_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 18,
                ),
              ),
            ],
            if (canManageViews) ...[
              const SizedBox(width: 2),
              IconButton(
                key: const ValueKey(
                  'accounting-work-queue-manage-custom-views',
                ),
                tooltip: 'Manage custom queue views',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                onPressed: onManageViews,
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
            ],
          ],
        ),
        if (hasActiveContext) ...[
          const SizedBox(height: 6),
          WorkQueueSavedViewContext(
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
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final view in views)
              _WorkQueueSavedViewChip(
                view: view,
                selected: view.isSelected(
                  query: query,
                  scope: scope,
                  rolePreset: rolePreset,
                  focus: focus,
                  sort: sort,
                  ownerFilter: ownerFilter,
                  resolutionFilter: resolutionFilter,
                  selectedQueueId: selectedQueueId,
                  detailSection: detailSection,
                ),
                onSelected: onSelected,
                onDeleted: onDeleted,
              ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Work queue saved views')
Widget workQueueSavedViewsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueSavedViews(
          views: accountingWorkspaceWorkQueueSavedViewsForRole(
            AccountingWorkspaceRolePreset.controller,
          ),
          query: '',
          scope: AccountingMenuSearchScope.all,
          rolePreset: AccountingWorkspaceRolePreset.controller,
          focus: AccountingWorkspaceWorkQueueFocus.blocked,
          sort: AccountingWorkspaceWorkQueueSort.urgent,
          ownerFilter: 'Report approver',
          resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
          selectedQueueId: 'controller-release-approvals',
          selectedQueueLabel: 'Release approvals',
          detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
          onSelected: (_) {},
          onContextReset: () {},
          onSaveCurrent: () {},
          onManageViews: () {},
        ),
      ),
    ),
  );
}

AccountingWorkspaceWorkQueueSavedView? _matchingCustomSavedView({
  required List<AccountingWorkspaceWorkQueueSavedView> views,
  required String query,
  required AccountingMenuSearchScope scope,
  required AccountingWorkspaceRolePreset rolePreset,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  required String? selectedQueueId,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
}) {
  for (final view in views) {
    if (!view.isCustom) continue;
    if (view.isSelected(
      query: query,
      scope: scope,
      rolePreset: rolePreset,
      focus: focus,
      sort: sort,
      ownerFilter: ownerFilter,
      resolutionFilter: resolutionFilter,
      selectedQueueId: selectedQueueId,
      detailSection: detailSection,
    )) {
      return view;
    }
  }

  return null;
}

bool _hasActiveContext({
  required String query,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  required String? selectedQueueId,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
}) {
  return query.trim().isNotEmpty ||
      focus != AccountingWorkspaceWorkQueueFocus.all ||
      sort != AccountingWorkspaceWorkQueueSort.workflow ||
      (ownerFilter?.trim().isNotEmpty ?? false) ||
      !resolutionFilter.isDefault ||
      (selectedQueueId?.trim().isNotEmpty ?? false) ||
      detailSection != AccountingWorkspaceWorkQueueDetailSection.overview;
}

/// Selectable chip for a single accounting work queue saved view.
class _WorkQueueSavedViewChip extends StatelessWidget {
  const _WorkQueueSavedViewChip({
    required this.view,
    required this.selected,
    required this.onSelected,
    required this.onDeleted,
  });

  final AccountingWorkspaceWorkQueueSavedView view;
  final bool selected;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onSelected;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView>? onDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor =
        selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;

    final label = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              view.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: contentColor,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          if (view.isCustom) ...[
            const SizedBox(width: 6),
            _CustomSavedViewMarker(selected: selected),
          ],
        ],
      ),
    );
    final avatar = Icon(getIconData(view.icon), size: 17, color: contentColor);
    final chipKey = ValueKey('accounting-work-queue-saved-view-${view.id}');

    if (view.isCustom && onDeleted != null) {
      return InputChip(
        key: chipKey,
        selected: selected,
        showCheckmark: false,
        avatar: avatar,
        label: label,
        tooltip: view.description,
        selectedColor: colorScheme.primaryContainer,
        deleteButtonTooltipMessage: 'Delete ${view.label}',
        deleteIcon: Icon(Icons.close_rounded, size: 16, color: contentColor),
        onDeleted: () => onDeleted!(view),
        onSelected: (_) => onSelected(view),
      );
    }

    return ChoiceChip(
      key: chipKey,
      selected: selected,
      showCheckmark: false,
      avatar: avatar,
      label: label,
      tooltip: view.description,
      selectedColor: colorScheme.primaryContainer,
      onSelected: (_) => onSelected(view),
    );
  }
}

/// Small visual marker for user-defined accounting queue views.
class _CustomSavedViewMarker extends StatelessWidget {
  const _CustomSavedViewMarker({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        selected ? colorScheme.onPrimaryContainer : colorScheme.primary;
    final background =
        selected
            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.12)
            : colorScheme.primary.withValues(alpha: 0.1);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-saved-view-custom-marker'),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          'Custom',
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
