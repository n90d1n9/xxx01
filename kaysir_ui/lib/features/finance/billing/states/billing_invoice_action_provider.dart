import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_invoice.dart';
import '../models/billing_invoice_action.dart';
import '../repositories/billing_invoice_action_repository.dart';

final billingInvoiceActionRepositoryProvider =
    Provider<BillingInvoiceActionRepository>(
      (ref) => const DemoBillingInvoiceActionRepository(),
    );

final billingInvoiceActionControllerProvider = StateNotifierProvider<
  BillingInvoiceActionController,
  AsyncValue<BillingInvoiceActionResult?>
>((ref) {
  return BillingInvoiceActionController(ref);
});

class BillingInvoiceActionController
    extends StateNotifier<AsyncValue<BillingInvoiceActionResult?>> {
  final Ref ref;

  BillingInvoiceActionController(this.ref) : super(const AsyncData(null));

  Future<BillingInvoiceActionResult> performAction({
    required BillingInvoice invoice,
    required BillingInvoiceAction action,
    String? tenantName,
  }) async {
    if (!action.enabled) {
      throw StateError(
        action.disabledReason ?? 'This invoice action is not available.',
      );
    }

    state = const AsyncLoading();

    try {
      final result = await ref
          .read(billingInvoiceActionRepositoryProvider)
          .performAction(
            BillingInvoiceActionRequest(
              invoice: invoice,
              action: action,
              tenantName: tenantName,
            ),
          );
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
