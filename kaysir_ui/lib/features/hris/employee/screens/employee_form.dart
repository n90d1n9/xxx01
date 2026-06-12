import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../../../utils/id_generator.dart';
import '../models/employee.dart';
import '../states/employee_form_provider.dart';
import '../states/employee_provider.dart';
import '../widgets/form/employee_form_fields.dart';
import '../widgets/form/employee_form_header.dart';
import '../widgets/form/employee_form_readiness_panel.dart';

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends ConsumerState<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    ref.read(employeeFormDraftProvider.notifier).initialize(widget.employee);
  }

  @override
  void didUpdateWidget(covariant AddEditEmployeeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employee?.id != widget.employee?.id) {
      ref.read(employeeFormDraftProvider.notifier).initialize(widget.employee);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(employeeFormDraftProvider);
    final form = ref.read(employeeFormDraftProvider.notifier);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmployeeFormHeader(isEditing: _isEditing),
                        const SizedBox(height: 16),
                        EmployeeFormFields(
                          draft: draft,
                          onNameChanged: form.setName,
                          onPositionChanged: form.setPosition,
                          onDepartmentChanged: form.setDepartment,
                          onEmailChanged: form.setEmail,
                          onPhoneChanged: form.setPhone,
                          onSalaryChanged: form.setSalary,
                          onSelectHireDate: _selectDate,
                        ),
                        const SizedBox(height: 16),
                        EmployeeFormReadinessPanel(draft: draft),
                        const SizedBox(height: 20),
                        _EmployeeFormActions(
                          isEditing: _isEditing,
                          onCancel: () => Navigator.of(context).pop(),
                          onSave: _saveEmployee,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    final draft = ref.read(employeeFormDraftProvider);
    final validFields = _formKey.currentState?.validate() == true;
    if (!validFields || !draft.isReadyToSave) {
      final message =
          draft.validationErrors.isEmpty
              ? 'Please review the highlighted fields'
              : draft.validationErrors.first;
      _showMessage(message);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final employee = draft.toEmployee(
        id: widget.employee?.id ?? SnowflakeIdGenerator(1).next(),
        existing: widget.employee,
      );

      if (_isEditing) {
        await ref.read(employeeListProvider.notifier).updateEmployee(employee);
      } else {
        await ref.read(employeeListProvider.notifier).addEmployee(employee);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage('Error: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final draft = ref.read(employeeFormDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    ref.read(employeeFormDraftProvider.notifier).setHireDate(picked);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmployeeFormActions extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EmployeeFormActions({
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onSave,
          icon: Icon(
            isEditing ? Icons.save_outlined : Icons.person_add_alt_outlined,
          ),
          label: Text(isEditing ? 'Update Employee' : 'Add Employee'),
        ),
      ],
    );
  }
}
