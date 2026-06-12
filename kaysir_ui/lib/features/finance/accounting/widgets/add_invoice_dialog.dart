import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';
import 'package:uuid/uuid.dart';

import '../models/customer.dart';
import '../models/invoice.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/invoice_provider.dart';
import 'closed_period_posting_notice.dart';
import 'receivable_invoice_components.dart';

class AddInvoiceDialog extends ConsumerStatefulWidget {
  final List<Customer> customers;

  const AddInvoiceDialog({required this.customers, super.key});

  @override
  ConsumerState<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends ConsumerState<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCustomerId;
  DateTime _issueDate = DateTime.now();
  late DateTime _dueDate;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _dueDate = _issueDate.add(const Duration(days: 30));
    _referenceController.text =
        'INV-${DateFormat('yyyyMMdd-HHmm').format(_issueDate)}';
    _amountController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _amountController.removeListener(_refreshPreview);
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureCustomerSelection();

    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final selectedCustomer = _selectedCustomer();
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(_issueDate);
    final hasCustomers = widget.customers.isNotEmpty;
    final canCreate = hasCustomers && !_isCreating && closeRecord == null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              if (!hasCustomers)
                const Expanded(
                  child: AppEmptyState(
                    icon: Icons.people_outline,
                    title: 'Customer setup incomplete',
                    message:
                        'Add a customer record before creating receivable invoices.',
                  ),
                )
              else
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReceivableInvoiceCustomerField(
                            customers: widget.customers,
                            selectedCustomerId: _selectedCustomerId!,
                            enabled: !_isCreating,
                            onChanged:
                                (value) => setState(() {
                                  _selectedCustomerId = value;
                                }),
                          ),
                          const SizedBox(height: 12),
                          ReceivableInvoiceDetailsFields(
                            referenceController: _referenceController,
                            amountController: _amountController,
                            enabled: !_isCreating,
                          ),
                          const SizedBox(height: 12),
                          ReceivableInvoiceDateFields(
                            issueDate: _issueDate,
                            dueDate: _dueDate,
                            onPickIssueDate: _pickIssueDate,
                            onPickDueDate: _pickDueDate,
                            enabled: !_isCreating,
                          ),
                          const SizedBox(height: 16),
                          ReceivableInvoicePreviewPanel(
                            customerName:
                                selectedCustomer?.name ?? 'Selected customer',
                            reference: _referenceController.text.trim(),
                            amount:
                                double.tryParse(
                                  _amountController.text.trim(),
                                ) ??
                                0,
                            issueDate: _issueDate,
                            dueDate: _dueDate,
                            currency: currency,
                          ),
                          ClosedPeriodPostingNotice(
                            closeRecord: closeRecord,
                            actionLabel: 'create this customer invoice',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              AppDialogActions(
                cancelLabel: 'Cancel',
                onCancel:
                    _isCreating ? null : () => Navigator.of(context).pop(),
                confirmLabel: _isCreating ? 'Creating...' : 'Create Invoice',
                confirmIcon:
                    _isCreating
                        ? Icons.hourglass_top_rounded
                        : Icons.add_card_outlined,
                confirmVariant: AppActionButtonVariant.primary,
                onConfirm: canCreate ? _createInvoice : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.request_quote_outlined,
          size: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: 'Create Customer Invoice',
            subtitle: 'AR billing, due date, and collection setup',
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

  void _ensureCustomerSelection() {
    if (widget.customers.any(
      (customer) => customer.id == _selectedCustomerId,
    )) {
      return;
    }
    _selectedCustomerId =
        widget.customers.isEmpty ? null : widget.customers.first.id;
  }

  Customer? _selectedCustomer() {
    for (final customer in widget.customers) {
      if (customer.id == _selectedCustomerId) {
        return customer;
      }
    }
    return null;
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickIssueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) {
      return;
    }

    setState(() {
      final previousTerm = _dueDate.difference(_issueDate);
      _issueDate = date;
      _dueDate = date.add(previousTerm);
    });
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _issueDate,
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) {
      return;
    }
    setState(() => _dueDate = date);
  }

  void _createInvoice() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customer = _selectedCustomer();
    if (customer == null) {
      _showCreationError('Customer is required');
      return;
    }

    setState(() => _isCreating = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final invoice = Invoice(
      id: const Uuid().v4(),
      customerId: customer.id,
      issueDate: _issueDate,
      dueDate: _dueDate,
      amount: double.parse(_amountController.text.trim()),
      reference: _referenceController.text.trim(),
      status: InvoiceStatus.outstanding,
    );

    var didClose = false;
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(_issueDate, actionLabel: 'create customer invoice');
      ref.read(invoicesProvider.notifier).addInvoice(invoice);

      didClose = true;
      navigator.pop(invoice);
      messenger.showSnackBar(
        SnackBar(content: Text('Invoice created for ${customer.name}')),
      );
    } on StateError catch (error) {
      _showCreationError(error.message);
    } finally {
      if (mounted && !didClose) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showCreationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }
}
