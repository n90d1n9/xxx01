import 'package:flutter/material.dart';

class FinancialReportTintedSurface extends StatelessWidget {
  const FinancialReportTintedSurface({
    required this.color,
    required this.child,
    this.minHeight,
    this.padding = const EdgeInsets.all(12),
    this.fillAlpha = 0.07,
    this.borderAlpha = 0.2,
    this.borderRadius = 8,
    this.backgroundColor,
    this.width,
    super.key,
  });

  final Color color;
  final Widget child;
  final double? minHeight;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double fillAlpha;
  final double borderAlpha;
  final double borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: fillAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: child,
    );
  }
}
