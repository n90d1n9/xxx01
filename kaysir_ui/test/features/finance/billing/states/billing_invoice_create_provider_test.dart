import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_create_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_profile_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_create_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_issue_outbox_provider.dart';

void main() {
  test('createInvoice submits draft and stores created invoice', () async {
    final repository = _FakeBillingInvoiceCreateRepository();
    final outboxRepository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 10),
    );
    final container = _container(
      repository,
      outboxRepository: outboxRepository,
    );
    addTearDown(container.dispose);
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 2500,
      issueDate: DateTime(2026, 5, 31),
    );

    final invoice = await container
        .read(billingInvoiceCreateControllerProvider.notifier)
        .createInvoice(draft);

    expect(repository.drafts, [draft]);
    expect(repository.issueCommands.single?.tenantId, 'tenant-a');
    expect(invoice.id, 'inv-created');
    expect(invoice.status, BillingInvoiceStatus.pending);
    expect(
      container.read(billingInvoiceCreateControllerProvider).requireValue?.id,
      'inv-created',
    );
    expect(
      container
          .read(locallyCreatedBillingInvoicesProvider('tenant-a'))
          .map((invoice) => invoice.id),
      ['inv-created'],
    );
    final entries = await outboxRepository.fetchEntries(tenantId: 'tenant-a');
    expect(entries, hasLength(1));
    expect(entries.single.status, BillingInvoiceIssueOutboxStatus.synced);
    expect(entries.single.remoteInvoiceId, 'inv-created');
    expect(entries.single.attemptCount, 1);
  });

  test('createInvoice rejects invalid drafts before repository submission', () {
    final repository = _FakeBillingInvoiceCreateRepository();
    final outboxRepository = InMemoryBillingInvoiceIssueOutboxRepository();
    final container = _container(
      repository,
      outboxRepository: outboxRepository,
    );
    addTearDown(container.dispose);

    expect(
      container
          .read(billingInvoiceCreateControllerProvider.notifier)
          .createInvoice(
            BillingInvoiceDraft(
              tenantId: '',
              amount: 0,
              issueDate: DateTime(2026, 5, 31),
            ),
          ),
      throwsStateError,
    );
    expect(repository.drafts, isEmpty);
    expect(outboxRepository.fetchEntries(), completion(isEmpty));
  });

  test('createInvoice marks outbox failures for retry', () async {
    final repository = _FakeBillingInvoiceCreateRepository(
      error: StateError('offline'),
    );
    final outboxRepository = InMemoryBillingInvoiceIssueOutboxRepository(
      clock: () => DateTime(2026, 5, 31, 10),
    );
    final container = _container(
      repository,
      outboxRepository: outboxRepository,
    );
    addTearDown(container.dispose);
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 2500,
      issueDate: DateTime(2026, 5, 31),
    );

    await expectLater(
      container
          .read(billingInvoiceCreateControllerProvider.notifier)
          .createInvoice(draft),
      throwsStateError,
    );

    final entries = await outboxRepository.fetchEntries(tenantId: 'tenant-a');
    expect(repository.issueCommands.single?.tenantId, 'tenant-a');
    expect(entries, hasLength(1));
    expect(entries.single.status, BillingInvoiceIssueOutboxStatus.failed);
    expect(entries.single.canRetry, isTrue);
    expect(entries.single.lastError, contains('offline'));
    expect(entries.single.attemptCount, 1);
    expect(
      container.read(billingInvoiceCreateControllerProvider).hasError,
      isTrue,
    );
  });

  test(
    'createInvoiceFromDomainValues builds drafts from domain modules',
    () async {
      final repository = _FakeBillingInvoiceCreateRepository();
      final outboxRepository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 6, 1, 10),
      );
      final serviceModule = BillingBusinessDomainModule(
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
      );
      final container = _container(
        repository,
        outboxRepository: outboxRepository,
        moduleRegistry: BillingBusinessDomainModuleRegistry(
          modules: [serviceModule],
        ),
      );
      addTearDown(container.dispose);

      final invoice = await container
          .read(billingInvoiceCreateControllerProvider.notifier)
          .createInvoiceFromDomainValues(
            tenantId: 'tenant-a',
            issueDate: DateTime(2026, 6, 1),
            domain: 'service',
            values: const [_WorkOrder('wo-1', 'Repair visit', 240)],
          );

      expect(invoice.amount, 264);
      expect(repository.drafts.single.amount, 264);
      expect(
        repository.drafts.single.lineItems.single.source?.domain,
        'service',
      );
      expect(
        repository.drafts.single.lineItems.single.source?.type,
        'work_order',
      );
      expect(
        repository.issueCommands.single?.issuePlan.paymentSchedule.strategy,
        BillingPaymentScheduleStrategy.upfrontAndBalance,
      );
      expect(
        repository
            .issueCommands
            .single
            ?.issuePlan
            .paymentSchedule
            .items
            .first
            .amount,
        closeTo(66, 0.001),
      );
      expect(
        repository.issueCommands.single?.draft.lineItems.single.source?.domain,
        'service',
      );
      final entries = await outboxRepository.fetchEntries(tenantId: 'tenant-a');
      expect(entries.single.status, BillingInvoiceIssueOutboxStatus.synced);
    },
  );
}

ProviderContainer _container(
  BillingInvoiceCreateRepository repository, {
  BillingInvoiceIssueOutboxRepository? outboxRepository,
  BillingBusinessDomainModuleRegistry? moduleRegistry,
}) {
  return ProviderContainer(
    overrides: [
      billingInvoiceCreateRepositoryProvider.overrideWithValue(repository),
      if (moduleRegistry != null)
        billingBusinessDomainModuleRegistryProvider.overrideWithValue(
          moduleRegistry,
        ),
      if (outboxRepository != null)
        billingInvoiceIssueOutboxRepositoryProvider.overrideWithValue(
          outboxRepository,
        ),
    ],
  );
}

class _FakeBillingInvoiceCreateRepository
    implements BillingInvoiceCreateRepository {
  final drafts = <BillingInvoiceDraft>[];
  final issueCommands = <BillingInvoiceIssueCommand?>[];
  final Object? error;

  _FakeBillingInvoiceCreateRepository({this.error});

  @override
  Future<BillingInvoice> createInvoice(
    BillingInvoiceDraft draft, {
    BillingInvoiceIssueCommand? issueCommand,
  }) async {
    drafts.add(draft);
    issueCommands.add(issueCommand);
    final resolvedError = error;
    if (resolvedError != null) {
      throw resolvedError;
    }

    return BillingInvoice(
      id: 'inv-created',
      tenantId: draft.tenantId,
      amount: draft.amount,
      date: draft.issueDate,
      status: BillingInvoiceStatus.pending,
    );
  }
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

class _WorkOrder {
  final String id;
  final String label;
  final double amount;

  const _WorkOrder(this.id, this.label, this.amount);
}
