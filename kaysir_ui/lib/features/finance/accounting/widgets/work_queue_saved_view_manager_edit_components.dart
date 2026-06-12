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
import '../models/work_queue_saved_view_recovery.dart';
import 'work_queue_saved_view_summary_chips.dart';

/// Inline action strip for saving draft saved-view name edits together.
class WorkQueueSavedViewManagerPendingChangesNotice extends StatelessWidget {
  const WorkQueueSavedViewManagerPendingChangesNotice({
    required this.pendingCount,
    required this.onSave,
    required this.onDiscard,
    super.key,
  });

  final int pendingCount;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final countLabel =
        pendingCount == 1
            ? '1 name edit pending'
            : '$pendingCount name edits pending';

    return DecoratedBox(
      key: const ValueKey(
        'accounting-work-queue-saved-view-manager-pending-changes',
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              color: colorScheme.onTertiaryContainer,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                countLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              key: const ValueKey(
                'accounting-work-queue-saved-view-manager-discard-pending',
              ),
              onPressed: onDiscard,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Discard'),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              key: const ValueKey(
                'accounting-work-queue-saved-view-manager-save-pending',
              ),
              onPressed: onSave,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact role section label for mixed-role saved-view manager lists.
class WorkQueueSavedViewManagerRoleGroupHeader extends StatelessWidget {
  const WorkQueueSavedViewManagerRoleGroupHeader({
    required this.rolePreset,
    required this.viewCount,
    super.key,
  });

  final AccountingWorkspaceRolePreset rolePreset;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final countLabel = viewCount == 1 ? '1 view' : '$viewCount views';

    return Row(
      key: ValueKey(
        'accounting-work-queue-saved-view-manager-role-group-'
        '${rolePreset.storageValue}',
      ),
      children: [
        Icon(
          getIconData(rolePreset.icon),
          color: colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            rolePreset.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              countLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact inline recovery notice after deleting a custom queue view.
class WorkQueueSavedViewManagerUndoDeleteNotice extends StatelessWidget {
  const WorkQueueSavedViewManagerUndoDeleteNotice({
    required this.view,
    required this.onUndo,
    super.key,
  });

  final AccountingWorkspaceWorkQueueSavedView view;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: const ValueKey(
        'accounting-work-queue-saved-view-manager-delete-undo-notice',
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.restore_rounded,
              color: colorScheme.onSecondaryContainer,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${view.label} deleted',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey(
                'accounting-work-queue-saved-view-manager-delete-undo',
              ),
              onPressed: onUndo,
              child: const Text('Undo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Editable list row for a custom accounting queue view.
class WorkQueueSavedViewManagerRow extends StatelessWidget {
  const WorkQueueSavedViewManagerRow({
    required this.view,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.onRenamed,
    required this.onDeleted,
    super.key,
  });

  final AccountingWorkspaceWorkQueueSavedView view;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onRenamed;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Icon(getIconData(view.icon), color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: ValueKey(
                  'accounting-work-queue-saved-view-manager-label-${view.id}',
                ),
                controller: controller,
                maxLength: workQueueSavedViewLabelLimit,
                decoration: InputDecoration(
                  labelText: 'View name',
                  counterText: '',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: onChanged,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onRenamed(),
              ),
              const SizedBox(height: 8),
              WorkQueueSavedViewSummaryChips(view: view),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: ValueKey(
            'accounting-work-queue-saved-view-manager-save-${view.id}',
          ),
          tooltip: 'Rename queue view',
          onPressed: onRenamed,
          icon: const Icon(Icons.check_rounded),
        ),
        IconButton(
          key: ValueKey(
            'accounting-work-queue-saved-view-manager-delete-${view.id}',
          ),
          tooltip: 'Delete queue view',
          onPressed: onDeleted,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

/// Empty state for the custom accounting queue view manager.
class WorkQueueSavedViewManagerEmptyState extends StatelessWidget {
  const WorkQueueSavedViewManagerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 360,
      child: Row(
        children: [
          Icon(Icons.bookmark_border_rounded, color: colorScheme.outline),
          const SizedBox(width: 8),
          const Expanded(child: Text('No custom queue views saved.')),
        ],
      ),
    );
  }
}

@Preview(name: 'Work queue saved view manager edit components')
Widget workQueueSavedViewManagerEditComponentsPreview() {
  final view = _controllerBlockedSavedView();
  final controller = TextEditingController(text: view.label);

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WorkQueueSavedViewManagerPendingChangesNotice(
              pendingCount: 2,
              onSave: () {},
              onDiscard: () {},
            ),
            const SizedBox(height: 12),
            const WorkQueueSavedViewManagerRoleGroupHeader(
              rolePreset: AccountingWorkspaceRolePreset.controller,
              viewCount: 2,
            ),
            const SizedBox(height: 12),
            WorkQueueSavedViewManagerRow(
              view: view,
              controller: controller,
              errorText: null,
              onChanged: (_) {},
              onRenamed: () {},
              onDeleted: () {},
            ),
            const SizedBox(height: 12),
            WorkQueueSavedViewManagerUndoDeleteNotice(
              view: view,
              onUndo: () {},
            ),
            const SizedBox(height: 12),
            const WorkQueueSavedViewManagerEmptyState(),
          ],
        ),
      ),
    ),
  );
}

AccountingWorkspaceWorkQueueSavedView _controllerBlockedSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.blocked,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: null,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: null,
    selectedQueueTitle: null,
    detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
  ).copyWith(label: 'Month-end blockers');
}
