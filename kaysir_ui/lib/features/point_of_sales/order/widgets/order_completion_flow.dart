import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_experience_provider.dart';
import '../../cashier/experiences/pos_order_completion_controller.dart';
import '../states/current_order_provider.dart';
import 'receipt_dialog.dart';

Future<void> completeAndPresentPOSOrder({
  required BuildContext context,
  required WidgetRef ref,
  String? successMessage,
  Color? successColor,
}) async {
  final completionResult =
      await ref
          .read(posOrderCompletionControllerProvider)
          .completeCurrentOrder();
  if (!context.mounted) return;

  await presentPOSOrderCompletionResult(
    context: context,
    ref: ref,
    completionResult: completionResult,
    successMessage: successMessage,
    successColor: successColor,
  );
}

Future<void> presentPOSOrderCompletionResult({
  required BuildContext context,
  required WidgetRef ref,
  required POSOrderCompletionResult completionResult,
  String? successMessage,
  Color? successColor,
}) async {
  if (!completionResult.isCompleted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(completionResult.operatorMessage)));
    return;
  }

  final completedOrder = completionResult.order!;
  final checkoutBehavior = ref.read(posCheckoutBehaviorProvider);
  if (checkoutBehavior.startNewOrderAfterCompletion) {
    ref
        .read(currentOrderProvider.notifier)
        .createNewOrder(completedOrder.terminal);
  }

  if (checkoutBehavior.showReceiptAfterCompletion) {
    await showDialog(
      context: context,
      builder: (context) => ReceiptDialog(order: completedOrder),
    );
    return;
  }

  if (successMessage != null && successMessage.trim().isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage), backgroundColor: successColor),
    );
  }
}
