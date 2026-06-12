import 'package:flutter/material.dart';

class FinancialReportRowSurface extends StatelessWidget {
  const FinancialReportRowSurface({
    required this.child,
    required this.isDarkMode,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    this.backgroundColor,
    this.borderColor,
    this.showBottomBorder = true,
    super.key,
  });

  final Widget child;
  final bool isDarkMode;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor =
        borderColor ?? (isDarkMode ? Colors.white10 : Colors.grey.shade100);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border:
            showBottomBorder
                ? Border(bottom: BorderSide(color: resolvedBorderColor))
                : null,
      ),
      child: child,
    );
  }
}
