import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_bulk_profile_update_models.dart';

class EmployeeDirectoryBulkProfileUpdatePanel extends StatefulWidget {
  final int selectedCount;
  final EmployeeDirectoryBulkProfileUpdateDraft draft;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onAuditNoteChanged;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryBulkProfileUpdatePanel({
    super.key,
    required this.selectedCount,
    required this.draft,
    required this.onManagerChanged,
    required this.onDepartmentChanged,
    required this.onLocationChanged,
    required this.onAuditNoteChanged,
    required this.canSubmit,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryBulkProfileUpdatePanel> createState() =>
      _EmployeeDirectoryBulkProfileUpdatePanelState();
}

class _EmployeeDirectoryBulkProfileUpdatePanelState
    extends State<EmployeeDirectoryBulkProfileUpdatePanel> {
  late final TextEditingController _managerController;
  late final TextEditingController _departmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _auditNoteController;

  @override
  void initState() {
    super.initState();
    _managerController = TextEditingController(text: widget.draft.manager);
    _departmentController = TextEditingController(
      text: widget.draft.department,
    );
    _locationController = TextEditingController(text: widget.draft.location);
    _auditNoteController = TextEditingController(text: widget.draft.auditNote);
  }

  @override
  void didUpdateWidget(EmployeeDirectoryBulkProfileUpdatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_managerController, widget.draft.manager);
    _syncController(_departmentController, widget.draft.department);
    _syncController(_locationController, widget.draft.location);
    _syncController(_auditNoteController, widget.draft.auditNote);
  }

  @override
  void dispose() {
    _managerController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _auditNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.draft.validationErrors(widget.selectedCount);
    final showErrors =
        errors.isNotEmpty &&
        (widget.selectedCount > 0 || widget.draft.hasInput);

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-bulk-profile-update-panel'),
      icon: Icons.manage_accounts_outlined,
      title: 'Bulk profile update',
      subtitle:
          widget.selectedCount == 0
              ? 'Select employees to update manager, department, or location'
              : '${widget.selectedCount} selected profiles ready for governed updates',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Selected',
              value: '${widget.selectedCount}',
            ),
            HrisMetricStripItem(
              label: 'Fields',
              value: '${widget.draft.targetFieldCount}',
            ),
            HrisMetricStripItem(
              label: 'Audit',
              value: widget.draft.auditNote.trim().isEmpty ? 'Missing' : 'Set',
            ),
            HrisMetricStripItem(
              label: 'Ready',
              value: widget.draft.isReady(widget.selectedCount) ? 'Yes' : 'No',
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 820;
            final fieldRows = [
              _BulkUpdateTextField(
                key: const ValueKey(
                  'employee-directory-bulk-profile-manager-field',
                ),
                controller: _managerController,
                label: 'New manager',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onManagerChanged,
              ),
              _BulkUpdateTextField(
                key: const ValueKey(
                  'employee-directory-bulk-profile-department-field',
                ),
                controller: _departmentController,
                label: 'New department',
                icon: Icons.account_tree_outlined,
                onChanged: widget.onDepartmentChanged,
              ),
              _BulkUpdateTextField(
                key: const ValueKey(
                  'employee-directory-bulk-profile-location-field',
                ),
                controller: _locationController,
                label: 'New location',
                icon: Icons.location_city_outlined,
                onChanged: widget.onLocationChanged,
              ),
            ];

            if (narrow) {
              return Column(
                children:
                    fieldRows
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
                for (var index = 0; index < fieldRows.length; index++) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(child: fieldRows[index]),
                ],
              ],
            );
          },
        ),
        TextField(
          key: const ValueKey('employee-directory-bulk-profile-note-field'),
          controller: _auditNoteController,
          minLines: 2,
          maxLines: 3,
          onChanged: widget.onAuditNoteChanged,
          decoration: const InputDecoration(
            labelText: 'Audit note',
            prefixIcon: Icon(Icons.notes_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (showErrors)
          HrisListSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  errors
                      .map(
                        (error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            error,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey(
                'employee-directory-bulk-profile-submit-button',
              ),
              onPressed: widget.canSubmit ? widget.onSubmit : null,
              icon: const Icon(Icons.done_all_outlined),
              label: const Text('Apply updates'),
            ),
            OutlinedButton.icon(
              key: const ValueKey(
                'employee-directory-bulk-profile-clear-button',
              ),
              onPressed: widget.draft.hasInput ? widget.onClear : null,
              icon: const Icon(Icons.clear_all_outlined),
              label: const Text('Clear form'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BulkUpdateTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _BulkUpdateTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
