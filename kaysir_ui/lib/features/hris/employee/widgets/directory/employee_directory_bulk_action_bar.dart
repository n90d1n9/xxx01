import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';

class EmployeeDirectoryBulkActionBar extends StatelessWidget {
  final int selectedCount;
  final int visibleCount;
  final VoidCallback onSelectVisible;
  final VoidCallback onClearSelection;
  final VoidCallback onExportSelected;
  final VoidCallback onRemoveSelected;
  final ValueChanged<EmployeeDirectoryStatus> onStatusChanged;

  const EmployeeDirectoryBulkActionBar({
    super.key,
    required this.selectedCount,
    required this.visibleCount,
    required this.onSelectVisible,
    required this.onClearSelection,
    required this.onExportSelected,
    required this.onRemoveSelected,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCount > 0;

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_circle_outlined,
      title: 'Bulk operations',
      subtitle:
          hasSelection
              ? '$selectedCount selected profiles ready for bulk actions'
              : 'Select visible rows or use the table checkboxes',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final actions = [
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-table-select-visible-button',
                ),
                onPressed: visibleCount == 0 ? null : onSelectVisible,
                icon: const Icon(Icons.select_all_outlined),
                label: Text('Select visible ($visibleCount)'),
              ),
              if (hasSelection)
                OutlinedButton.icon(
                  key: const ValueKey(
                    'employee-directory-table-export-selected-button',
                  ),
                  onPressed: onExportSelected,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Export CSV'),
                ),
              if (hasSelection)
                PopupMenuButton<EmployeeDirectoryStatus>(
                  key: const ValueKey(
                    'employee-directory-table-bulk-status-menu',
                  ),
                  tooltip: 'Update selected status',
                  onSelected: onStatusChanged,
                  itemBuilder:
                      (context) =>
                          EmployeeDirectoryStatus.values
                              .map(
                                (status) => PopupMenuItem(
                                  value: status,
                                  child: Text('Mark ${status.label}'),
                                ),
                              )
                              .toList(),
                  child: _BulkActionShell(
                    icon: Icons.published_with_changes_outlined,
                    label: 'Set status',
                    enabled: hasSelection,
                  ),
                ),
              if (hasSelection)
                OutlinedButton.icon(
                  key: const ValueKey(
                    'employee-directory-table-clear-selection-button',
                  ),
                  onPressed: onClearSelection,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Clear'),
                ),
              if (hasSelection)
                FilledButton.tonalIcon(
                  key: const ValueKey(
                    'employee-directory-table-remove-selected-button',
                  ),
                  onPressed: onRemoveSelected,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
            ];

            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    actions
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: action,
                          ),
                        )
                        .toList(),
              );
            }

            return Wrap(spacing: 10, runSpacing: 10, children: actions);
          },
        ),
      ],
    );
  }
}

class _BulkActionShell extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;

  const _BulkActionShell({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? HrisColors.primary : HrisColors.muted;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: HrisColors.border),
        borderRadius: BorderRadius.circular(8),
        color: HrisColors.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
