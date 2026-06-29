import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_vault_models.dart';

class EmployeeDocumentVaultForm extends StatelessWidget {
  final EmployeeDocumentVaultDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController summaryController;
  final ValueChanged<EmployeeDocumentVaultCategory> onCategoryChanged;
  final ValueChanged<EmployeeDocumentVaultAccess> onAccessChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onSummaryChanged;
  final VoidCallback onSelectExpiryDate;
  final VoidCallback onClearExpiryDate;
  final VoidCallback onSubmit;

  const EmployeeDocumentVaultForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.summaryController,
    required this.onCategoryChanged,
    required this.onAccessChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onSummaryChanged,
    required this.onSelectExpiryDate,
    required this.onClearExpiryDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResponsiveFieldPair(
            first: DropdownButtonFormField<EmployeeDocumentVaultCategory>(
              initialValue: draft.category,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder_copy_outlined),
              ),
              items:
                  EmployeeDocumentVaultCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onCategoryChanged(value);
              },
            ),
            second: DropdownButtonFormField<EmployeeDocumentVaultAccess>(
              initialValue: draft.access,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Access',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              items:
                  EmployeeDocumentVaultAccess.values
                      .map(
                        (access) => DropdownMenuItem(
                          value: access,
                          child: Text(
                            access.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onAccessChanged(value);
              },
            ),
          ),
          const SizedBox(height: 12),
          _DocumentVaultTextField(
            controller: titleController,
            label: 'Document title',
            icon: Icons.description_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _ResponsiveFieldPair(
            first: _DocumentVaultTextField(
              controller: ownerController,
              label: 'Owner',
              icon: Icons.person_outline,
              onChanged: onOwnerChanged,
            ),
            second: _DocumentVaultDateField(
              label: 'Expiry',
              date: draft.expiresAt,
              onTap: onSelectExpiryDate,
              onClear: draft.expiresAt == null ? null : onClearExpiryDate,
            ),
          ),
          const SizedBox(height: 12),
          _DocumentVaultTextField(
            controller: summaryController,
            label: 'Summary',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onSummaryChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToAdd ? onSubmit : null,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Add to vault'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsiveFieldPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(children: [first, const SizedBox(height: 12), second]);
        }

        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _DocumentVaultDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DocumentVaultDateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon:
              onClear == null
                  ? null
                  : IconButton(
                    tooltip: 'Clear expiry',
                    icon: const Icon(Icons.close_outlined),
                    onPressed: onClear,
                  ),
        ),
        child: Text(
          date == null ? 'No expiry' : DateFormat('MMM d, yyyy').format(date!),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: date == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _DocumentVaultTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _DocumentVaultTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
