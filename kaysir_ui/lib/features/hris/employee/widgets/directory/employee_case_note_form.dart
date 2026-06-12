import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_case_log_models.dart';

class EmployeeHrCaseNoteForm extends StatelessWidget {
  final EmployeeHrCaseNoteDraft draft;
  final List<EmployeeHrCaseRecord> cases;
  final TextEditingController authorController;
  final TextEditingController bodyController;
  final ValueChanged<String> onCaseChanged;
  final ValueChanged<String> onAuthorChanged;
  final ValueChanged<String> onBodyChanged;
  final ValueChanged<bool> onConfidentialChanged;
  final VoidCallback onAdd;

  const EmployeeHrCaseNoteForm({
    super.key,
    required this.draft,
    required this.cases,
    required this.authorController,
    required this.bodyController,
    required this.onCaseChanged,
    required this.onAuthorChanged,
    required this.onBodyChanged,
    required this.onConfidentialChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: draft.caseId.isEmpty ? null : draft.caseId,
            decoration: const InputDecoration(
              labelText: 'Case',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder_shared_outlined),
            ),
            items:
                cases
                    .map(
                      (record) => DropdownMenuItem(
                        value: record.id,
                        child: Text(record.title),
                      ),
                    )
                    .toList(),
            onChanged: (caseId) {
              if (caseId != null) onCaseChanged(caseId);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: authorController,
            decoration: const InputDecoration(
              labelText: 'Author',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onAuthorChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Case note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onBodyChanged,
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Confidential note'),
              value: draft.confidential,
              onChanged: onConfidentialChanged,
            ),
          ),
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
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add note'),
            ),
          ),
        ],
      ),
    );
  }
}
