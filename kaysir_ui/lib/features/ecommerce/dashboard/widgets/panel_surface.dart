import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class PanelSurface extends StatelessWidget {
  const PanelSurface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.border,
    this.elevated = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BoxBorder? border;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      padding: padding,
      color: color ?? theme.colorScheme.surface,
      border: border ?? Border.all(color: theme.dividerColor),
      elevated: elevated,
      child: child,
    );
  }
}
