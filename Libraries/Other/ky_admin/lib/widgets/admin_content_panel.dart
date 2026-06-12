import 'package:flutter/material.dart';

import '../../../widgets/ui/app_surface.dart';
import 'admin_section_header.dart';

class AdminContentPanel extends StatelessWidget {
  const AdminContentPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.elevated = true,
    this.padding = const EdgeInsets.all(18),
    this.contentSpacing = 16,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool elevated;
  final EdgeInsetsGeometry padding;
  final double contentSpacing;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      elevated: elevated,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionHeader(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            trailing: trailing,
          ),
          SizedBox(height: contentSpacing),
          child,
        ],
      ),
    );
  }
}
