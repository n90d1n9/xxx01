import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_variance_models.dart';
import '../../states/employee_payroll_variance_provider.dart';
import 'employee_payroll_variance_adjustment_form.dart';
import 'employee_payroll_variance_tiles.dart';

class EmployeePayrollVarianceReviewPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollVarianceReviewPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayrollVarianceReviewPanel> createState() =>
      _EmployeePayrollVarianceReviewPanelState();
}

class _EmployeePayrollVarianceReviewPanelState
    extends ConsumerState<EmployeePayrollVarianceReviewPanel> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _ownerController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _ownerController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayrollVarianceProvider(employeeId));
    final draft = ref.watch(
      employeePayrollVarianceAdjustmentDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_amountController, _amountText(draft.amount));
    _sync(_ownerController, draft.owner);
    _sync(_reasonController, draft.reason);

    return HrisSectionPanel(
      icon: Icons.stacked_line_chart_outlined,
      title: 'Payroll variance review',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollVarianceSummaryStrip(profile: profile),
        EmployeePayrollVariancePeriodCard(profile: profile),
        EmployeePayrollVarianceAdjustmentForm(
          draft: draft,
          titleController: _titleController,
          amountController: _amountController,
          ownerController: _ownerController,
          reasonController: _reasonController,
          onTitleChanged:
              ref
                  .read(
                    employeePayrollVarianceAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onAmountChanged:
              ref
                  .read(
                    employeePayrollVarianceAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setAmount,
          onOwnerChanged:
              ref
                  .read(
                    employeePayrollVarianceAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onReasonChanged:
              ref
                  .read(
                    employeePayrollVarianceAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setReason,
          onTaxableImpactChanged:
              ref
                  .read(
                    employeePayrollVarianceAdjustmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTaxableImpact,
          onAdd: () => _addAdjustment(draft),
        ),
        ...profile.sortedLines.map(
          (line) => EmployeePayrollVarianceLineTile(
            line: line,
            onReview: () => _reviewLine(line),
            onApprove: () => _approveLine(line),
            onExclude: () => _excludeLine(line),
            onReopen: () => _reopenLine(line),
          ),
        ),
      ],
    );
  }

  void _addAdjustment(EmployeePayrollVarianceAdjustmentDraft draft) {
    try {
      final line = ref
          .read(employeePayrollVarianceProvider(draft.employeeId).notifier)
          .addAdjustment(draft);
      ref
          .read(
            employeePayrollVarianceAdjustmentDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${line.title} added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reviewLine(EmployeePayrollVarianceLine line) {
    ref
        .read(
          employeePayrollVarianceProvider(widget.snapshot.member.id).notifier,
        )
        .reviewLine(line.id);
    _showMessage('${line.title} moved to review');
  }

  void _approveLine(EmployeePayrollVarianceLine line) {
    ref
        .read(
          employeePayrollVarianceProvider(widget.snapshot.member.id).notifier,
        )
        .approveLine(line.id);
    _showMessage('${line.title} approved');
  }

  void _excludeLine(EmployeePayrollVarianceLine line) {
    ref
        .read(
          employeePayrollVarianceProvider(widget.snapshot.member.id).notifier,
        )
        .excludeLine(line.id);
    _showMessage('${line.title} excluded from projection');
  }

  void _reopenLine(EmployeePayrollVarianceLine line) {
    ref
        .read(
          employeePayrollVarianceProvider(widget.snapshot.member.id).notifier,
        )
        .reopenLine(line.id);
    _showMessage('${line.title} reopened');
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

  String _amountText(double value) {
    if (value == 0) return '';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }
}
