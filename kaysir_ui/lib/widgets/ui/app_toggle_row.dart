import 'package:flutter/material.dart';

import 'app_info_row.dart';

class AppToggleRow extends StatelessWidget {
  const AppToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
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
  final bool value;
  final ValueChanged<bool>? onChanged;
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
    return AppInfoRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      contained: contained,
      iconStyle:
          iconBadge ? AppInfoRowIconStyle.badge : AppInfoRowIconStyle.plain,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      titleMaxLines: titleMaxLines,
      subtitleMaxLines: subtitleMaxLines,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
