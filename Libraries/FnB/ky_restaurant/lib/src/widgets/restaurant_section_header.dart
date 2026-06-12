import 'package:flutter/material.dart';

class RestaurantSectionHeader extends StatelessWidget {
  const RestaurantSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.iconSize = 18,
    this.subtitle,
    this.trailingLabel,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
    this.trailingStyle,
  }) : assert(
         trailing == null || trailingLabel == null,
         'Use trailing or trailingLabel, not both.',
       );

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final String? subtitle;
  final String? trailingLabel;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final effectiveTrailing =
        trailing ??
        (trailingLabel == null
            ? null
            : Text(
                trailingLabel!,
                style:
                    trailingStyle ??
                    theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
              ));

    return Row(
      crossAxisAlignment: subtitle == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? colors.onSurfaceVariant,
            size: iconSize,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    titleStyle ??
                    theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style:
                      subtitleStyle ??
                      theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (effectiveTrailing != null) ...[
          const SizedBox(width: 8),
          effectiveTrailing,
        ],
      ],
    );
  }
}
