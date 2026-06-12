import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_models.dart';
import '../../states/employee_payroll_provider.dart';
import 'employee_payroll_change_form.dart';
import 'employee_payroll_tiles.dart';

class EmployeePayrollCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayrollCenterPanel> createState() =>
      _EmployeePayrollCenterPanelState();
}

class _EmployeePayrollCenterPanelState
    extends ConsumerState<EmployeePayrollCenterPanel> {
  final _titleController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _requestedByController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayrollProfileProvider(employeeId));
    final draft = ref.watch(employeePayrollChangeDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_requestedByController, draft.requestedBy);
    _sync(_detailController, draft.detail);

    final changes = [...profile.changes]..sort((a, b) {
      final rankCompare = _changeRank(
        a.status,
      ).compareTo(_changeRank(b.status));
      if (rankCompare != 0) return rankCompare;
      return b.effectiveDate.compareTo(a.effectiveDate);
    });

    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Payroll and tax',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollSummaryStrip(profile: profile),
        EmployeePayrollBankAccountCard(
          bankAccount: profile.bankAccount,
          onVerify: () {
            ref
                .read(employeePayrollProfileProvider(employeeId).notifier)
                .markBankVerified();
            _showMessage('Bank account marked verified');
          },
        ),
        EmployeePayrollTaxProfileCard(
          taxProfile: profile.taxProfile,
          onMarkCurrent: () {
            ref
                .read(employeePayrollProfileProvider(employeeId).notifier)
                .markTaxCurrent();
            _showMessage('Tax profile marked current');
          },
        ),
        EmployeePayrollScheduleCard(
          schedule: profile.schedule,
          asOfDate: profile.asOfDate,
        ),
        EmployeePayrollChangeForm(
          draft: draft,
          titleController: _titleController,
          requestedByController: _requestedByController,
          detailController: _detailController,
          onTypeChanged:
              ref
                  .read(employeePayrollChangeDraftProvider(employeeId).notifier)
                  .setType,
          onTitleChanged:
              ref
                  .read(employeePayrollChangeDraftProvider(employeeId).notifier)
                  .setTitle,
          onRequestedByChanged:
              ref
                  .read(employeePayrollChangeDraftProvider(employeeId).notifier)
                  .setRequestedBy,
          onDetailChanged:
              ref
                  .read(employeePayrollChangeDraftProvider(employeeId).notifier)
                  .setDetail,
          onSelectEffectiveDate: () => _selectEffectiveDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (changes.isEmpty)
          const HrisListSurface(child: Text('No payroll changes submitted.'))
        else
          ...changes.map(
            (change) => EmployeePayrollChangeRequestTile(
              request: change,
              onApprove:
                  () => ref
                      .read(employeePayrollProfileProvider(employeeId).notifier)
                      .approveChange(change.id),
              onApply: () => _applyChange(change),
              onReject:
                  () => ref
                      .read(employeePayrollProfileProvider(employeeId).notifier)
                      .rejectChange(change.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(EmployeePayrollChangeDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 14)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeePayrollChangeDraftProvider(draft.employeeId).notifier)
        .setEffectiveDate(picked);
  }

  void _submitDraft(EmployeePayrollChangeDraft draft) {
    try {
      final request = ref
          .read(employeePayrollProfileProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref
          .read(employeePayrollChangeDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.id} submitted for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _applyChange(EmployeePayrollChangeRequest change) {
    ref
        .read(employeePayrollProfileProvider(change.employeeId).notifier)
        .applyChange(change.id);
    _showMessage('${change.id} applied to ${change.employeeName}');
  }

  int _changeRank(EmployeePayrollChangeStatus status) {
    return switch (status) {
      EmployeePayrollChangeStatus.submitted => 0,
      EmployeePayrollChangeStatus.approved => 1,
      EmployeePayrollChangeStatus.applied => 2,
      EmployeePayrollChangeStatus.rejected => 3,
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
