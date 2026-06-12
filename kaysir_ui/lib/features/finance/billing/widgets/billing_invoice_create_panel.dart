import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/billing_invoice.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_plan.dart';
import '../models/billing_tenant_account.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';
import '../utils/billing_invoice_issue_plan.dart';
import 'billing_invoice_create_components.dart';
import 'billing_invoice_issue_plan_preview.dart';

class BillingInvoiceCreatePanel extends StatefulWidget {
  final BillingTenantAccount tenant;
  final DateTime? initialDate;
  final Future<BillingInvoice> Function(BillingInvoiceDraft draft) onCreate;
  final ValueChanged<BillingInvoice>? onCreated;
  final VoidCallback? onCancel;

  const BillingInvoiceCreatePanel({
    super.key,
    required this.tenant,
    required this.onCreate,
    this.initialDate,
    this.onCreated,
    this.onCancel,
  });

  @override
  State<BillingInvoiceCreatePanel> createState() =>
      _BillingInvoiceCreatePanelState();
}

class _BillingInvoiceCreatePanelState extends State<BillingInvoiceCreatePanel> {
  final _amountController = TextEditingController();
  late DateTime _issueDate;
  bool _isSubmitting = false;
  String? _errorText;

  BillingTenantPreferences get _preferences => widget.tenant.preferences;

  double? get _amount {
    final value = _amountController.text.trim().replaceAll(',', '');
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  BillingInvoiceDraft get _draft {
    return BillingInvoiceDraft(
      tenantId: widget.tenant.id,
      amount: _amount ?? 0,
      issueDate: _issueDate,
      taxMode: billingInvoiceTaxModeFromTenantPreferences(_preferences),
    );
  }

  BillingInvoiceIssuePlan get _issuePlan {
    return buildBillingInvoiceIssuePlan(_draft, preferences: _preferences);
  }

  bool get _canSubmit =>
      !_isSubmitting && _amount != null && _issuePlan.canIssue;

  @override
  void initState() {
    super.initState();
    _issueDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    final issuePlan = _issuePlan;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            BillingInvoiceCreateHeader(tenant: widget.tenant),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged:
                  (_) => setState(() {
                    _errorText = null;
                  }),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: _preferences.currencySymbol,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickIssueDate,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                'Issue date ${formatBillingDate(_issueDate, preferences: _preferences)}',
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            BillingInvoiceIssuePlanPreview(
              issuePlan: issuePlan,
              preferences: _preferences,
              showTotalPlaceholder: amount == null,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            BillingInvoiceCreateActions(
              isSubmitting: _isSubmitting,
              canSubmit: _canSubmit,
              onCancel: widget.onCancel,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIssueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    setState(() {
      _issueDate = pickedDate;
    });
  }

  Future<void> _submit() async {
    final draft = _draft;
    final issuePlan = buildBillingInvoiceIssuePlan(
      draft,
      preferences: _preferences,
    );
    final errors = issuePlan.validationErrors;
    if (errors.isNotEmpty) {
      setState(() {
        _errorText = errors.first;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final invoice = await widget.onCreate(draft);
      if (!mounted) return;
      widget.onCreated?.call(invoice);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
