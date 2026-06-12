import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class ChipSurface extends StatelessWidget {
  const ChipSurface({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    super.key,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: borderColor),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
