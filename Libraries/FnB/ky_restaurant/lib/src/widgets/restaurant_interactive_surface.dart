import 'package:flutter/material.dart';

class RestaurantInteractiveSurface extends StatelessWidget {
  const RestaurantInteractiveSurface({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.selectedBorderColor,
    this.borderRadius = 8,
    this.borderWidth = 1,
    this.selectedBorderWidth = 1.4,
    this.isSelected = false,
    this.tooltip,
    this.onPressed,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color? selectedBorderColor;
  final double borderRadius;
  final double borderWidth;
  final double selectedBorderWidth;
  final bool isSelected;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(borderRadius);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? selectedBorderColor ?? colors.primary
                  : borderColor,
              width: isSelected ? selectedBorderWidth : borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
    final tooltipMessage = tooltip?.trim();
    if (tooltipMessage == null || tooltipMessage.isEmpty) return button;

    return Tooltip(message: tooltipMessage, child: button);
  }
}
