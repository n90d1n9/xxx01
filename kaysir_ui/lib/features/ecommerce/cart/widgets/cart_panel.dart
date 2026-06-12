import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../payment_button.dart';
import '../../checkout/states/checkout_provider.dart';
import '../../checkout/widgets/checkout_panel.dart';
import '../cart_item_tile.dart';
import '../cart_summary.dart';
import '../states/cart_providers.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartProvider.notifier).total;
    final checkoutSession = ref.watch(ecommerceActiveCheckoutSessionProvider);
    final paymentBlockingIssues = checkoutSession.paymentBlockingIssues;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = cart[index];
            return Dismissible(
              key: Key(item.product.id),
              direction: DismissDirection.endToStart,
              onDismissed:
                  (_) => ref
                      .read(cartProvider.notifier)
                      .removeProduct(item.product.id),
              child: CartItemTile(
                item: item,
                onQuantityChanged: (quantity) {
                  ref
                      .read(cartProvider.notifier)
                      .updateQuantity(item.product.id, quantity);
                },
                onRemove:
                    () => ref
                        .read(cartProvider.notifier)
                        .removeProduct(item.product.id),
              ),
            );
          }, childCount: cart.length),
        ),
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(child: CartSummary(cartTotal: cartTotal)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CheckoutPanel(compact: true),
          ),
        ),
        SliverToBoxAdapter(
          child: PaymentButtons(
            enabled: checkoutSession.canSelectPayment,
            externalSettlementLabel:
                checkoutSession.payment?.isExternal == true
                    ? 'Complete ${checkoutSession.payment!.label}'
                    : null,
            disabledMessage:
                paymentBlockingIssues.isEmpty
                    ? null
                    : paymentBlockingIssues.first.message,
            onExternalSettlementSelected: () {
              if (cart.isEmpty) return;
              ref.read(ecommerceCheckoutSessionProvider.notifier).complete();
            },
            onPaymentSelected: (paymentMethod) {
              if (cart.isEmpty) return;
              final checkout = ref.read(
                ecommerceCheckoutSessionProvider.notifier,
              );
              checkout.selectPaymentMethod(paymentMethod);
              checkout.complete();
            },
          ),
        ),
      ],
    );
  }
}
