import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_intake_draft.dart';
import 'employee_directory_intake_form.dart';

enum EmployeeDirectoryIntakeSheetMode { create, edit }

class EmployeeDirectoryIntakeSheet extends StatefulWidget {
  final DateTime initialJoiningDate;
  final EmployeeDirectoryIntakeDraft? initialDraft;
  final EmployeeDirectoryIntakeSheetMode mode;
  final ValueChanged<EmployeeDirectoryIntakeDraft> onSubmit;

  const EmployeeDirectoryIntakeSheet({
    super.key,
    required this.initialJoiningDate,
    required this.onSubmit,
    this.initialDraft,
    this.mode = EmployeeDirectoryIntakeSheetMode.create,
  });

  @override
  State<EmployeeDirectoryIntakeSheet> createState() =>
      _EmployeeDirectoryIntakeSheetState();
}

class _EmployeeDirectoryIntakeSheetState
    extends State<EmployeeDirectoryIntakeSheet> {
  final _formKey = GlobalKey<FormState>();
  late EmployeeDirectoryIntakeDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft =
        widget.initialDraft ??
        EmployeeDirectoryIntakeDraft.empty(
          joiningDate: widget.initialJoiningDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Form(
                key: _formKey,
                child: Column(
                  key: const ValueKey('employee-directory-intake-sheet'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _EmployeeDirectoryIntakeHeader(
                      mode: widget.mode,
                      completionRatio: _draft.completionRatio,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDirectoryIntakeFormFields(
                      draft: _draft,
                      onNameChanged:
                          (value) => _update(_draft.copyWith(name: value)),
                      onPositionChanged:
                          (value) => _update(_draft.copyWith(position: value)),
                      onDepartmentChanged:
                          (value) =>
                              _update(_draft.copyWith(department: value)),
                      onEmailChanged:
                          (value) => _update(_draft.copyWith(email: value)),
                      onPhoneChanged:
                          (value) => _update(_draft.copyWith(phone: value)),
                      onPerformanceChanged:
                          (value) =>
                              _update(_draft.copyWith(performance: value)),
                      onLocationChanged:
                          (value) => _update(_draft.copyWith(location: value)),
                      onManagerChanged:
                          (value) => _update(_draft.copyWith(manager: value)),
                      onStatusChanged:
                          (value) => _update(_draft.copyWith(status: value)),
                      onSelectJoiningDate: _selectJoiningDate,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDirectoryIntakeReadinessPanel(draft: _draft),
                    const SizedBox(height: 14),
                    _EmployeeDirectoryIntakeActions(
                      mode: widget.mode,
                      onCancel: () => Navigator.of(context).pop(),
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _update(EmployeeDirectoryIntakeDraft draft) {
    setState(() => _draft = draft);
  }

  Future<void> _selectJoiningDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.joiningDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked == null) return;
    _update(_draft.copyWith(joiningDate: picked));
  }

  void _submit() {
    final validFields = _formKey.currentState?.validate() == true;
    if (!validFields || !_draft.isReadyToCreate) {
      final message =
          _draft.validationErrors.isEmpty
              ? 'Please review the highlighted fields'
              : _draft.validationErrors.first;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    widget.onSubmit(_draft);
  }
}

class _EmployeeDirectoryIntakeHeader extends StatelessWidget {
  final EmployeeDirectoryIntakeSheetMode mode;
  final double completionRatio;

  const _EmployeeDirectoryIntakeHeader({
    required this.mode,
    required this.completionRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add_alt_1_outlined,
              color: HrisColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (mode) {
                    EmployeeDirectoryIntakeSheetMode.create =>
                      'Create employee profile',
                    EmployeeDirectoryIntakeSheetMode.edit =>
                      'Update employee profile',
                  },
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  switch (mode) {
                    EmployeeDirectoryIntakeSheetMode.create =>
                      '${(completionRatio * 100).round()}% complete for directory intake',
                    EmployeeDirectoryIntakeSheetMode.edit =>
                      '${(completionRatio * 100).round()}% complete for profile update',
                  },
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDirectoryIntakeActions extends StatelessWidget {
  final EmployeeDirectoryIntakeSheetMode mode;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _EmployeeDirectoryIntakeActions({
    required this.mode,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        const SizedBox(width: 12),
        FilledButton.icon(
          key: const ValueKey('employee-directory-intake-submit-button'),
          onPressed: onSubmit,
          icon: Icon(switch (mode) {
            EmployeeDirectoryIntakeSheetMode.create =>
              Icons.person_add_alt_1_outlined,
            EmployeeDirectoryIntakeSheetMode.edit => Icons.save_outlined,
          }),
          label: Text(switch (mode) {
            EmployeeDirectoryIntakeSheetMode.create => 'Create employee',
            EmployeeDirectoryIntakeSheetMode.edit => 'Update employee',
          }),
        ),
      ],
    );
  }
}
