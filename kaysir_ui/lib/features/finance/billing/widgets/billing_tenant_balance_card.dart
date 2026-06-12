import 'package:flutter/material.dart';

import '../models/billing_tenant_account.dart';
import '../utils/billing_formatters.dart';
import 'billing_tenant_avatar.dart';

class BillingTenantBalanceCard extends StatelessWidget {
  final BillingTenantAccount tenant;
  final VoidCallback? onPayNow;
  final VoidCallback? onViewInvoices;

  const BillingTenantBalanceCard({
    super.key,
    required this.tenant,
    this.onPayNow,
    this.onViewInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tenant.planName} Plan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  BillingTenantAvatar(
                    name: tenant.name,
                    logoUrl: tenant.logoUrl,
                    radius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatBillingCurrency(
                  tenant.currentBalance,
                  preferences: tenant.preferences,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _payNowButton(),
                      const SizedBox(height: 10),
                      _invoiceHistoryButton(),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: _payNowButton()),
                      const SizedBox(width: 12),
                      _invoiceHistoryButton(),
                    ],
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _payNowButton() {
    return ElevatedButton.icon(
      onPressed: onPayNow,
      icon: const Icon(Icons.payments_outlined, size: 18),
      label: const Text('Pay Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4F46E5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _invoiceHistoryButton() {
    return OutlinedButton.icon(
      onPressed: onViewInvoices,
      icon: const Icon(Icons.receipt_long_outlined, size: 18),
      label: const Text('Invoice History'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
