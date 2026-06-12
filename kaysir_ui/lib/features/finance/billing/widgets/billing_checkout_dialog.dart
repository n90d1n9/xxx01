import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_cart_item.dart';
import '../models/billing_checkout.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_cart_provider.dart';
import '../states/billing_checkout_provider.dart';
import '../states/billing_product_catalog_provider.dart';
import '../utils/billing_cart_summary.dart';
import 'billing_checkout_receipt_sheet.dart';
import 'billing_checkout_review.dart';

Future<BillingCheckoutReceipt?> showBillingCheckoutDialog(
  BuildContext context, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) async {
  final receipt = await showDialog<BillingCheckoutReceipt>(
    context: context,
    builder: (context) => const BillingCheckoutDialog(),
  );

  if (receipt == null || !context.mounted) return receipt;

  await showBillingCheckoutReceiptSheet(
    context,
    receipt: receipt,
    preferences: preferences,
  );
  return receipt;
}

class BillingCheckoutDialog extends ConsumerWidget {
  const BillingCheckoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTenant = ref.watch(currentTenantProvider);
    final tenantId = currentTenant?.id ?? '';
    final cartItems =
        currentTenant == null
            ? const <CartItem>[]
            : ref.watch(cartItemsForTenantProvider(tenantId));
    final summary =
        currentTenant == null
            ? const BillingCartSummary(
              lineCount: 0,
              itemCount: 0,
              subtotal: 0,
              discount: 0,
              tax: 0,
              total: 0,
            )
            : ref.watch(cartSummaryForTenantProvider(tenantId));
    final checkoutAsync = ref.watch(billingCheckoutControllerProvider);
    final isSubmitting = checkoutAsync.isLoading;

    return AlertDialog(
      scrollable: true,
      title: const Text('Confirm Purchase'),
      content: BillingCheckoutReview(
        tenantName: currentTenant?.name ?? '-',
        cartItems: cartItems,
        summary: summary,
        preferences:
            currentTenant?.preferences ?? const BillingTenantPreferences(),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              isSubmitting || cartItems.isEmpty
                  ? null
                  : () => _submitCheckout(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child:
              isSubmitting
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _submitCheckout(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final receipt =
          await ref
              .read(billingCheckoutControllerProvider.notifier)
              .submitCurrentCart();
      if (!context.mounted) return;

      navigator.pop(receipt);
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
