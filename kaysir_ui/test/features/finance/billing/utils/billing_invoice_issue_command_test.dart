import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_policies.dart';

void main() {
  test('buildBillingInvoiceIssueCommand creates retry-safe issue metadata', () {
    final requestedAt = DateTime(2026, 5, 31, 10, 30);
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 750,
      issueDate: DateTime(2026, 5, 31),
    );

    final command = buildBillingInvoiceIssueCommand(
      draft,
      requestedAt: requestedAt,
      channel: 'pos',
      attributes: const {'terminalId': 'front-counter'},
    );
    final fingerprint = billingInvoiceDraftFingerprint(draft);

    expect(
      command.idempotencyKey,
      billingInvoiceIssueCommandKey(
        draft,
        requestedAt: requestedAt,
        channel: 'pos',
      ),
    );
    expect(command.draftFingerprint, fingerprint);
    expect(command.channel, 'pos');
    expect(command.tenantId, 'tenant-a');
    expect(command.total, 750);
    expect(command.canIssue, isTrue);
    expect(command.attributes, {'terminalId': 'front-counter'});
    expect(
      () => command.attributes['terminalId'] = 'back-counter',
      throwsUnsupportedError,
    );
  });

  test('BillingInvoiceIssueCommand exposes immutable API payload snapshot', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
      lineItems: [
        BillingInvoiceLineItem(
          id: 'seat-line',
          description: 'Subscription seats',
          quantity: 2,
          unitPrice: 300,
          discountAmount: 50,
          taxRate: 0.1,
          source: BillingInvoiceLineItemSource(
            domain: 'saas',
            type: 'subscription',
            id: 'sub-1',
            attributes: const {'plan': 'growth'},
          ),
        ),
      ],
    );
    final command = buildBillingInvoiceIssueCommand(
      draft,
      requestedAt: DateTime(2026, 5, 31, 10, 30),
      channel: 'pos',
      attributes: const {'terminalId': 'front-counter'},
    );

    final payload = command.toPayload();

    expect(payload['idempotencyKey'], command.idempotencyKey);
    expect(payload['draftFingerprint'], command.draftFingerprint);
    expect(payload['tenantId'], 'tenant-a');
    expect(payload['channel'], 'pos');
    expect(payload['lineCount'], 1);
    expect(payload['total'], 605);
    expect(payload['attributes'], {'terminalId': 'front-counter'});
    final paymentSchedule = payload['paymentSchedule'] as Map<String, Object?>;
    expect(paymentSchedule['strategy'], 'singleDueDate');
    expect(paymentSchedule['paymentCount'], 1);
    final lineItems = payload['lineItems'] as List<Map<String, Object?>>;
    expect(lineItems, hasLength(1));
    expect(lineItems.single['id'], 'seat-line');
    expect(lineItems.single['netSubtotal'], 550);
    expect(lineItems.single['source'], {
      'domain': 'saas',
      'type': 'subscription',
      'id': 'sub-1',
      'attributes': {'plan': 'growth'},
    });
    expect(() => payload['total'] = 0, throwsUnsupportedError);
  });

  test('billingInvoiceIssueCommandKey is stable across request times', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 750,
      issueDate: DateTime(2026, 5, 31),
    );

    final firstKey = billingInvoiceIssueCommandKey(
      draft,
      requestedAt: DateTime(2026, 5, 31, 10, 30),
      channel: 'pos',
    );
    final secondKey = billingInvoiceIssueCommandKey(
      draft,
      requestedAt: DateTime(2026, 5, 31, 10, 45),
      channel: 'pos',
    );

    expect(firstKey, secondKey);
  });

  test('billingInvoiceIssueCommandKey changes when draft content changes', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 750,
      issueDate: DateTime(2026, 5, 31),
    );
    final changedDraft = draft.copyWith(amount: 751);

    expect(
      billingInvoiceIssueCommandKey(draft, channel: 'pos'),
      isNot(billingInvoiceIssueCommandKey(changedDraft, channel: 'pos')),
    );
  });

  test('buildBillingInvoiceIssueCommand carries issue-plan tax behavior', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
      taxMode: BillingInvoiceTaxMode.inclusive,
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'subscription',
          description: 'Subscription seats',
          quantity: 1,
          unitPrice: 110,
          taxRate: 0.1,
        ),
      ],
    );

    final command = buildBillingInvoiceIssueCommand(
      draft,
      requestedAt: DateTime(2026, 5, 31),
      preferences: const BillingTenantPreferences(paymentTermsDays: 7),
    );

    expect(command.issuePlan.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(command.issuePlan.dueDate, DateTime(2026, 6, 7));
    expect(command.total, 110);
  });

  test(
    'buildBillingInvoiceIssueCommand carries scheduled payment behavior',
    () {
      final command = buildBillingInvoiceIssueCommand(
        BillingInvoiceDraft(
          tenantId: 'tenant-a',
          amount: 1200,
          issueDate: DateTime(2026, 6, 10),
        ),
        requestedAt: DateTime(2026, 6, 10),
        preferences: const BillingTenantPreferences(paymentTermsDays: 10),
        paymentScheduleOptions: BillingPaymentScheduleOptions.splitEqual(
          installments: 3,
          intervalDays: 15,
        ),
      );

      expect(command.issuePlan.paymentSchedule.paymentCount, 3);
      expect(
        command.issuePlan.paymentSchedule.items.map((item) => item.dueDate),
        [DateTime(2026, 6, 20), DateTime(2026, 7, 5), DateTime(2026, 7, 20)],
      );

      final payload = command.toPayload();
      final paymentSchedule =
          payload['paymentSchedule'] as Map<String, Object?>;
      final scheduleItems =
          paymentSchedule['items'] as List<Map<String, Object?>>;
      expect(paymentSchedule['strategy'], 'splitEqual');
      expect(scheduleItems.map((item) => item['amount']), [400, 400, 400]);
    },
  );

  test('buildBillingInvoiceIssueCommand applies reusable issue policies', () {
    final policy = billingInvoiceIssuePolicyForProfile(
      constructionBillingDomainProfile(),
    );
    final command = buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 900,
        issueDate: DateTime(2026, 6, 10),
      ),
      requestedAt: DateTime(2026, 6, 10),
      preferences: const BillingTenantPreferences(paymentTermsDays: 10),
      issuePolicy: policy,
    );

    final payload = command.toPayload();
    final paymentSchedule = payload['paymentSchedule'] as Map<String, Object?>;

    expect(command.issuePlan.paymentSchedule.paymentCount, 3);
    expect(paymentSchedule['strategy'], 'splitEqual');
    expect(paymentSchedule['paymentCount'], 3);
  });

  test('BillingInvoiceIssueCommand blocks invalid draft issuance', () {
    final command = buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: '',
        amount: 0,
        issueDate: DateTime(2026, 5, 31),
      ),
      requestedAt: DateTime(2026, 5, 31),
      channel: '',
    );

    expect(command.canIssue, isFalse);
    expect(command.validationErrors, [
      'Invoice issue channel is required.',
      'Choose a tenant before creating an invoice.',
      'Enter an invoice amount greater than zero.',
    ]);
    expect(command.ensureCanIssue, throwsStateError);
  });

  test('billingInvoiceIssueCommandKey normalizes empty inputs', () {
    final key = billingInvoiceIssueCommandKey(
      BillingInvoiceDraft(
        tenantId: '',
        amount: 100,
        issueDate: DateTime(2026, 5, 31),
      ),
      requestedAt: DateTime(2026, 5, 31),
      channel: '',
    );

    expect(key, startsWith('issue-unknown-unknown-'));
    expect(
      key,
      billingInvoiceIssueCommandKey(
        BillingInvoiceDraft(
          tenantId: '',
          amount: 100,
          issueDate: DateTime(2026, 5, 31),
        ),
        requestedAt: DateTime(2027),
        channel: '',
      ),
    );
  });
}
