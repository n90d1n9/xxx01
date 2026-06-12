import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_actions.dart';

class OrderSaveOutboxActionBar extends StatelessWidget {
  final POSOrderSaveOutboxActions actions;
  final VoidCallback? onSync;
  final VoidCallback? onClearSent;

  const OrderSaveOutboxActionBar({
    super.key,
    required this.actions,
    this.onSync,
    this.onClearSent,
  });

  @override
  Widget build(BuildContext context) {
    final syncButton = _actionButton(
      key: const ValueKey('order-save-outbox-sync-action'),
      action: actions.syncNow,
      icon:
          actions.syncNow.busy
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.sync),
      onPressed: onSync,
      variant: POSActionButtonVariant.filled,
    );
    final clearButton = _actionButton(
      key: const ValueKey('order-save-outbox-clear-sent-action'),
      action: actions.clearSent,
      icon: const Icon(Icons.cleaning_services_outlined),
      onPressed: onClearSent,
      variant: POSActionButtonVariant.tonal,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              syncButton,
              const SizedBox(height: POSUiTokens.gap),
              clearButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: syncButton),
            const SizedBox(width: POSUiTokens.gap),
            Expanded(child: clearButton),
          ],
        );
      },
    );
  }

  Widget _actionButton({
    required Key key,
    required POSOrderSaveOutboxActionState action,
    required Widget icon,
    required VoidCallback? onPressed,
    required POSActionButtonVariant variant,
  }) {
    return Tooltip(
      message: action.tooltip,
      child: POSActionButton(
        key: key,
        icon: icon,
        label: action.label,
        onPressed: action.isEnabled ? onPressed : null,
        variant: variant,
      ),
    );
  }
}
