import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_audit_trail_models.dart';

class EmployeeAuditTrailForm extends StatelessWidget {
  final EmployeeAuditTrailDraft draft;
  final TextEditingController titleController;
  final TextEditingController actorController;
  final TextEditingController detailController;
  final ValueChanged<EmployeeAuditTrailSource> onSourceChanged;
  final ValueChanged<EmployeeAuditTrailActionType> onActionTypeChanged;
  final ValueChanged<EmployeeAuditTrailSeverity> onSeverityChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onActorChanged;
  final ValueChanged<String> onDetailChanged;
  final ValueChanged<bool> onSensitiveChanged;
  final VoidCallback onSubmit;

  const EmployeeAuditTrailForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.actorController,
    required this.detailController,
    required this.onSourceChanged,
    required this.onActionTypeChanged,
    required this.onSeverityChanged,
    required this.onTitleChanged,
    required this.onActorChanged,
    required this.onDetailChanged,
    required this.onSensitiveChanged,
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
            first: DropdownButtonFormField<EmployeeAuditTrailSource>(
              initialValue: draft.source,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Source',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.source_outlined),
              ),
              items:
                  EmployeeAuditTrailSource.values
                      .map(
                        (source) => DropdownMenuItem(
                          value: source,
                          child: Text(
                            source.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onSourceChanged(value);
              },
            ),
            second: DropdownButtonFormField<EmployeeAuditTrailActionType>(
              initialValue: draft.actionType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.rule_outlined),
              ),
              items:
                  EmployeeAuditTrailActionType.values
                      .map(
                        (action) => DropdownMenuItem(
                          value: action,
                          child: Text(
                            action.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onActionTypeChanged(value);
              },
            ),
          ),
          const SizedBox(height: 12),
          _ResponsiveFieldPair(
            first: DropdownButtonFormField<EmployeeAuditTrailSeverity>(
              initialValue: draft.severity,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items:
                  EmployeeAuditTrailSeverity.values
                      .map(
                        (severity) => DropdownMenuItem(
                          value: severity,
                          child: Text(
                            severity.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) onSeverityChanged(value);
              },
            ),
            second: _AuditTextField(
              controller: actorController,
              label: 'Actor',
              icon: Icons.person_outline,
              onChanged: onActorChanged,
            ),
          ),
          const SizedBox(height: 12),
          _AuditTextField(
            controller: titleController,
            label: 'Audit title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _AuditTextField(
            controller: detailController,
            label: 'Detail',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onDetailChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Contains sensitive employee data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch.adaptive(
                value: draft.containsSensitiveData,
                onChanged: onSensitiveChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add audit note'),
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

class _AuditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _AuditTextField({
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
