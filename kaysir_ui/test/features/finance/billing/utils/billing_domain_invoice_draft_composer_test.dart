import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/utils/billing_domain_invoice_draft_composer.dart';

void main() {
  test('BillingDomainInvoiceDraftComposer composes module-backed drafts', () {
    final registry = BillingBusinessDomainModuleRegistry(
      modules: [
        BillingBusinessDomainModule(
          profile: BillingBusinessDomainProfile(
            domain: 'service',
            label: 'Service',
            defaultSourceType: 'work_order',
            taxRate: 0.1,
          ),
          lineItemAdapters: [_workOrderAdapter()],
          issuePolicy: BillingInvoiceIssuePolicy(
            domain: 'service',
            label: 'Service',
            taxMode: BillingInvoiceTaxMode.exclusive,
            paymentScheduleOptions:
                BillingPaymentScheduleOptions.upfrontAndBalance(
                  upfrontRatio: 0.25,
                ),
          ),
        ),
      ],
    );
    final composer = BillingDomainInvoiceDraftComposer(
      moduleRegistry: registry,
    );

    final composition = composer.prepareFromValues(
      tenantId: 'tenant-a',
      issueDate: DateTime(2026, 6, 1),
      domain: ' SERVICE ',
      values: const [_WorkOrder('wo-1', 'Repair visit', 240)],
    );
    final draft = composition.draft;

    expect(draft.amount, 264);
    expect(draft.taxMode, BillingInvoiceTaxMode.exclusive);
    expect(draft.lineItems.single.source?.domain, 'service');
    expect(draft.lineItems.single.source?.type, 'work_order');
    expect(composition.issuePolicy?.paymentScheduleOptions?.upfrontRatio, 0.25);
  });

  test('BillingDomainInvoiceDraftComposer can override module source type', () {
    final registry = BillingBusinessDomainModuleRegistry(
      modules: [
        BillingBusinessDomainModule(
          profile: BillingBusinessDomainProfile(
            domain: 'service',
            label: 'Service',
            defaultSourceType: 'work_order',
          ),
          lineItemAdapters: [_workOrderAdapter(), _siteVisitAdapter()],
        ),
      ],
    );
    final composer = BillingDomainInvoiceDraftComposer(
      moduleRegistry: registry,
    );

    final draft = composer.composeFromValues(
      tenantId: 'tenant-a',
      issueDate: DateTime(2026, 6, 1),
      domain: 'service',
      sourceType: 'site_visit',
      values: const [_SiteVisit('visit-1', 90, 2)],
    );

    expect(draft.amount, 180);
    expect(draft.lineItems.single.source?.type, 'site_visit');
    expect(draft.lineItems.single.unitLabel, 'hour');
  });

  test('BillingDomainInvoiceDraftComposer rejects missing module adapters', () {
    final composer = BillingDomainInvoiceDraftComposer(
      moduleRegistry: BillingBusinessDomainModuleRegistry(
        modules: [
          BillingBusinessDomainModule(
            profile: BillingBusinessDomainProfile(
              domain: 'service',
              label: 'Service',
              defaultSourceType: 'work_order',
            ),
          ),
        ],
      ),
    );

    expect(
      () => composer.composeFromValues(
        tenantId: 'tenant-a',
        issueDate: DateTime(2026, 6, 1),
        domain: 'service',
        values: const [_WorkOrder('wo-1', 'Repair visit', 240)],
      ),
      throwsStateError,
    );
  });
}

BillingInvoiceLineItemAdapter _workOrderAdapter() {
  return BillingInvoiceLineItemAdapter(
    domain: 'service',
    type: 'work_order',
    canAdapt: (value) => value is _WorkOrder,
    toLineItem: (value) {
      final workOrder = value as _WorkOrder;
      return BillingInvoiceLineItem(
        id: workOrder.id,
        description: workOrder.label,
        quantity: 1,
        unitPrice: workOrder.amount,
        unitLabel: 'job',
        taxRate: 0.1,
        source: BillingInvoiceLineItemSource(
          domain: 'service',
          type: 'work_order',
          id: workOrder.id,
        ),
      );
    },
  );
}

BillingInvoiceLineItemAdapter _siteVisitAdapter() {
  return BillingInvoiceLineItemAdapter(
    domain: 'service',
    type: 'site_visit',
    canAdapt: (value) => value is _SiteVisit,
    toLineItem: (value) {
      final visit = value as _SiteVisit;
      return BillingInvoiceLineItem(
        id: visit.id,
        description: 'Site visit ${visit.id}',
        quantity: visit.hours,
        unitPrice: visit.hourlyRate,
        unitLabel: 'hour',
        source: BillingInvoiceLineItemSource(
          domain: 'service',
          type: 'site_visit',
          id: visit.id,
        ),
      );
    },
  );
}

class _WorkOrder {
  final String id;
  final String label;
  final double amount;

  const _WorkOrder(this.id, this.label, this.amount);
}

class _SiteVisit {
  final String id;
  final double hourlyRate;
  final double hours;

  const _SiteVisit(this.id, this.hourlyRate, this.hours);
}
