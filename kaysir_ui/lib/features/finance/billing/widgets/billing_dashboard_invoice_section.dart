import 'package:flutter/material.dart';

import '../models/billing_invoice.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_invoice_filter_bar.dart';
import 'billing_invoice_sliver_list.dart';

class BillingDashboardInvoiceSection extends StatelessWidget {
  final Key? sectionKey;
  final String tenantId;
  final BillingTenantPreferences preferences;
  final ValueChanged<BillingInvoice>? onInvoiceTap;

  const BillingDashboardInvoiceSection({
    super.key,
    this.sectionKey,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: sectionKey,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Invoices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: BillingInvoiceFilterBar(tenantId: tenantId)),
        BillingInvoiceSliverList(
          tenantId: tenantId,
          preferences: preferences,
          onInvoiceTap: onInvoiceTap,
        ),
      ],
    );
  }
}
