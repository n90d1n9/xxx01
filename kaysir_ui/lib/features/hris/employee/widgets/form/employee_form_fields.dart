import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/employee_form_draft.dart';

class EmployeeFormFields extends StatelessWidget {
  final EmployeeFormDraft draft;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onSalaryChanged;
  final VoidCallback onSelectHireDate;

  const EmployeeFormFields({
    super.key,
    required this.draft,
    required this.onNameChanged,
    required this.onPositionChanged,
    required this.onDepartmentChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onSalaryChanged,
    required this.onSelectHireDate,
  });

  @override
  Widget build(BuildContext context) {
    return HrisResponsivePanelGrid(
      panels: [
        HrisSectionPanel(
          icon: Icons.badge_outlined,
          title: 'Identity',
          subtitle: 'Employee profile and contact details',
          children: [
            _EmployeeTextField(
              initialValue: draft.name,
              label: 'Name',
              icon: Icons.person_outline,
              onChanged: onNameChanged,
              validator:
                  (value) =>
                      EmployeeFormDraft.validateRequired(value, 'a name'),
            ),
            _EmployeeTextField(
              initialValue: draft.email,
              label: 'Email',
              icon: Icons.email_outlined,
              onChanged: onEmailChanged,
              keyboardType: TextInputType.emailAddress,
              validator: EmployeeFormDraft.validateEmail,
            ),
            _EmployeeTextField(
              initialValue: draft.phone,
              label: 'Phone',
              icon: Icons.phone_outlined,
              onChanged: onPhoneChanged,
              keyboardType: TextInputType.phone,
              validator:
                  (value) => EmployeeFormDraft.validateRequired(
                    value,
                    'a phone number',
                  ),
            ),
          ],
        ),
        HrisSectionPanel(
          icon: Icons.work_outline,
          title: 'Employment',
          subtitle: 'Role, department, hire date, and salary',
          children: [
            _EmployeeTextField(
              initialValue: draft.position,
              label: 'Position',
              icon: Icons.work_outline,
              onChanged: onPositionChanged,
              validator:
                  (value) =>
                      EmployeeFormDraft.validateRequired(value, 'a position'),
            ),
            _EmployeeTextField(
              initialValue: draft.department,
              label: 'Department',
              icon: Icons.apartment_outlined,
              onChanged: onDepartmentChanged,
              validator:
                  (value) =>
                      EmployeeFormDraft.validateRequired(value, 'a department'),
            ),
            _EmployeeTextField(
              initialValue: draft.salary,
              label: 'Salary',
              icon: Icons.payments_outlined,
              onChanged: onSalaryChanged,
              keyboardType: TextInputType.number,
              validator: EmployeeFormDraft.validateSalary,
            ),
            _HireDateField(hireDate: draft.hireDate, onTap: onSelectHireDate),
          ],
        ),
      ],
    );
  }
}

class _EmployeeTextField extends StatelessWidget {
  final String initialValue;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _EmployeeTextField({
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
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class _HireDateField extends StatelessWidget {
  final DateTime? hireDate;
  final VoidCallback onTap;

  const _HireDateField({required this.hireDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasError = EmployeeFormDraft.validateHireDate(hireDate) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Hire Date',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              errorText: hasError ? 'Please select a hire date' : null,
            ),
            child: Text(
              hireDate == null
                  ? 'Select a date'
                  : DateFormat('MMM d, yyyy').format(hireDate!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: hireDate == null ? HrisColors.muted : HrisColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
