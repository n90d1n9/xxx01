import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class OrderFilterChoiceStrip extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const OrderFilterChoiceStrip({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(right: POSUiTokens.gap),
                    child: child,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
