import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_cutoff_models.dart';
import '../../states/employee_payroll_cutoff_provider.dart';
import 'employee_payroll_cutoff_signoff_form.dart';
import 'employee_payroll_cutoff_tiles.dart';

class EmployeePayrollCutoffReconciliationPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollCutoffReconciliationPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeePayrollCutoffReconciliationPanel> createState() =>
      _EmployeePayrollCutoffReconciliationPanelState();
}

class _EmployeePayrollCutoffReconciliationPanelState
    extends ConsumerState<EmployeePayrollCutoffReconciliationPanel> {
  final _reviewerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _reviewerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeePayrollCutoffReconciliationProvider(employeeId),
    );
    final draft = ref.watch(
      employeePayrollCutoffSignoffDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_reviewerController, draft.reviewer);
    _sync(_noteController, draft.note);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Payroll cutoff reconciliation',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollCutoffSummaryStrip(profile: profile),
        EmployeePayrollCutoffPeriodCard(profile: profile),
        if (profile.signoff == null)
          EmployeePayrollCutoffSignoffForm(
            draft: draft,
            reviewerController: _reviewerController,
            noteController: _noteController,
            blockerCount: profile.blockingCount,
            warningCount: profile.openWarningCount,
            canSignOff: profile.canSignOff,
            onReviewerChanged:
                ref
                    .read(
                      employeePayrollCutoffSignoffDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setReviewer,
            onNoteChanged:
                ref
                    .read(
                      employeePayrollCutoffSignoffDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setNote,
            onAcceptWarningsChanged:
                ref
                    .read(
                      employeePayrollCutoffSignoffDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setAcceptOpenWarnings,
            onSelectReviewDate: () => _selectReviewDate(draft),
            onSubmit: () => _submitSignoff(draft),
          )
        else
          EmployeePayrollCutoffSignoffCard(signoff: profile.signoff!),
        ...profile.sortedItems.map(
          (item) => EmployeePayrollCutoffItemTile(
            item: item,
            onReview: () => _reviewItem(item),
            onResolve: () => _resolveItem(item),
            onWaive: () => _waiveItem(item),
            onReopen: () => _reopenItem(item),
          ),
        ),
      ],
    );
  }

  Future<void> _selectReviewDate(
    EmployeePayrollCutoffSignoffDraft draft,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 45)),
    );
    if (picked == null) return;
    ref
        .read(
          employeePayrollCutoffSignoffDraftProvider(draft.employeeId).notifier,
        )
        .setReviewDate(picked);
  }

  void _submitSignoff(EmployeePayrollCutoffSignoffDraft draft) {
    try {
      final signoff = ref
          .read(
            employeePayrollCutoffReconciliationProvider(
              draft.employeeId,
            ).notifier,
          )
          .submitSignoff(draft);
      ref
          .read(
            employeePayrollCutoffSignoffDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${signoff.id} signed off');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reviewItem(EmployeePayrollCutoffItem item) {
    ref
        .read(
          employeePayrollCutoffReconciliationProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .reviewItem(item.id);
    _showMessage('${item.title} moved to review');
  }

  void _resolveItem(EmployeePayrollCutoffItem item) {
    ref
        .read(
          employeePayrollCutoffReconciliationProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .resolveItem(item.id);
    _showMessage('${item.title} resolved');
  }

  void _waiveItem(EmployeePayrollCutoffItem item) {
    ref
        .read(
          employeePayrollCutoffReconciliationProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .waiveItem(item.id);
    _showMessage('${item.title} waived');
  }

  void _reopenItem(EmployeePayrollCutoffItem item) {
    ref
        .read(
          employeePayrollCutoffReconciliationProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .reopenItem(item.id);
    _showMessage('${item.title} reopened');
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
