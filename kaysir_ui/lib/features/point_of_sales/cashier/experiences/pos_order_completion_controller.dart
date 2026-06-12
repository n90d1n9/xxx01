import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../order/models/order.dart';
import '../../order/states/order_save_outbox_auto_sync_provider.dart';
import '../../order/states/current_order_provider.dart';
import 'pos_order_fulfillment.dart';
import 'pos_order_fulfillment_provider.dart';

final posOrderCompletionControllerProvider =
    Provider<POSOrderCompletionController>(
      (ref) => POSOrderCompletionController(ref),
    );

enum POSOrderCompletionStatus {
  completed,
  noActiveOrder,
  paymentRequired,
  fulfillmentBlocked,
  failed,
}

class POSOrderCompletionResult {
  final POSOrderCompletionStatus status;
  final Order? order;
  final POSOrderFulfillmentReadiness? fulfillmentReadiness;

  const POSOrderCompletionResult({
    required this.status,
    this.order,
    this.fulfillmentReadiness,
  });

  bool get isCompleted => status == POSOrderCompletionStatus.completed;

  String get operatorMessage {
    switch (status) {
      case POSOrderCompletionStatus.completed:
        return '';
      case POSOrderCompletionStatus.noActiveOrder:
        return 'No active order to complete.';
      case POSOrderCompletionStatus.paymentRequired:
        return 'Complete payment before closing the order.';
      case POSOrderCompletionStatus.fulfillmentBlocked:
        return fulfillmentReadiness?.summaryLabel ??
            'Complete fulfillment details before closing.';
      case POSOrderCompletionStatus.failed:
        return 'Unable to complete order.';
    }
  }
}

class POSOrderCompletionController {
  final Ref _ref;

  const POSOrderCompletionController(this._ref);

  Future<POSOrderCompletionResult> completeCurrentOrder() async {
    final order = _ref.read(currentOrderProvider);
    if (order == null) {
      return const POSOrderCompletionResult(
        status: POSOrderCompletionStatus.noActiveOrder,
      );
    }

    if (!order.isPaid) {
      return const POSOrderCompletionResult(
        status: POSOrderCompletionStatus.paymentRequired,
      );
    }

    final fulfillmentReadiness = _ref.read(
      posOrderFulfillmentReadinessProvider,
    );
    if (fulfillmentReadiness?.canComplete == false) {
      return POSOrderCompletionResult(
        status: POSOrderCompletionStatus.fulfillmentBlocked,
        fulfillmentReadiness: fulfillmentReadiness,
      );
    }

    final orderNotifier = _ref.read(currentOrderProvider.notifier);
    if (fulfillmentReadiness != null) {
      orderNotifier.setFulfillment(
        fulfillmentReadiness.toOrderFulfillmentSnapshot(),
      );
    }

    final completedOrder = await orderNotifier.completeOrder();
    if (completedOrder == null) {
      return POSOrderCompletionResult(
        status: POSOrderCompletionStatus.failed,
        fulfillmentReadiness: fulfillmentReadiness,
      );
    }

    _ref
        .read(posOrderSaveOutboxAutoSyncControllerProvider)
        .maybeSyncAfterCompletion();

    return POSOrderCompletionResult(
      status: POSOrderCompletionStatus.completed,
      order: completedOrder,
      fulfillmentReadiness: fulfillmentReadiness,
    );
  }
}
