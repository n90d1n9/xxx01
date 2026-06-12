import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_action.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_action_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_invoice_action_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_actions.dart';

void main() {
  test('performAction submits enabled invoice actions', () async {
    final repository = _FakeBillingInvoiceActionRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final action = billingInvoiceActions(BillingInvoiceStatus.pending).first;

    final result = await container
        .read(billingInvoiceActionControllerProvider.notifier)
        .performAction(
          invoice: _invoice(),
          action: action,
          tenantName: 'Acme Corp',
        );

    expect(repository.requests, hasLength(1));
    expect(repository.requests.single.invoice.id, 'inv-pending');
    expect(repository.requests.single.action.type, action.type);
    expect(repository.requests.single.tenantName, 'Acme Corp');
    expect(result.message, 'handled inv-pending');
    expect(
      container.read(billingInvoiceActionControllerProvider).requireValue?.type,
      BillingInvoiceActionType.collectPayment,
    );
  });

  test('performAction rejects disabled invoice actions', () async {
    final repository = _FakeBillingInvoiceActionRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final action = billingInvoiceActions(BillingInvoiceStatus.paid).first;

    expect(
      container
          .read(billingInvoiceActionControllerProvider.notifier)
          .performAction(invoice: _invoice(), action: action),
      throwsStateError,
    );
    expect(repository.requests, isEmpty);
  });
}

ProviderContainer _container(BillingInvoiceActionRepository repository) {
  return ProviderContainer(
    overrides: [
      billingInvoiceActionRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

BillingInvoice _invoice() {
  return BillingInvoice(
    id: 'inv-pending',
    tenantId: 'tenant-test',
    amount: 2000,
    date: DateTime(2026, 6, 10),
    status: BillingInvoiceStatus.pending,
  );
}

class _FakeBillingInvoiceActionRepository
    implements BillingInvoiceActionRepository {
  final requests = <BillingInvoiceActionRequest>[];

  @override
  Future<BillingInvoiceActionResult> performAction(
    BillingInvoiceActionRequest request,
  ) async {
    requests.add(request);
    return BillingInvoiceActionResult(
      type: request.action.type,
      invoiceId: request.invoice.id,
      message: 'handled ${request.invoice.id}',
      completedAt: DateTime(2026, 6, 10),
    );
  }
}
