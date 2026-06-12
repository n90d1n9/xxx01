import 'package:flutter/material.dart';

import 'app_icon_badge.dart';
import 'app_text_cluster.dart';

enum AppInfoRowIconStyle { plain, badge }

class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.contained = false,
    this.iconStyle = AppInfoRowIconStyle.plain,
    this.padding,
    this.iconSize = 20,
    this.iconBoxSize = 36,
    this.iconGap = 12,
    this.trailingGap = 10,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
    this.titleOverflow = TextOverflow.ellipsis,
    this.subtitleOverflow = TextOverflow.ellipsis,
    this.titleGap = 3,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool contained;
  final AppInfoRowIconStyle iconStyle;
  final EdgeInsetsGeometry? padding;
  final double iconSize;
  final double iconBoxSize;
  final double iconGap;
  final double trailingGap;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int? titleMaxLines;
  final int? subtitleMaxLines;
  final TextOverflow? titleOverflow;
  final TextOverflow? subtitleOverflow;
  final double titleGap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedPadding =
        padding ??
        (contained
            ? const EdgeInsets.fromLTRB(12, 10, 10, 10)
            : EdgeInsets.zero);
    final resolvedTitleStyle =
        titleStyle ??
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800);
    final resolvedSubtitleStyle =
        subtitleStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );

    final child = Padding(
      padding: resolvedPadding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (icon != null) ...[
            _InfoRowIcon(
              icon: icon!,
              style: iconStyle,
              size: iconSize,
              boxSize: iconBoxSize,
              backgroundColor: iconBackgroundColor,
              foregroundColor: iconForegroundColor,
            ),
            SizedBox(width: iconGap),
          ],
          Expanded(
            child: AppTextCluster(
              title: title,
              subtitle: subtitle,
              titleStyle: resolvedTitleStyle,
              subtitleStyle: resolvedSubtitleStyle,
              titleMaxLines: titleMaxLines,
              subtitleMaxLines: subtitleMaxLines,
              titleOverflow: titleOverflow,
              subtitleOverflow: subtitleOverflow,
              titleGap: titleGap,
            ),
          ),
          if (trailing != null) ...[SizedBox(width: trailingGap), trailing!],
        ],
      ),
    );

    if (!contained) {
      if (onTap == null) return child;

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: child,
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: borderColor ?? colorScheme.outlineVariant),
    );

    return Material(
      color: backgroundColor ?? colorScheme.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child:
          onTap == null
              ? child
              : InkWell(onTap: onTap, customBorder: shape, child: child),
    );
  }
}

class _InfoRowIcon extends StatelessWidget {
  const _InfoRowIcon({
    required this.icon,
    required this.style,
    required this.size,
    required this.boxSize,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final AppInfoRowIconStyle style;
  final double size;
  final double boxSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (style == AppInfoRowIconStyle.badge) {
      return AppIconBadge(
        icon: icon,
        size: boxSize,
        iconSize: size,
        backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
        foregroundColor: foregroundColor ?? colorScheme.onPrimaryContainer,
      );
    }

    return Icon(
      icon,
      color: foregroundColor ?? colorScheme.primary,
      size: size,
    );
  }
}
