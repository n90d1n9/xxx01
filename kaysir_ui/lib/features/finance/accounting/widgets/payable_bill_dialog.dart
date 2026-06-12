import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';
import 'package:uuid/uuid.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../models/invoice.dart';
import '../models/vendor.dart';
import '../states/accounting_core_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/invoice_provider.dart';
import '../states/vendor_provider.dart';
import 'closed_period_posting_notice.dart';
import 'payable_bill_components.dart';

class PayableBillDialog extends ConsumerStatefulWidget {
  const PayableBillDialog({super.key});

  @override
  ConsumerState<PayableBillDialog> createState() => _PayableBillDialogState();
}

class _PayableBillDialogState extends ConsumerState<PayableBillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedVendorId;
  String? _selectedExpenseAccountId;
  DateTime _invoiceDate = DateTime.now();
  late DateTime _dueDate;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _dueDate = _invoiceDate.add(const Duration(days: 30));
    _invoiceNumberController.text =
        'BILL-${DateFormat('yyyyMMdd-HHmm').format(_invoiceDate)}';
    _amountController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _amountController.removeListener(_refreshPreview);
    _invoiceNumberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);
    final expenseAccounts =
        ref
            .watch(accountingChartProvider)
            .where((account) => account.type == AccountingAccountType.expense)
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code));
    _ensureSelections(vendors, expenseAccounts);

    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final selectedExpenseAccount = _findExpenseAccount(expenseAccounts);
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(_invoiceDate);
    final hasRequiredSetup = vendors.isNotEmpty && expenseAccounts.isNotEmpty;
    final canPost = hasRequiredSetup && !_isPosting && closeRecord == null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              if (!hasRequiredSetup)
                Expanded(child: _buildSetupEmptyState(vendors, expenseAccounts))
              else
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSelectionFields(vendors, expenseAccounts),
                          const SizedBox(height: 12),
                          _buildBillFields(),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            enabled: !_isPosting,
                            decoration: _inputDecoration(
                              context,
                              label: 'Description',
                              icon: Icons.notes_outlined,
                            ),
                            minLines: 2,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          _buildDateFields(),
                          const SizedBox(height: 16),
                          _buildPostingPreview(
                            currency,
                            selectedExpenseAccount,
                          ),
                          ClosedPeriodPostingNotice(
                            closeRecord: closeRecord,
                            actionLabel: 'post this bill',
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
                confirmLabel: _isPosting ? 'Posting...' : 'Post Bill',
                confirmIcon:
                    _isPosting
                        ? Icons.hourglass_top_rounded
                        : Icons.receipt_long_outlined,
                confirmVariant: AppActionButtonVariant.primary,
                onConfirm: canPost ? _postBill : null,
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
          icon: Icons.receipt_long_outlined,
          size: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: 'Post Vendor Bill',
            subtitle: 'AP liability and expense recognition',
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

  Widget _buildSetupEmptyState(
    List<Vendor> vendors,
    List<AccountingAccount> expenseAccounts,
  ) {
    final missingLabels = [
      if (vendors.isEmpty) 'vendor records',
      if (expenseAccounts.isEmpty) 'expense accounts',
    ].join(' and ');

    return AppEmptyState(
      icon: Icons.rule_folder_outlined,
      title: 'Bill setup incomplete',
      message: 'Configure $missingLabels before posting vendor bills.',
    );
  }

  Widget _buildSelectionFields(
    List<Vendor> vendors,
    List<AccountingAccount> expenseAccounts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vendorField = AppSelectField<String>(
          label: 'Vendor',
          value: _selectedVendorId!,
          icon: Icons.storefront_outlined,
          enabled: !_isPosting,
          options: [
            for (final vendor in vendors)
              AppSelectOption(value: vendor.id, label: vendor.name),
          ],
          onChanged:
              (value) => setState(() {
                _selectedVendorId = value;
              }),
        );
        final accountField = AppSelectField<String>(
          label: 'Expense Account',
          value: _selectedExpenseAccountId!,
          icon: Icons.category_outlined,
          enabled: !_isPosting,
          menuMaxHeight: 280,
          options: [
            for (final account in expenseAccounts)
              AppSelectOption(
                value: account.id,
                label: '${account.code} - ${account.name}',
              ),
          ],
          onChanged:
              (value) => setState(() {
                _selectedExpenseAccountId = value;
              }),
        );

        if (constraints.maxWidth < 560) {
          return Column(
            children: [vendorField, const SizedBox(height: 12), accountField],
          );
        }

        return Row(
          children: [
            Expanded(child: vendorField),
            const SizedBox(width: 12),
            Expanded(child: accountField),
          ],
        );
      },
    );
  }

  Widget _buildBillFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final numberField = TextFormField(
          controller: _invoiceNumberController,
          enabled: !_isPosting,
          decoration: _inputDecoration(
            context,
            label: 'Bill Number',
            icon: Icons.tag_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a bill number';
            }
            return null;
          },
        );
        final amountField = TextFormField(
          controller: _amountController,
          enabled: !_isPosting,
          decoration: _inputDecoration(
            context,
            label: 'Amount',
            icon: Icons.attach_money_rounded,
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value.trim());
            if (amount == null) {
              return 'Please enter a valid number';
            }
            if (amount <= 0) {
              return 'Amount must be greater than zero';
            }
            return null;
          },
        );

        if (constraints.maxWidth < 560) {
          return Column(
            children: [numberField, const SizedBox(height: 12), amountField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: numberField),
            const SizedBox(width: 12),
            Expanded(child: amountField),
          ],
        );
      },
    );
  }

  Widget _buildDateFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final billDateTile = PayableBillDateField(
          label: 'Bill Date',
          date: _invoiceDate,
          onTap: _isPosting ? null : _pickInvoiceDate,
        );
        final dueDateTile = PayableBillDateField(
          label: 'Due Date',
          date: _dueDate,
          onTap: _isPosting ? null : _pickDueDate,
        );

        if (constraints.maxWidth < 420) {
          return Column(
            children: [billDateTile, const SizedBox(height: 12), dueDateTile],
          );
        }

        return Row(
          children: [
            Expanded(child: billDateTile),
            const SizedBox(width: 12),
            Expanded(child: dueDateTile),
          ],
        );
      },
    );
  }

  Widget _buildPostingPreview(
    NumberFormat currency,
    AccountingAccount? expenseAccount,
  ) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final debitAccount = expenseAccount?.name ?? 'Selected expense account';

    return PayableBillJournalPreview(
      debitAccountName: debitAccount,
      creditAccountName: 'Accounts Payable',
      amount: amount,
      currency: currency,
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? prefixText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon, size: 18),
      prefixText: prefixText,
      filled: true,
      fillColor: colorScheme.surface,
      border: border,
      enabledBorder: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _ensureSelections(
    List<Vendor> vendors,
    List<AccountingAccount> expenseAccounts,
  ) {
    if (!vendors.any((vendor) => vendor.id == _selectedVendorId)) {
      _selectedVendorId = vendors.isEmpty ? null : vendors.first.id;
    }
    if (!expenseAccounts.any(
      (account) => account.id == _selectedExpenseAccountId,
    )) {
      _selectedExpenseAccountId =
          expenseAccounts.isEmpty ? null : expenseAccounts.first.id;
    }
  }

  AccountingAccount? _findExpenseAccount(List<AccountingAccount> accounts) {
    for (final account in accounts) {
      if (account.id == _selectedExpenseAccountId) {
        return account;
      }
    }
    return null;
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickInvoiceDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) {
      return;
    }

    setState(() {
      final previousTerm = _dueDate.difference(_invoiceDate);
      _invoiceDate = date;
      _dueDate = date.add(previousTerm);
    });
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _invoiceDate,
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) {
      return;
    }
    setState(() => _dueDate = date);
  }

  void _postBill() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final expenseAccount = _findExpenseAccount(
      ref
          .read(accountingChartProvider)
          .where((account) => account.type == AccountingAccountType.expense)
          .toList(),
    );
    final selectedVendor = _findVendor(ref.read(vendorsProvider));
    if (expenseAccount == null || selectedVendor == null) {
      _showPostingError('Vendor and expense account are required');
      return;
    }

    setState(() => _isPosting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final description = _descriptionController.text.trim();
    final bill = Invoice(
      id: const Uuid().v4(),
      vendorId: selectedVendor.id,
      vendorName: selectedVendor.name,
      invoiceNumber: _invoiceNumberController.text.trim(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      amount: double.parse(_amountController.text.trim()),
      description: description,
      status: InvoiceStatus.pending,
      payments: const [],
      expenseAccountId: expenseAccount.id,
    );

    var didClose = false;
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(_invoiceDate, actionLabel: 'post vendor bill');
      final posting = ref
          .read(payablePostingServiceProvider)
          .postBill(bill, expenseAccount: expenseAccount);
      ref.read(invoicesProvider.notifier).addInvoice(bill);
      ref.read(postedLedgerProvider.notifier).addPosting(posting);

      didClose = true;
      navigator.pop(bill);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Bill posted to ${expenseAccount.name} and payables'),
        ),
      );
    } on LedgerPostingException catch (error) {
      _showPostingError(error.issues.join('\n'));
    } on ArgumentError catch (error) {
      _showPostingError(error.message?.toString() ?? 'Invalid bill');
    } on StateError catch (error) {
      _showPostingError(error.message);
    } finally {
      if (mounted && !didClose) {
        setState(() => _isPosting = false);
      }
    }
  }

  Vendor? _findVendor(List<Vendor> vendors) {
    for (final vendor in vendors) {
      if (vendor.id == _selectedVendorId) {
        return vendor;
      }
    }
    return null;
  }

  void _showPostingError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }
}
