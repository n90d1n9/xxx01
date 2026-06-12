import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_reimbursement_models.dart';
import '../../states/employee_reimbursement_provider.dart';
import 'employee_reimbursement_form.dart';
import 'employee_reimbursement_tiles.dart';

class EmployeeReimbursementCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeReimbursementCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeReimbursementCenterPanel> createState() =>
      _EmployeeReimbursementCenterPanelState();
}

class _EmployeeReimbursementCenterPanelState
    extends ConsumerState<EmployeeReimbursementCenterPanel> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeReimbursementProfileProvider(employeeId));
    final draft = ref.watch(employeeExpenseDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_merchantController, draft.merchant);
    _sync(
      _amountController,
      draft.amount <= 0 ? '' : draft.amount.round().toString(),
    );
    _sync(_descriptionController, draft.description);

    final claims = [...profile.claims]..sort((a, b) {
      final receiptCompare = _receiptRank(a).compareTo(_receiptRank(b));
      if (receiptCompare != 0) return receiptCompare;
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return b.submittedAt.compareTo(a.submittedAt);
    });

    return HrisSectionPanel(
      icon: Icons.request_quote_outlined,
      title: 'Expenses and reimbursement',
      subtitle: profile.nextAction,
      children: [
        EmployeeReimbursementSummaryStrip(profile: profile),
        EmployeeExpenseAllowanceCard(allowances: profile.allowances),
        EmployeeExpenseClaimForm(
          draft: draft,
          merchantController: _merchantController,
          amountController: _amountController,
          descriptionController: _descriptionController,
          onCategoryChanged:
              ref
                  .read(employeeExpenseDraftProvider(employeeId).notifier)
                  .setCategory,
          onMerchantChanged:
              ref
                  .read(employeeExpenseDraftProvider(employeeId).notifier)
                  .setMerchant,
          onAmountChanged:
              (value) => ref
                  .read(employeeExpenseDraftProvider(employeeId).notifier)
                  .setAmount(_parseAmount(value)),
          onDescriptionChanged:
              ref
                  .read(employeeExpenseDraftProvider(employeeId).notifier)
                  .setDescription,
          onReceiptChanged:
              ref
                  .read(employeeExpenseDraftProvider(employeeId).notifier)
                  .setReceiptAttached,
          onSelectDate: () => _selectIncurredDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (claims.isEmpty)
          const HrisListSurface(child: Text('No expense claims submitted.'))
        else
          ...claims.map(
            (claim) => EmployeeExpenseClaimTile(
              claim: claim,
              onAttachReceipt: () {
                ref
                    .read(
                      employeeReimbursementProfileProvider(employeeId).notifier,
                    )
                    .attachReceipt(claim.id);
                _showMessage('${claim.id} receipt attached');
              },
              onApprove:
                  () => ref
                      .read(
                        employeeReimbursementProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .approveClaim(claim.id),
              onReimburse: () => _reimburseClaim(claim),
              onReject:
                  () => ref
                      .read(
                        employeeReimbursementProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .rejectClaim(claim.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectIncurredDate(EmployeeExpenseDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.incurredOn,
      firstDate: draft.asOfDate.subtract(const Duration(days: 365)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(employeeExpenseDraftProvider(draft.employeeId).notifier)
        .setIncurredOn(picked);
  }

  void _submitDraft(EmployeeExpenseDraft draft) {
    try {
      final claim = ref
          .read(employeeReimbursementProfileProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref.read(employeeExpenseDraftProvider(draft.employeeId).notifier).reset();
      _showMessage('${claim.id} submitted for ${claim.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reimburseClaim(EmployeeExpenseClaim claim) {
    ref
        .read(employeeReimbursementProfileProvider(claim.employeeId).notifier)
        .reimburseClaim(claim.id);
    _showMessage('${claim.id} reimbursed to ${claim.employeeName}');
  }

  int _receiptRank(EmployeeExpenseClaim claim) {
    return claim.needsReceipt &&
            claim.status != EmployeeExpenseClaimStatus.rejected
        ? 0
        : 1;
  }

  int _statusRank(EmployeeExpenseClaimStatus status) {
    return switch (status) {
      EmployeeExpenseClaimStatus.submitted => 0,
      EmployeeExpenseClaimStatus.approved => 1,
      EmployeeExpenseClaimStatus.reimbursed => 2,
      EmployeeExpenseClaimStatus.rejected => 3,
    };
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
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
