import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentInterventionTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class IncomingTalentDevelopmentInterventionStatusFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionDraft draft;
  final ValueChanged<IncomingTalentDevelopmentInterventionType> onTypeChanged;
  final ValueChanged<IncomingTalentDevelopmentInterventionPriority>
  onPriorityChanged;
  final ValueChanged<IncomingTalentDevelopmentInterventionStatus>
  onStatusChanged;

  const IncomingTalentDevelopmentInterventionStatusFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeField =
        DropdownButtonFormField<IncomingTalentDevelopmentInterventionType>(
          initialValue: draft.actionType,
          decoration: const InputDecoration(
            labelText: 'Action type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items:
              IncomingTalentDevelopmentInterventionType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator:
              IncomingTalentDevelopmentInterventionDraft.validateActionType,
        );
    final priorityField = DropdownButtonFormField<
      IncomingTalentDevelopmentInterventionPriority
    >(
      initialValue: draft.priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high_outlined),
      ),
      items:
          IncomingTalentDevelopmentInterventionPriority.values
              .map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.label),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onPriorityChanged(value);
      },
      validator: IncomingTalentDevelopmentInterventionDraft.validatePriority,
    );
    final statusField =
        DropdownButtonFormField<IncomingTalentDevelopmentInterventionStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.route_outlined),
          ),
          items:
              IncomingTalentDevelopmentInterventionStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
          validator: IncomingTalentDevelopmentInterventionDraft.validateStatus,
        );

    return Column(
      children: [
        typeField,
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 620) {
              return Column(
                children: [
                  priorityField,
                  const SizedBox(height: 12),
                  statusField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: priorityField),
                const SizedBox(width: 12),
                Expanded(child: statusField),
              ],
            );
          },
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentInterventionDueDateField
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionDraft draft;
  final VoidCallback onSelectDueDate;

  const IncomingTalentDevelopmentInterventionDueDateField({
    super.key,
    required this.draft,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final error = IncomingTalentDevelopmentInterventionDraft.validateDueDate(
      draft.dueDate,
      draft.asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectDueDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.dueDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.dueDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.dueDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class IncomingTalentDevelopmentInterventionDraftReadiness
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionDraft draft;

  const IncomingTalentDevelopmentInterventionDraftReadiness({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% complete',
          ),
          if (draft.source != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: draft.source!.label,
                ),
                if (draft.releaseEvidenceCount > 0)
                  TalentMetaLabel(
                    icon: Icons.workspace_premium_outlined,
                    label: '${draft.releaseEvidenceCount} evidence signals',
                  ),
                if (draft.programCompletionExtensionCount > 0)
                  TalentMetaLabel(
                    icon: Icons.report_problem_outlined,
                    label:
                        '${draft.programCompletionExtensionCount} extensions',
                  ),
              ],
            ),
          ],
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
