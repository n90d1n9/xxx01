import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_policy_models.dart';

class EmployeeApprovalPolicyRuleForm extends StatelessWidget {
  final EmployeeApprovalPolicyRuleDraft draft;
  final TextEditingController nameController;
  final TextEditingController ownerController;
  final TextEditingController thresholdController;
  final TextEditingController notesController;
  final ValueChanged<EmployeeApprovalPolicyArea> onAreaChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<EmployeeApprovalRoute> onPrimaryRouteChanged;
  final ValueChanged<EmployeeApprovalRoute> onFallbackRouteChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onThresholdChanged;
  final ValueChanged<int> onEscalationHoursChanged;
  final ValueChanged<EmployeeApprovalEscalationMode> onEscalationModeChanged;
  final ValueChanged<EmployeeApprovalPolicyRisk> onRiskChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectExpiry;
  final VoidCallback onSubmit;

  const EmployeeApprovalPolicyRuleForm({
    super.key,
    required this.draft,
    required this.nameController,
    required this.ownerController,
    required this.thresholdController,
    required this.notesController,
    required this.onAreaChanged,
    required this.onNameChanged,
    required this.onPrimaryRouteChanged,
    required this.onFallbackRouteChanged,
    required this.onOwnerChanged,
    required this.onThresholdChanged,
    required this.onEscalationHoursChanged,
    required this.onEscalationModeChanged,
    required this.onRiskChanged,
    required this.onNotesChanged,
    required this.onSelectExpiry,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeApprovalPolicyArea>(
            initialValue: draft.area,
            decoration: const InputDecoration(
              labelText: 'Policy area',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rule_folder_outlined),
            ),
            items:
                EmployeeApprovalPolicyArea.values
                    .map(
                      (area) => DropdownMenuItem(
                        value: area,
                        child: Text(area.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onAreaChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Policy rule name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title_outlined),
            ),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeApprovalRoute>(
            initialValue: draft.primaryRoute,
            decoration: const InputDecoration(
              labelText: 'Primary route',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
            items:
                EmployeeApprovalRoute.values
                    .map(
                      (route) => DropdownMenuItem(
                        value: route,
                        child: Text(route.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onPrimaryRouteChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeApprovalRoute>(
            initialValue: draft.fallbackRoute,
            decoration: const InputDecoration(
              labelText: 'Fallback route',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment_ind_outlined),
            ),
            items:
                EmployeeApprovalRoute.values
                    .map(
                      (route) => DropdownMenuItem(
                        value: route,
                        child: Text(route.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onFallbackRouteChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Policy owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: thresholdController,
            decoration: const InputDecoration(
              labelText: 'Threshold',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tune_outlined),
            ),
            onChanged: onThresholdChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeApprovalEscalationMode>(
            initialValue: draft.escalationMode,
            decoration: const InputDecoration(
              labelText: 'Escalation mode',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.trending_up_outlined),
            ),
            items:
                EmployeeApprovalEscalationMode.values
                    .map(
                      (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onEscalationModeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: draft.escalationHours,
            decoration: const InputDecoration(
              labelText: 'Escalation window',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule_outlined),
            ),
            items:
                const [4, 8, 24, 48, 72, 120]
                    .map(
                      (hours) => DropdownMenuItem(
                        value: hours,
                        child: Text('$hours hours'),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onEscalationHoursChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeApprovalPolicyRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeApprovalPolicyRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(risk.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _ExpiryField(draft: draft, onTap: onSelectExpiry),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Policy notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNotesChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HrisProgressBar(
                  value: draft.completionRatio,
                  color:
                      draft.isReadyToSubmit
                          ? const Color(0xFF15803D)
                          : HrisColors.primary,
                  label: '${(draft.completionRatio * 100).round()}% ready',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: draft.isReadyToSubmit ? onSubmit : null,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add rule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpiryField extends StatelessWidget {
  final EmployeeApprovalPolicyRuleDraft draft;
  final VoidCallback onTap;

  const _ExpiryField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final expiry = draft.expiresOn;
    final label =
        expiry == null
            ? 'Select expiry'
            : DateFormat('MMM d, yyyy').format(expiry);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Expires on',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
