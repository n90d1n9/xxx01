import 'package:flutter/material.dart';

import '../models/billing_invoice_action.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';
import 'billing_invoice_action_bar.dart';

Future<void> showBillingInvoiceActionResultSheet(
  BuildContext context, {
  required BillingInvoiceActionResult result,
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  String? tenantName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return BillingInvoiceActionResultPanel(
        result: result,
        preferences: preferences,
        tenantName: tenantName,
      );
    },
  );
}

class BillingInvoiceActionResultPanel extends StatelessWidget {
  final BillingInvoiceActionResult result;
  final BillingTenantPreferences preferences;
  final String? tenantName;

  const BillingInvoiceActionResultPanel({
    super.key,
    required this.result,
    this.preferences = const BillingTenantPreferences(),
    this.tenantName,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(result.type);

    return Padding(
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
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tone.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tone.icon, color: tone.foregroundColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tone.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tone.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              result.message,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ActionResultFact(label: 'Invoice', value: result.invoiceId),
          if (tenantName != null && tenantName!.trim().isNotEmpty)
            _ActionResultFact(label: 'Tenant', value: tenantName!),
          _ActionResultFact(
            label: 'Completed',
            value: formatBillingDate(
              result.completedAt,
              preferences: preferences,
            ),
          ),
          _ActionResultFact(label: 'Next step', value: tone.nextStep),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Done'),
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
      ),
    );
  }
}

class _ActionResultFact extends StatelessWidget {
  final String label;
  final String value;

  const _ActionResultFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionResultTone {
  final String title;
  final String subtitle;
  final String nextStep;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  const _ActionResultTone({
    required this.title,
    required this.subtitle,
    required this.nextStep,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });
}

_ActionResultTone _toneFor(BillingInvoiceActionType type) {
  switch (type) {
    case BillingInvoiceActionType.collectPayment:
      return _ActionResultTone(
        title: 'Payment Collection Started',
        subtitle: 'The receivable workflow is now moving.',
        nextStep: 'Review settlement, then reconcile when funds arrive.',
        icon: billingInvoiceActionIcon(type),
        foregroundColor: const Color(0xFF2563EB),
        backgroundColor: const Color(0xFFDBEAFE),
      );
    case BillingInvoiceActionType.sendReminder:
      return _ActionResultTone(
        title: 'Reminder Queued',
        subtitle: 'The customer follow-up is ready.',
        nextStep: 'Monitor replies and follow up if the balance stays open.',
        icon: billingInvoiceActionIcon(type),
        foregroundColor: const Color(0xFFD97706),
        backgroundColor: const Color(0xFFFEF3C7),
      );
    case BillingInvoiceActionType.download:
      return _ActionResultTone(
        title: 'Invoice Ready',
        subtitle: 'The document can be shared or archived.',
        nextStep: 'Share or archive the invoice with the related order file.',
        icon: billingInvoiceActionIcon(type),
        foregroundColor: const Color(0xFF059669),
        backgroundColor: const Color(0xFFD1FAE5),
      );
  }
}
