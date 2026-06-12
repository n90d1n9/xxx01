import 'package:flutter/material.dart';

import '../models/billing_invoice_draft.dart';
import '../models/billing_tenant_account.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_invoice_issue_plan.dart';
import 'billing_invoice_issue_plan_preview.dart';

class BillingInvoiceCreateHeader extends StatelessWidget {
  final BillingTenantAccount tenant;

  const BillingInvoiceCreateHeader({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add_card_outlined, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Invoice',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tenant.name,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BillingInvoiceCreateActions extends StatelessWidget {
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  const BillingInvoiceCreateActions({
    super.key,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canSubmit ? onSubmit : null,
            icon:
                isSubmitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.receipt_long_outlined, size: 18),
            label: Text(isSubmitting ? 'Creating' : 'Create Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class BillingInvoiceDraftPreview extends StatelessWidget {
  final double? amount;
  final BillingTenantPreferences preferences;
  final DateTime issueDate;

  const BillingInvoiceDraftPreview({
    super.key,
    required this.amount,
    required this.preferences,
    required this.issueDate,
  });

  @override
  Widget build(BuildContext context) {
    final issuePlan = buildBillingInvoiceIssuePlan(
      BillingInvoiceDraft(
        tenantId: '_preview',
        amount: amount ?? 0,
        issueDate: issueDate,
        taxMode: billingInvoiceTaxModeFromTenantPreferences(preferences),
      ),
      preferences: preferences,
    );

    return BillingInvoiceIssuePlanPreview(
      issuePlan: issuePlan,
      preferences: preferences,
      showTotalPlaceholder: amount == null,
    );
  }
}
