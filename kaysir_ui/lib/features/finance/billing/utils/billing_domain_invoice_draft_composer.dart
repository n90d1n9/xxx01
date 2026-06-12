import '../models/billing_business_domain_module.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_policy.dart';
import '../models/billing_invoice_tax_mode.dart';
import 'billing_invoice_draft_composer.dart';

class BillingDomainInvoiceDraftComposition {
  final BillingBusinessDomainModule module;
  final BillingInvoiceDraft draft;

  const BillingDomainInvoiceDraftComposition({
    required this.module,
    required this.draft,
  });

  BillingInvoiceIssuePolicy? get issuePolicy => module.issuePolicy;
}

class BillingDomainInvoiceDraftComposer {
  final BillingBusinessDomainModuleRegistry moduleRegistry;

  const BillingDomainInvoiceDraftComposer({required this.moduleRegistry});

  BillingDomainInvoiceDraftComposition prepareFromValues({
    required String tenantId,
    required DateTime issueDate,
    required Iterable<Object> values,
    required String domain,
    String? sourceType,
    double amount = 0,
    BillingInvoiceTaxMode? taxMode,
  }) {
    final module = moduleRegistry.requireModule(domain);
    final draft = composeBillingInvoiceDraftFromValues(
      tenantId: tenantId,
      issueDate: issueDate,
      values: values,
      adapterRegistry: module.lineItemAdapterRegistry,
      amount: amount,
      profile: module.profile,
      sourceType: sourceType,
      taxMode: taxMode,
    );

    return BillingDomainInvoiceDraftComposition(module: module, draft: draft);
  }

  BillingInvoiceDraft composeFromValues({
    required String tenantId,
    required DateTime issueDate,
    required Iterable<Object> values,
    required String domain,
    String? sourceType,
    double amount = 0,
    BillingInvoiceTaxMode? taxMode,
  }) {
    return prepareFromValues(
      tenantId: tenantId,
      issueDate: issueDate,
      values: values,
      domain: domain,
      sourceType: sourceType,
      amount: amount,
      taxMode: taxMode,
    ).draft;
  }
}
