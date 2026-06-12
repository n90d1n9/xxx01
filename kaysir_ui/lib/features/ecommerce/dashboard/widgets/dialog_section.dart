import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class DialogSection extends StatelessWidget {
  const DialogSection({
    required this.title,
    required this.child,
    this.trailing,
    this.spacing = POSUiTokens.gap,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: POSUiTokens.gap),
                trailing,
              ],
            ],
          ),
          SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}
