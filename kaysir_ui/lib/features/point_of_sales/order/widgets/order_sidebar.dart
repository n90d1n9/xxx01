import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_commerce_channel_provider.dart';
import '../../cashier/experiences/pos_experience_action_policy.dart';
import '../../cashier/experiences/pos_experience_provider.dart';
import '../../cashier/experiences/pos_order_fulfillment_provider.dart';
import '../../cashier/states/terminal_provider.dart';
import '../../cashier/widgets/customer_selection_dialog.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../../payment/widgets/payment_dialog.dart';
import '../../promotion/widgets/promotion_dialog.dart';
import '../states/current_order_provider.dart';
import 'order_checkout_panel.dart';
import 'order_completion_flow.dart';
import 'order_customer_panel.dart';
import 'order_fulfillment_panel.dart';
import 'order_header_panel.dart';
import 'order_items_panel.dart';
import 'order_promotions_panel.dart';

class OrderSidebar extends ConsumerWidget {
  final bool compact;
  final bool edgeToEdge;

  const OrderSidebar({
    super.key,
    this.compact = false,
    this.edgeToEdge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrder = ref.watch(currentOrderProvider);
    final checkoutBehavior = ref.watch(posCheckoutBehaviorProvider);
    final actionPolicy = ref.watch(posExperienceActionPolicyProvider);
    final canSelectCustomer = actionPolicy.allows(
      POSExperienceAction.customerSelection,
    );
    final canUsePromotions = actionPolicy.allows(
      POSExperienceAction.promotions,
    );
    final canTakePayments = actionPolicy.allows(POSExperienceAction.payments);
    final canStartNewOrder = actionPolicy.allows(POSExperienceAction.newOrders);
    final theme = Theme.of(context);

    if (currentOrder == null) {
      return const POSEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No active order',
        message: 'Select a terminal to begin a new sale.',
      );
    }

    final commerceChannel = ref.watch(posCommerceChannelProvider);
    final fulfillmentContext = ref.watch(posOrderFulfillmentContextProvider);
    final fulfillmentReadiness = ref.watch(
      posOrderFulfillmentReadinessProvider,
    );
    final fulfillmentBehaviorHints = ref.watch(
      posOrderFulfillmentBehaviorHintsProvider,
    );
    final fulfillmentController = ref.watch(
      posOrderFulfillmentControllerProvider,
    );
    final headerStatusLabel =
        currentOrder.isPaid && fulfillmentReadiness?.canComplete == false
            ? fulfillmentReadiness!.statusLabel
            : checkoutBehavior.readinessLabel(currentOrder);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow:
            edgeToEdge
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(-4, 0),
                  ),
                ],
      ),
      child: Column(
        children: [
          OrderHeaderPanel(
            order: currentOrder,
            compact: compact,
            onNewOrderPressed: () => _confirmNewOrder(context, ref),
            showNewOrderAction: canStartNewOrder,
            statusLabel: headerStatusLabel,
          ),
          if (fulfillmentReadiness?.needsOperatorInput == true)
            OrderFulfillmentPanel(
              channel: commerceChannel,
              context: fulfillmentContext,
              readiness: fulfillmentReadiness!,
              behaviorHints: fulfillmentBehaviorHints,
              compact: compact,
              onModeChanged: fulfillmentController.setMode,
              onContactChanged: fulfillmentController.setContactName,
              onDestinationChanged: fulfillmentController.setDestination,
              onTableChanged: fulfillmentController.setTableName,
              onScheduleChanged: fulfillmentController.setScheduleLabel,
            ),
          if (canSelectCustomer || currentOrder.customer != null)
            OrderCustomerPanel(
              order: currentOrder,
              compact: compact,
              canManageCustomer: canSelectCustomer,
              onSelectCustomer: () => _showCustomerDialog(context),
              onRemoveCustomer: () {
                ref.read(currentOrderProvider.notifier).removeCustomer();
              },
            ),
          Expanded(child: OrderItemsPanel(order: currentOrder)),
          if (canUsePromotions || currentOrder.appliedPromotions.isNotEmpty)
            OrderPromotionsPanel(
              order: currentOrder,
              canManagePromotions: canUsePromotions,
              onManagePromotions: () => _showPromotionDialog(context),
              onRemovePromotion: (promotionId) {
                ref
                    .read(currentOrderProvider.notifier)
                    .removePromotion(promotionId);
              },
            ),
          OrderCheckoutPanel(
            order: currentOrder,
            onShowPromotions: () => _showPromotionDialog(context),
            onShowPayment: () => _showPaymentDialog(context),
            onCompleteOrder: () => _completeOrder(context, ref),
            checkoutBehavior: checkoutBehavior,
            fulfillmentReadiness: fulfillmentReadiness,
            showPromotionAction: canUsePromotions,
            showPaymentAction: canTakePayments,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmNewOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Order'),
            content: const Text('Clear the current order and start a new one?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final currentTerminal = ref.read(currentTerminalProvider);
    if (currentTerminal == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a terminal before new order')),
      );
      return;
    }

    final notifier = ref.read(currentOrderProvider.notifier);
    notifier.cancelOrder();
    notifier.createNewOrder(currentTerminal);
  }

  void _showCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomerSelectionDialog(),
    );
  }

  void _showPromotionDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const PromotionDialog());
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const PaymentDialog());
  }

  Future<void> _completeOrder(BuildContext context, WidgetRef ref) async {
    await completeAndPresentPOSOrder(context: context, ref: ref);
  }
}
