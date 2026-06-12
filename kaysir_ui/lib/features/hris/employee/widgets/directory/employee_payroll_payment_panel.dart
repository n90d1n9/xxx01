import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_payment_models.dart';
import '../../states/employee_payroll_payment_provider.dart';
import 'employee_payroll_payment_form.dart';
import 'employee_payroll_payment_tiles.dart';

class EmployeePayrollPaymentPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollPaymentPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayrollPaymentPanel> createState() =>
      _EmployeePayrollPaymentPanelState();
}

class _EmployeePayrollPaymentPanelState
    extends ConsumerState<EmployeePayrollPaymentPanel> {
  final _ownerController = TextEditingController();
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _ownerController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayrollPaymentProvider(employeeId));
    final draft = ref.watch(employeePayrollPaymentDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(
      _ownerController,
      profile.paymentOwner.isEmpty ? draft.owner : profile.paymentOwner,
    );
    _sync(
      _referenceController,
      profile.paymentReference.isEmpty
          ? draft.reference
          : profile.paymentReference,
    );
    _sync(
      _noteController,
      profile.paymentNote.isEmpty ? draft.note : profile.paymentNote,
    );

    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Payment disbursement',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollPaymentSummaryStrip(profile: profile),
        EmployeePayrollPaymentStatusCard(profile: profile),
        EmployeePayrollPaymentForm(
          profile: profile,
          draft: draft,
          ownerController: _ownerController,
          referenceController: _referenceController,
          noteController: _noteController,
          onOwnerChanged:
              ref
                  .read(
                    employeePayrollPaymentDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onReferenceChanged:
              ref
                  .read(
                    employeePayrollPaymentDraftProvider(employeeId).notifier,
                  )
                  .setReference,
          onNoteChanged:
              ref
                  .read(
                    employeePayrollPaymentDraftProvider(employeeId).notifier,
                  )
                  .setNote,
          onScheduledForChanged:
              ref
                  .read(
                    employeePayrollPaymentDraftProvider(employeeId).notifier,
                  )
                  .setScheduledFor,
          onSchedule: () => _schedule(draft),
          onHold: _hold,
          onReopen: _reopen,
          onMarkPaid: _markPaid,
        ),
        ...profile.sortedInstructions.map(
          (instruction) =>
              EmployeePayrollPaymentInstructionTile(instruction: instruction),
        ),
      ],
    );
  }

  void _schedule(EmployeePayrollPaymentDraft draft) {
    try {
      ref
          .read(employeePayrollPaymentProvider(draft.employeeId).notifier)
          .schedule(draft);
      _showMessage('Payroll payment scheduled');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _hold() {
    try {
      ref
          .read(
            employeePayrollPaymentProvider(widget.snapshot.member.id).notifier,
          )
          .hold();
      _showMessage('Payroll payment placed on hold');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reopen() {
    ref
        .read(
          employeePayrollPaymentProvider(widget.snapshot.member.id).notifier,
        )
        .reopen();
    _showMessage('Payroll payment reopened');
  }

  void _markPaid() {
    try {
      ref
          .read(
            employeePayrollPaymentProvider(widget.snapshot.member.id).notifier,
          )
          .markPaid();
      _showMessage('Payroll payment settled');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
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
