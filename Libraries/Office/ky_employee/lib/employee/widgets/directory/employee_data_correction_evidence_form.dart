import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_governance_models.dart';
import '../../models/employee_data_correction_models.dart';

class EmployeeDataCorrectionEvidenceForm extends StatelessWidget {
  final EmployeeDataCorrectionEvidenceDraft draft;
  final List<EmployeeDataCorrectionRequest> requests;
  final TextEditingController authorController;
  final TextEditingController summaryController;
  final ValueChanged<String> onRequestChanged;
  final ValueChanged<String> onAuthorChanged;
  final ValueChanged<String> onSummaryChanged;
  final VoidCallback onAdd;

  const EmployeeDataCorrectionEvidenceForm({
    super.key,
    required this.draft,
    required this.requests,
    required this.authorController,
    required this.summaryController,
    required this.onRequestChanged,
    required this.onAuthorChanged,
    required this.onSummaryChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _RequestPicker(
                      draft: draft,
                      requests: requests,
                      onChanged: onRequestChanged,
                    ),
                    const SizedBox(height: 12),
                    _authorField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _RequestPicker(
                      draft: draft,
                      requests: requests,
                      onChanged: onRequestChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _authorField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: summaryController,
            minLines: 2,
            maxLines: 4,
            onChanged: onSummaryChanged,
            decoration: const InputDecoration(
              labelText: 'Evidence summary',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
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
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add evidence'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authorField() {
    return TextField(
      controller: authorController,
      onChanged: onAuthorChanged,
      decoration: const InputDecoration(
        labelText: 'Evidence author',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }
}

class _RequestPicker extends StatelessWidget {
  final EmployeeDataCorrectionEvidenceDraft draft;
  final List<EmployeeDataCorrectionRequest> requests;
  final ValueChanged<String> onChanged;

  const _RequestPicker({
    required this.draft,
    required this.requests,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRequestId =
        requests.any((request) => request.id == draft.requestId)
            ? draft.requestId
            : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedRequestId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Correction request',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.edit_note_outlined),
      ),
      items:
          requests
              .map(
                (request) => DropdownMenuItem(
                  value: request.id,
                  child: Text(request.field, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (requestId) {
        if (requestId != null) onChanged(requestId);
      },
    );
  }
}
