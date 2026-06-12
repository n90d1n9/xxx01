import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_saved_view_models.dart';

class EmployeeDirectorySavedViewsPanel extends StatefulWidget {
  final List<EmployeeDirectorySavedView> savedViews;
  final EmployeeDirectorySavedViewDraft draft;
  final EmployeeDirectorySavedView? activeView;
  final String allDepartmentsLabel;
  final int currentFilterCount;
  final int currentColumnCount;
  final String currentDensityLabel;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<bool> onPinnedChanged;
  final VoidCallback onSave;
  final VoidCallback onClearDraft;
  final ValueChanged<EmployeeDirectorySavedView> onApply;
  final ValueChanged<EmployeeDirectorySavedView> onDelete;

  const EmployeeDirectorySavedViewsPanel({
    super.key,
    required this.savedViews,
    required this.draft,
    required this.activeView,
    required this.allDepartmentsLabel,
    required this.currentFilterCount,
    required this.currentColumnCount,
    required this.currentDensityLabel,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onPinnedChanged,
    required this.onSave,
    required this.onClearDraft,
    required this.onApply,
    required this.onDelete,
  });

  @override
  State<EmployeeDirectorySavedViewsPanel> createState() =>
      _EmployeeDirectorySavedViewsPanelState();
}

class _EmployeeDirectorySavedViewsPanelState
    extends State<EmployeeDirectorySavedViewsPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _descriptionController = TextEditingController(
      text: widget.draft.description,
    );
  }

  @override
  void didUpdateWidget(EmployeeDirectorySavedViewsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_nameController, widget.draft.name);
    _syncController(_descriptionController, widget.draft.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-custom-saved-views-panel'),
      icon: Icons.bookmarks_outlined,
      title: 'Custom saved views',
      subtitle:
          widget.activeView == null
              ? '${widget.savedViews.length} custom views saved'
              : '${widget.activeView!.name} active',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Saved',
              value: '${widget.savedViews.length}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: widget.activeView == null ? 'None' : 'Custom',
            ),
            HrisMetricStripItem(
              label: 'Filters',
              value: '${widget.currentFilterCount}',
            ),
            HrisMetricStripItem(
              label: 'Layout',
              value:
                  '${widget.currentColumnCount} ${widget.currentDensityLabel.toLowerCase()}',
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 820;
            final fields = [
              TextField(
                key: const ValueKey('employee-directory-saved-view-name-field'),
                controller: _nameController,
                onChanged: widget.onNameChanged,
                decoration: const InputDecoration(
                  labelText: 'View name',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              TextField(
                key: const ValueKey(
                  'employee-directory-saved-view-description-field',
                ),
                controller: _descriptionController,
                onChanged: widget.onDescriptionChanged,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ];

            if (narrow) {
              return Column(
                children:
                    fields
                        .map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: field,
                          ),
                        )
                        .toList(),
              );
            }

            return Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
              ],
            );
          },
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: const ValueKey(
                  'employee-directory-saved-view-pinned-toggle',
                ),
                value: widget.draft.pinned,
                onChanged:
                    (value) =>
                        widget.onPinnedChanged(value ?? widget.draft.pinned),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pin saved view',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Priority cohorts stay above ad hoc views.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey('employee-directory-saved-view-save-button'),
              onPressed: widget.onSave,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save current view'),
            ),
            OutlinedButton.icon(
              key: const ValueKey('employee-directory-saved-view-clear-button'),
              onPressed: widget.draft.hasInput ? widget.onClearDraft : null,
              icon: const Icon(Icons.clear_all_outlined),
              label: const Text('Clear draft'),
            ),
          ],
        ),
        if (widget.savedViews.isEmpty)
          const HrisListSurface(child: Text('No custom views saved yet.'))
        else
          ...widget.savedViews.map(
            (view) => _SavedViewTile(
              key: ValueKey('employee-directory-saved-view-${view.id}'),
              view: view,
              active: widget.activeView?.id == view.id,
              allDepartmentsLabel: widget.allDepartmentsLabel,
              onApply: () => widget.onApply(view),
              onDelete: () => widget.onDelete(view),
            ),
          ),
      ],
    );
  }
}

class _SavedViewTile extends StatelessWidget {
  final EmployeeDirectorySavedView view;
  final bool active;
  final String allDepartmentsLabel;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  const _SavedViewTile({
    super.key,
    required this.view,
    required this.active,
    required this.allDepartmentsLabel,
    required this.onApply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final filterCount = view.filterCount(allDepartmentsLabel);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              view.pinned ? Icons.push_pin_outlined : Icons.bookmark_outline,
              color: HrisColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        view.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 8),
                      const HrisStatusPill(
                        label: 'Active',
                        color: HrisColors.primary,
                      ),
                    ],
                    if (view.pinned) ...[
                      const SizedBox(width: 8),
                      const HrisStatusPill(
                        label: 'Pinned',
                        color: Color(0xFFD97706),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  view.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _SavedViewFact(
                      icon: Icons.filter_alt_outlined,
                      label: '$filterCount filters',
                    ),
                    _SavedViewFact(
                      icon: Icons.view_column_outlined,
                      label: view.columnSummary,
                    ),
                    _SavedViewFact(
                      icon: Icons.sort_outlined,
                      label: view.sortSummary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  view.filterSummary(allDepartmentsLabel),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              IconButton(
                key: ValueKey('employee-directory-saved-view-apply-${view.id}'),
                tooltip: 'Apply saved view',
                onPressed: active ? null : onApply,
                icon: const Icon(Icons.playlist_add_check_outlined),
              ),
              IconButton(
                key: ValueKey(
                  'employee-directory-saved-view-delete-${view.id}',
                ),
                tooltip: 'Delete saved view',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedViewFact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SavedViewFact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: HrisColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
