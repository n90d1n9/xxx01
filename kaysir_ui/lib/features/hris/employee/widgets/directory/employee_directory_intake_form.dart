import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_intake_draft.dart';
import '../../models/employee_directory_models.dart';

class EmployeeDirectoryIntakeFormFields extends StatelessWidget {
  final EmployeeDirectoryIntakeDraft draft;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onPerformanceChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<EmployeeDirectoryStatus> onStatusChanged;
  final VoidCallback onSelectJoiningDate;

  const EmployeeDirectoryIntakeFormFields({
    super.key,
    required this.draft,
    required this.onNameChanged,
    required this.onPositionChanged,
    required this.onDepartmentChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onPerformanceChanged,
    required this.onLocationChanged,
    required this.onManagerChanged,
    required this.onStatusChanged,
    required this.onSelectJoiningDate,
  });

  @override
  Widget build(BuildContext context) {
    return HrisResponsivePanelGrid(
      panels: [
        HrisSectionPanel(
          icon: Icons.badge_outlined,
          title: 'Profile identity',
          subtitle: 'Core employee identity and contact data',
          children: [
            _IntakeTextField(
              fieldKey: const ValueKey('employee-directory-intake-name-field'),
              initialValue: draft.name,
              label: 'Name',
              icon: Icons.person_outline,
              onChanged: onNameChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a name',
                  ),
            ),
            _IntakeTextField(
              fieldKey: const ValueKey('employee-directory-intake-email-field'),
              initialValue: draft.email,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: onEmailChanged,
              validator: EmployeeDirectoryIntakeDraft.validateEmail,
            ),
            _IntakeTextField(
              fieldKey: const ValueKey('employee-directory-intake-phone-field'),
              initialValue: draft.phone,
              label: 'Phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: onPhoneChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a phone number',
                  ),
            ),
            _IntakeTextField(
              fieldKey: const ValueKey(
                'employee-directory-intake-location-field',
              ),
              initialValue: draft.location,
              label: 'Work location',
              icon: Icons.location_on_outlined,
              onChanged: onLocationChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a work location',
                  ),
            ),
          ],
        ),
        HrisSectionPanel(
          icon: Icons.work_outline,
          title: 'Employment setup',
          subtitle: 'Role, reporting line, status, and first rating',
          children: [
            _IntakeTextField(
              fieldKey: const ValueKey(
                'employee-directory-intake-position-field',
              ),
              initialValue: draft.position,
              label: 'Position',
              icon: Icons.work_outline,
              onChanged: onPositionChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a position',
                  ),
            ),
            _IntakeTextField(
              fieldKey: const ValueKey(
                'employee-directory-intake-department-field',
              ),
              initialValue: draft.department,
              label: 'Department',
              icon: Icons.apartment_outlined,
              onChanged: onDepartmentChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a department',
                  ),
            ),
            _IntakeTextField(
              fieldKey: const ValueKey(
                'employee-directory-intake-manager-field',
              ),
              initialValue: draft.manager,
              label: 'Manager',
              icon: Icons.supervisor_account_outlined,
              onChanged: onManagerChanged,
              validator:
                  (value) => EmployeeDirectoryIntakeDraft.validateRequired(
                    value,
                    'a manager',
                  ),
            ),
            _IntakeTextField(
              fieldKey: const ValueKey(
                'employee-directory-intake-performance-field',
              ),
              initialValue: draft.performance,
              label: 'Initial rating',
              icon: Icons.trending_up_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onPerformanceChanged,
              validator: EmployeeDirectoryIntakeDraft.validatePerformance,
            ),
            _JoiningDateField(
              joiningDate: draft.joiningDate,
              onTap: onSelectJoiningDate,
            ),
            _StatusField(value: draft.status, onChanged: onStatusChanged),
          ],
        ),
      ],
    );
  }
}

class EmployeeDirectoryIntakeReadinessPanel extends StatelessWidget {
  final EmployeeDirectoryIntakeDraft draft;

  const EmployeeDirectoryIntakeReadinessPanel({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisSectionPanel(
      icon: ready ? Icons.verified_outlined : Icons.rule_outlined,
      title: ready ? 'Ready to create' : 'Intake readiness',
      subtitle:
          ready
              ? 'All required directory data is complete'
              : '${errors.length} item(s) need attention',
      children: [
        HrisProgressBar(
          value: draft.completionRatio,
          color: ready ? const Color(0xFF15803D) : HrisColors.primary,
          label: '${(draft.completionRatio * 100).round()}% complete',
        ),
        if (errors.isEmpty)
          const HrisListSurface(
            child: Text('This employee can be added to the directory.'),
          )
        else
          ...errors
              .take(4)
              .map(
                (error) => HrisListSurface(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class _IntakeTextField extends StatelessWidget {
  final Key fieldKey;
  final String initialValue;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;

  const _IntakeTextField({
    required this.fieldKey,
    required this.initialValue,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        isDense: true,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class _JoiningDateField extends StatelessWidget {
  final DateTime? joiningDate;
  final VoidCallback onTap;

  const _JoiningDateField({required this.joiningDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasError =
        EmployeeDirectoryIntakeDraft.validateJoiningDate(joiningDate) != null;

    return InkWell(
      key: const ValueKey('employee-directory-intake-joining-date-field'),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Joining date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          errorText: hasError ? 'Please select a joining date' : null,
          isDense: true,
        ),
        child: Text(
          joiningDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(joiningDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: joiningDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _StatusField extends StatelessWidget {
  final EmployeeDirectoryStatus value;
  final ValueChanged<EmployeeDirectoryStatus> onChanged;

  const _StatusField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EmployeeDirectoryStatus>(
      key: const ValueKey('employee-directory-intake-status-field'),
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Directory status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.verified_user_outlined),
        isDense: true,
      ),
      items:
          EmployeeDirectoryStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (status) {
        if (status == null) return;
        onChanged(status);
      },
    );
  }
}
