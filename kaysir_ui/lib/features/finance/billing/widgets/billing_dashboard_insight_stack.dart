import 'package:flutter/material.dart';

import '../models/billing_cash_forecast.dart';
import '../models/billing_collection_task.dart';
import '../models/billing_invoice_aging_bucket.dart';
import '../models/billing_invoice_attention.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_business_domain_module_readiness.dart';
import 'billing_cash_forecast_section.dart';
import 'billing_collection_worklist_section.dart';
import 'billing_domain_module_readiness_panel.dart';
import 'billing_invoice_aging_bucket_section.dart';
import 'billing_invoice_attention_section.dart';
import 'billing_invoice_issue_outbox_health_panel.dart';

class BillingDashboardInsightStack extends StatelessWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final ValueChanged<BillingCashForecastBucket>? onCashForecastBucketSelected;
  final ValueChanged<BillingInvoiceAttentionItem>? onAttentionItemSelected;
  final ValueChanged<BillingInvoiceAgingBucket>? onAgingBucketSelected;
  final ValueChanged<BillingCollectionTask>? onCollectionTaskSelected;
  final VoidCallback? onIssueOutboxInspect;
  final BillingDomainModuleReadinessReport? readinessReport;

  const BillingDashboardInsightStack({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.onCashForecastBucketSelected,
    this.onAttentionItemSelected,
    this.onAgingBucketSelected,
    this.onCollectionTaskSelected,
    this.onIssueOutboxInspect,
    this.readinessReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (readinessReport != null)
          BillingDomainModuleReadinessPanel(report: readinessReport!),
        BillingInvoiceIssueOutboxHealthSection(
          tenantId: tenantId,
          onInspect: onIssueOutboxInspect,
        ),
        BillingCashForecastSection(
          tenantId: tenantId,
          preferences: preferences,
          onBucketSelected: onCashForecastBucketSelected,
        ),
        BillingInvoiceAttentionSection(
          tenantId: tenantId,
          preferences: preferences,
          onItemSelected: onAttentionItemSelected,
        ),
        BillingInvoiceAgingBucketSection(
          tenantId: tenantId,
          preferences: preferences,
          onBucketSelected: onAgingBucketSelected,
        ),
        BillingCollectionWorklistSection(
          tenantId: tenantId,
          preferences: preferences,
          onTaskSelected: onCollectionTaskSelected,
        ),
      ],
    );
  }
}
