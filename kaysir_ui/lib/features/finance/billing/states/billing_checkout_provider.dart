import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_checkout.dart';
import '../repositories/billing_checkout_repository.dart';
import '../utils/billing_cart_invoice_line_items.dart';
import '../utils/billing_invoice_line_item_summary.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_cart_provider.dart';
import 'billing_product_catalog_provider.dart';

final billingCheckoutRepositoryProvider = Provider<BillingCheckoutRepository>(
  (ref) => const DemoBillingCheckoutRepository(),
);

final billingCheckoutDomainModuleProvider =
    Provider<BillingBusinessDomainModule>((ref) {
      final tenant = ref.watch(currentTenantProvider);
      if (tenant == null) {
        return ref.watch(billingDefaultBusinessDomainModuleProvider);
      }

      return ref.watch(billingTenantDomainModuleProvider(tenant.preferences));
    });

final billingCheckoutDomainProfileProvider =
    Provider<BillingBusinessDomainProfile>((ref) {
      return ref.watch(billingCheckoutDomainModuleProvider).profile;
    });

final billingCheckoutControllerProvider = StateNotifierProvider<
  BillingCheckoutController,
  AsyncValue<BillingCheckoutReceipt?>
>((ref) {
  return BillingCheckoutController(ref);
});

class BillingCheckoutController
    extends StateNotifier<AsyncValue<BillingCheckoutReceipt?>> {
  final Ref ref;

  BillingCheckoutController(this.ref) : super(const AsyncData(null));

  Future<BillingCheckoutReceipt> submitCurrentCart() async {
    final tenant = ref.read(currentTenantProvider);

    if (tenant == null) {
      throw StateError('Select a tenant before checking out.');
    }
    final cartItems = ref.read(cartItemsForTenantProvider(tenant.id));
    if (cartItems.isEmpty) {
      throw StateError('Add at least one item before checking out.');
    }

    state = const AsyncLoading();

    try {
      final profile = ref.read(billingCheckoutDomainProfileProvider);
      final lineItems = billingCartItemsToInvoiceLineItems(
        cartItems,
        profile: profile,
      );
      final request = BillingCheckoutRequest(
        tenantId: tenant.id,
        tenantName: tenant.name,
        items: cartItems,
        lineItems: lineItems,
        total:
            summarizeBillingInvoiceLineItems(
              lineItems,
              taxMode: profile.taxMode,
            ).total,
      );
      final receipt = await ref
          .read(billingCheckoutRepositoryProvider)
          .submitCheckout(request);

      ref.read(cartProvider.notifier).clearTenantCart(tenant.id);
      state = AsyncData(receipt);
      return receipt;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
