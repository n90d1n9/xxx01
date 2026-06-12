import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class CheckoutReadinessBanner extends StatelessWidget {
  final bool ready;
  final String title;
  final String message;

  const CheckoutReadinessBanner({
    super.key,
    required this.ready,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        ready
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.42)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.42);
    final foreground =
        ready
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onErrorContainer;

    return POSSurface(
      color: background,
      padding: const EdgeInsets.all(12),
      border: Border.all(color: foreground.withValues(alpha: 0.12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ready ? Icons.check_circle_outline : Icons.info_outline,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foreground.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
