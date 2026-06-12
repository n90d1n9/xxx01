import 'package:flutter/material.dart';

import 'app_icon_badge.dart';

class AppCheckboxRow extends StatelessWidget {
  const AppCheckboxRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.trailing,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.contained = false,
    this.iconBadge = false,
    this.padding,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 1,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final ListTileControlAffinity controlAffinity;
  final bool contained;
  final bool iconBadge;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final int? titleMaxLines;
  final int? subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(
        color:
            contained
                ? borderColor ?? colorScheme.outlineVariant
                : Colors.transparent,
      ),
    );

    final tile = CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: controlAffinity,
      contentPadding:
          padding ??
          (contained
              ? const EdgeInsets.fromLTRB(12, 4, 12, 4)
              : EdgeInsets.zero),
      dense: true,
      shape: shape,
      tileColor: contained ? backgroundColor ?? colorScheme.surface : null,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      activeColor: colorScheme.primary,
      title: Text(
        title,
        maxLines: titleMaxLines,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color:
              onChanged == null
                  ? colorScheme.onSurface.withValues(alpha: 0.38)
                  : colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                subtitle!,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      onChanged == null
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      secondary: trailing ?? _buildIcon(),
    );

    if (!contained) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: tile,
    );
  }

  Widget? _buildIcon() {
    if (icon == null) return null;

    return _CheckboxRowIcon(icon: icon!, badge: iconBadge);
  }
}

class _CheckboxRowIcon extends StatelessWidget {
  const _CheckboxRowIcon({required this.icon, required this.badge});

  final IconData icon;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (badge) {
      return AppIconBadge(
        icon: icon,
        size: 36,
        iconSize: 20,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      );
    }

    return Icon(icon, color: colorScheme.primary, size: 20);
  }
}
