import 'package:flutter/material.dart';

class RestaurantIconBadge extends StatelessWidget {
  const RestaurantIconBadge({
    super.key,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    this.iconSize = 18,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 8,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Icon(icon, color: foregroundColor, size: iconSize),
      ),
    );
  }
}
