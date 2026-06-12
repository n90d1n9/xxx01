import 'package:flutter/material.dart';

import '../models/billing_checkout.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';

Future<void> showBillingCheckoutReceiptSheet(
  BuildContext context, {
  required BillingCheckoutReceipt receipt,
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: BillingCheckoutReceiptPanel(
          receipt: receipt,
          preferences: preferences,
        ),
      );
    },
  );
}

class BillingCheckoutReceiptPanel extends StatelessWidget {
  final BillingCheckoutReceipt receipt;
  final BillingTenantPreferences preferences;

  const BillingCheckoutReceiptPanel({
    super.key,
    required this.receipt,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context) {
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Complete',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Receipt is ready for this checkout.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ReceiptFact(label: 'Receipt ID', value: receipt.id),
          _ReceiptFact(label: 'Tenant', value: receipt.tenantName),
          _ReceiptFact(
            label: 'Date',
            value: formatBillingDate(
              receipt.createdAt,
              preferences: preferences,
            ),
          ),
          _ReceiptFact(label: 'Items', value: '${receipt.itemCount}'),
          _ReceiptFact(
            label: 'Total',
            value: formatBillingCurrency(
              receipt.total,
              preferences: preferences,
            ),
            emphasized: true,
          ),
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

class _ReceiptFact extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _ReceiptFact({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    emphasized
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF1E293B),
                fontSize: emphasized ? 18 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
