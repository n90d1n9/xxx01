import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';
import 'package:uuid/uuid.dart';

import '../accounting_core/services/ledger_posting_service.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../states/accounting_core_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/invoice_provider.dart';
import '../states/paymen_proc_provider.dart';
import 'closed_period_posting_notice.dart';
import 'payable_payment_components.dart';

class PayablePaymentDialog extends ConsumerStatefulWidget {
  final Invoice bill;

  const PayablePaymentDialog({required this.bill, super.key});

  @override
  ConsumerState<PayablePaymentDialog> createState() =>
      _PayablePaymentDialogState();
}

class _PayablePaymentDialogState extends ConsumerState<PayablePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String _method = 'bank_transfer';
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.remainingAmount.toStringAsFixed(2);
    _referenceController.text =
        'PAY-${widget.bill.invoiceNumber ?? widget.bill.id}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final billReference = widget.bill.invoiceNumber ?? widget.bill.id;
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(_paymentDate);
    final canPost = !_isPosting && closeRecord == null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, billReference),
              const SizedBox(height: 18),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PayablePaymentBalancePanel(
                          billReference: billReference,
                          vendorName: widget.bill.vendorName ?? 'Vendor bill',
                          outstandingAmount: widget.bill.remainingAmount,
                          currency: currency,
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentFields(),
                        const SizedBox(height: 12),
                        PayablePaymentMethodField(
                          method: _method,
                          enabled: !_isPosting,
                          onChanged: (value) => setState(() => _method = value),
                        ),
                        const SizedBox(height: 12),
                        PayablePaymentDateField(
                          paymentDate: _paymentDate,
                          onTap: _isPosting ? null : _pickPaymentDate,
                        ),
                        ClosedPeriodPostingNotice(
                          closeRecord: closeRecord,
                          actionLabel: 'post this vendor payment',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: 'Cancel',
                onCancel: _isPosting ? null : () => Navigator.of(context).pop(),
                confirmLabel: _isPosting ? 'Posting...' : 'Post Payment',
                confirmIcon:
                    _isPosting ? Icons.hourglass_top_rounded : Icons.task_alt,
                confirmVariant: AppActionButtonVariant.primary,
                onConfirm: canPost ? _postPayment : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String billReference) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.payments_outlined,
          size: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: 'Pay Bill $billReference',
            subtitle: widget.bill.vendorName ?? 'AP payment posting',
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final amountField = TextFormField(
          controller: _amountController,
          enabled: !_isPosting,
          decoration: _inputDecoration(
            context,
            label: 'Payment Amount',
            icon: Icons.attach_money_rounded,
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a payment amount';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null) {
              return 'Please enter a valid number';
            }
            if (amount <= 0) {
              return 'Amount must be greater than zero';
            }
            if (amount - widget.bill.remainingAmount > 0.01) {
              return 'Amount cannot exceed outstanding balance';
            }
            return null;
          },
        );
        final referenceField = TextFormField(
          controller: _referenceController,
          enabled: !_isPosting,
          decoration: _inputDecoration(
            context,
            label: 'Payment Reference',
            icon: Icons.confirmation_number_outlined,
            hintText: 'Transfer ID, check number, or note',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a payment reference';
            }
            return null;
          },
        );

        if (constraints.maxWidth < 500) {
          return Column(
            children: [amountField, const SizedBox(height: 12), referenceField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: amountField),
            const SizedBox(width: 12),
            Expanded(child: referenceField),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? prefixText,
    String? hintText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: icon == null ? null : Icon(icon, size: 18),
      prefixText: prefixText,
      filled: true,
      fillColor: colorScheme.surface,
      border: border,
      enabledBorder: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
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

  void _postPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPosting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final reference = _referenceController.text.trim();
    final payment = Payment(
      id: const Uuid().v4(),
      invoiceId: widget.bill.id,
      amount: double.parse(_amountController.text.trim()),
      paymentDate: _paymentDate,
      reference: reference,
      referenceNumber: reference,
      method: _method,
    );

    var didClose = false;
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(_paymentDate, actionLabel: 'post vendor payment');
      final posting = ref
          .read(payablePostingServiceProvider)
          .postPayment(bill: widget.bill, payment: payment);
      ref.read(paymentsProvider.notifier).addPayment(payment);
      ref
          .read(invoicesProvider.notifier)
          .recordPayment(widget.bill.id, payment);
      ref.read(postedLedgerProvider.notifier).addPosting(posting);

      didClose = true;
      navigator.pop(payment);
      messenger.showSnackBar(
        const SnackBar(content: Text('Bill payment posted to ledger')),
      );
    } on LedgerPostingException catch (error) {
      _showPostingError(error.issues.join('\n'));
    } on ArgumentError catch (error) {
      _showPostingError(error.message?.toString() ?? 'Invalid payment');
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
