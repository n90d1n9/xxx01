import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
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
import 'receivable_payment_components.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final Invoice invoice;
  final double outstandingAmount;

  const AddPaymentDialog({
    required this.invoice,
    required this.outstandingAmount,
    super.key,
  });

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String _method = 'bank_transfer';
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.outstandingAmount.toStringAsFixed(2);
    _referenceController.text =
        'RCPT-${widget.invoice.reference ?? widget.invoice.id}';
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
    final invoiceReference = widget.invoice.reference ?? widget.invoice.id;
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
              _buildHeader(context, invoiceReference),
              const SizedBox(height: 18),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReceivablePaymentBalancePanel(
                          invoiceReference: invoiceReference,
                          customerLabel: _customerLabel(),
                          outstandingAmount: widget.outstandingAmount,
                          currency: currency,
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentFields(),
                        const SizedBox(height: 12),
                        ReceivablePaymentMethodField(
                          method: _method,
                          enabled: !_isPosting,
                          onChanged: (value) => setState(() => _method = value),
                        ),
                        const SizedBox(height: 12),
                        ReceivablePaymentDateField(
                          paymentDate: _paymentDate,
                          onTap: _isPosting ? null : _pickPaymentDate,
                        ),
                        ClosedPeriodPostingNotice(
                          closeRecord: closeRecord,
                          actionLabel: 'post this customer payment',
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
                onConfirm: canPost ? _recordPayment : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String invoiceReference) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.account_balance_wallet_outlined,
          size: 44,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: 'Record Payment $invoiceReference',
            subtitle: _customerLabel(),
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
            if (amount - widget.outstandingAmount > 0.01) {
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
            hintText: 'Check number or transaction ID',
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

  String _customerLabel() {
    final customerId = widget.invoice.customerId;
    if (customerId != null && customerId.trim().isNotEmpty) {
      return 'Customer $customerId';
    }
    if (widget.invoice.description.trim().isNotEmpty) {
      return widget.invoice.description;
    }
    return 'AR cash receipt';
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

  void _recordPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPosting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final reference = _referenceController.text.trim();
    final payment = Payment(
      id: const Uuid().v4(),
      invoiceId: widget.invoice.id,
      paymentDate: _paymentDate,
      amount: double.parse(_amountController.text.trim()),
      reference: reference,
      referenceNumber: reference,
      method: _method,
    );

    var didClose = false;
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(_paymentDate, actionLabel: 'post customer payment');
      final posting = ref
          .read(receivablePaymentPostingServiceProvider)
          .postPayment(invoice: widget.invoice, payment: payment);

      ref.read(paymentsProvider.notifier).addPayment(payment);
      ref
          .read(invoicesProvider.notifier)
          .recordPayment(widget.invoice.id, payment);
      ref.read(postedLedgerProvider.notifier).addPosting(posting);

      didClose = true;
      navigator.pop(payment);
      messenger.showSnackBar(
        const SnackBar(content: Text('Payment posted to receivables')),
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
