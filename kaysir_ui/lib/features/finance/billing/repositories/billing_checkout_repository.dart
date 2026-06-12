import '../models/billing_checkout.dart';

abstract class BillingCheckoutRepository {
  Future<BillingCheckoutReceipt> submitCheckout(BillingCheckoutRequest request);
}

class DemoBillingCheckoutRepository implements BillingCheckoutRepository {
  final Duration latency;
  final DateTime Function() clock;

  const DemoBillingCheckoutRepository({
    this.latency = const Duration(milliseconds: 700),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  @override
  Future<BillingCheckoutReceipt> submitCheckout(
    BillingCheckoutRequest request,
  ) async {
    await _wait();
    final createdAt = clock();

    return BillingCheckoutReceipt(
      id: 'chk-${createdAt.millisecondsSinceEpoch}',
      tenantId: request.tenantId,
      tenantName: request.tenantName,
      total: request.total,
      itemCount: request.itemCount,
      createdAt: createdAt,
    );
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
