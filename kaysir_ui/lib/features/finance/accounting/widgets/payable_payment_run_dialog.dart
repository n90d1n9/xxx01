import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:uuid/uuid.dart';

import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../models/invoice.dart';
import '../models/payable_payment_run.dart';
import '../models/payment.dart';
import '../states/accounting_core_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/invoice_provider.dart';
import '../states/payable_payment_run_provider.dart';
import '../states/paymen_proc_provider.dart';
import 'closed_period_posting_notice.dart';
import 'payable_payment_run_components.dart';

class PayablePaymentRunDialog extends ConsumerStatefulWidget {
  const PayablePaymentRunDialog({super.key});

  @override
  ConsumerState<PayablePaymentRunDialog> createState() =>
      _PayablePaymentRunDialogState();
}

class _PayablePaymentRunDialogState
    extends ConsumerState<PayablePaymentRunDialog> {
  final _referenceController = TextEditingController();
  final Set<String> _selectedBillIds = {};
  DateTime _paymentDate = DateTime.now();
  String _method = 'bank_transfer';
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _referenceController.text =
        'RUN-${DateFormat('yyyyMMdd-HHmm').format(_paymentDate)}';
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(payablePaymentRunServiceProvider);
    final openBills = service.openBills(ref.watch(allPayableInvoicesProvider));
    final plan = service.plan(
      bills: openBills,
      selectedBillIds: _selectedBillIds,
    );
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(_paymentDate);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final canPost = !_isPosting && !plan.isEmpty && closeRecord == null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AP Payment Run',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              PaymentRunSummaryPanel(plan: plan, currency: currency),
              const SizedBox(height: 16),
              PaymentRunControls(
                referenceController: _referenceController,
                paymentDate: _paymentDate,
                method: _method,
                isPosting: _isPosting,
                onMethodChanged: (value) => setState(() => _method = value),
                onPickDate: _pickPaymentDate,
              ),
              ClosedPeriodPostingNotice(
                closeRecord: closeRecord,
                actionLabel: 'post this AP payment run',
              ),
              const SizedBox(height: 12),
              PaymentRunQuickSelectBar(
                hasOpenBills: openBills.isNotEmpty,
                hasSelection: _selectedBillIds.isNotEmpty,
                isPosting: _isPosting,
                onDueNow: () => _selectDueThrough(openBills, DateTime.now()),
                onNextSevenDays:
                    () => _selectDueThrough(
                      openBills,
                      DateTime.now().add(const Duration(days: 7)),
                    ),
                onAllOpen:
                    () => setState(() {
                      _selectedBillIds
                        ..clear()
                        ..addAll(openBills.map((bill) => bill.id));
                    }),
                onClear: () => setState(_selectedBillIds.clear),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PaymentRunBillPickerPanel(
                  bills: openBills,
                  selectedBillIds: _selectedBillIds,
                  currency: currency,
                  isPosting: _isPosting,
                  onBillSelectionChanged:
                      (billId, isSelected) =>
                          _toggleBill(billId, isSelected: isSelected),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: 'Cancel',
                cancelIcon: Icons.close_rounded,
                onCancel: _isPosting ? null : () => Navigator.of(context).pop(),
                confirmLabel: _isPosting ? 'Posting...' : 'Post Payments',
                confirmIcon: _isPosting ? null : Icons.payments_outlined,
                confirmVariant: AppActionButtonVariant.primary,
                onConfirm: canPost ? () => _postRun(plan) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleBill(String billId, {required bool isSelected}) {
    setState(() {
      if (isSelected) {
        _selectedBillIds.add(billId);
      } else {
        _selectedBillIds.remove(billId);
      }
    });
  }

  void _selectDueThrough(List<Invoice> bills, DateTime date) {
    final service = ref.read(payablePaymentRunServiceProvider);
    setState(() {
      _selectedBillIds
        ..clear()
        ..addAll(service.dueOnOrBefore(bills: bills, date: date));
    });
  }

  Future<void> _pickPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) {
      return;
    }
    setState(() => _paymentDate = date);
  }

  void _postRun(PayablePaymentRunPlan plan) {
    final reference = _referenceController.text.trim();
    if (reference.isEmpty) {
      _showPostingError('Payment reference is required');
      return;
    }

    setState(() => _isPosting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final payments = <Payment>[];
    final postings = <LedgerPosting>[];

    var didClose = false;
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(_paymentDate, actionLabel: 'post AP payment run');
      for (var index = 0; index < plan.items.length; index++) {
        final item = plan.items[index];
        final paymentReference =
            plan.items.length == 1 ? reference : '$reference-${index + 1}';
        final payment = Payment(
          id: const Uuid().v4(),
          invoiceId: item.billId,
          amount: item.amount,
          paymentDate: _paymentDate,
          reference: paymentReference,
          referenceNumber: paymentReference,
          method: _method,
        );
        final posting = ref
            .read(payablePostingServiceProvider)
            .postPayment(bill: item.bill, payment: payment);

        payments.add(payment);
        postings.add(posting);
      }

      for (var index = 0; index < payments.length; index++) {
        final payment = payments[index];
        ref.read(paymentsProvider.notifier).addPayment(payment);
        ref
            .read(invoicesProvider.notifier)
            .recordPayment(payment.invoiceId, payment);
        ref.read(postedLedgerProvider.notifier).addPosting(postings[index]);
      }
      final record = ref
          .read(payablePaymentRunServiceProvider)
          .record(
            id: const Uuid().v4(),
            reference: reference,
            paymentDate: _paymentDate,
            createdAt: DateTime.now(),
            method: _method,
            plan: plan,
            payments: payments,
          );
      ref.read(payablePaymentRunRecordsProvider.notifier).addRecord(record);

      didClose = true;
      navigator.pop(payments);
      messenger.showSnackBar(
        SnackBar(content: Text('${payments.length} bill payments posted')),
      );
    } on LedgerPostingException catch (error) {
      _showPostingError(error.issues.join('\n'));
    } on ArgumentError catch (error) {
      _showPostingError(error.message?.toString() ?? 'Invalid payment run');
    } on StateError catch (error) {
      _showPostingError(error.message);
    } finally {
      if (mounted && !didClose) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _showPostingError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }
}
