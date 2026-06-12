import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class InsetSurface extends StatelessWidget {
  const InsetSurface({
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.color,
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      padding: padding,
      color:
          color ??
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
      border: border ?? Border.all(color: theme.dividerColor),
      child: child,
    );
  }
}
