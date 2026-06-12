import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class OrderSavedWorkspaceDetailsSurfaceHeader extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const OrderSavedWorkspaceDetailsSurfaceHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      key: const ValueKey('order_saved_workspace_details_header'),
      children: [
        Icon(
          Icons.bookmark_rounded,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: POSUiTokens.gap),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
        if (showCloseButton) ...[
          const SizedBox(width: POSUiTokens.gap),
          IconButton(
            key: const ValueKey('order_saved_workspace_details_close'),
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ],
    );
  }
}
