import 'package:flutter/material.dart';

import '../models/billing_tenant_account.dart';
import 'billing_tenant_balance_card.dart';
import 'billing_tenant_selector.dart';

class BillingDashboardHeaderSection extends StatelessWidget {
  final List<BillingTenantAccount> tenants;
  final BillingTenantAccount selectedTenant;
  final ValueChanged<String> onTenantChanged;
  final VoidCallback? onPayNow;
  final VoidCallback? onViewInvoices;

  const BillingDashboardHeaderSection({
    super.key,
    required this.tenants,
    required this.selectedTenant,
    required this.onTenantChanged,
    this.onPayNow,
    this.onViewInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BillingTenantSelector(
            tenants: tenants,
            selectedTenant: selectedTenant,
            onTenantChanged: onTenantChanged,
          ),
          const SizedBox(height: 16),
          BillingTenantBalanceCard(
            tenant: selectedTenant,
            onPayNow: onPayNow,
            onViewInvoices: onViewInvoices,
          ),
          const SizedBox(height: 24),
          const Text(
            'Billing Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
